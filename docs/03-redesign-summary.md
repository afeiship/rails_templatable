# Rails Templatable 架构重构总结

## 重构概述

将 rails_templatable 从 **N:N（多对多）关系**重构为 **1:N（一对多）关系**。

## 核心变化

### 关系模型变更

#### 之前（N:N - 错误）
```
Post 1 ←→ Template A, Template B
Post 2 ←→ Template A
需要中间表: rails_templatable_assignments
```

#### 现在（1:N - 正确）
```
Post 1 → Template A
Post 2 → Template B
Post 3 → Template A  (可复用)
无需中间表，直接外键
```

## 代码变更

### 1. 删除的文件

- ❌ `app/models/rails_templatable/template_assignment.rb`
- ❌ `app/models/concerns/rails_templatable/has_templates.rb`

### 2. 新增的文件

- ✅ `app/models/concerns/rails_templatable/has_template.rb` (单数)

### 3. 修改的文件

#### db/migrate/20250207000000_create_rails_templatable_tables.rb
- ❌ 删除：`rails_templatable_assignments` 中间表创建
- ✅ 保留：仅创建 `rails_templatable_templates` 表
- ✅ 添加：注释说明目标模型需要自己添加 `template_id` 外键

#### app/models/rails_templatable/template.rb
- ❌ 删除：`has_many :assignments` 关联
- ❌ 删除：`assigned_to` 和 `for_model` 辅助方法
- ✅ 保留：基本验证和 enum

#### Concern 变更
```ruby
# 之前 (HasTemplates)
has_many :rails_templatable_assignments, as: :templatable
has_many :templates, through: :rails_templatable_assignments

# 现在 (HasTemplate)
belongs_to :template, class_name: "RailsTemplatable::Template", optional: true
```

## 数据库变更

### 之前（需要中间表）

```ruby
# rails_templatable_templates
create_table :rails_templatable_templates do |t|
  t.string :category
  t.text :content
  t.integer :content_format
end

# rails_templatable_assignments (中间表)
create_table :rails_templatable_assignments do |t|
  t.references :template
  t.references :templatable, polymorphic: true
end
```

### 现在（直接外键）

```ruby
# rails_templatable_templates (同上)
create_table :rails_templatable_templates do |t|
  t.string :category
  t.text :content
  t.integer :content_format
end

# 目标模型表（如 posts）
add_reference :posts, :template,
              foreign_key: { to_table: :rails_templatable_templates }
```

## API 变更

### 创建记录

```ruby
# 之前
post = Post.create(title: "New post")
post.templates << template_a
post.templates << template_b  # 可以添加多个

# 现在
post = Post.create(title: "New post", template: template_a)
post.update(template: template_b)  # 只能有一个，会替换
```

### 查询模板

```ruby
# 之前
post.templates  # 返回 Collection
post.templates.where(category: "feature_request")

# 现在
post.template  # 返回单个 Template 或 nil
```

### 查询使用某个模板的记录

```ruby
# 之前
template.assigned_to(Post)

# 现在
Post.where(template: template)
```

### 移除模板

```ruby
# 之前
post.templates.delete(template)
post.templates.clear

# 现在
post.update(template: nil)
```

## 测试变更

### 新测试覆盖

1. ✅ 创建 5 种预定义模板分类
2. ✅ 一个记录只能有一个模板
3. ✅ 一个模板可被多个记录使用
4. ✅ 更换模板功能
5. ✅ 移除模板功能
6. ✅ 按分类查询
7. ✅ 按内容格式查询
8. ✅ 创建时不指定模板
9. ✅ 之后添加模板

### 测试结果

```
📊 Summary:
  - Created 5 templates
  - Created 6 posts
  - Created 3 work logs
  - 1:N relationship verified: one record → one template
  - 1:N relationship verified: one template → many records
```

## 模板分类

系统预定义的 5 种模板分类：

| 分类 | 说明 | 示例用途 |
|------|------|----------|
| `feature_request` | 功能需求 | 新功能开发 |
| `bug_report` | Bug 修复 | 问题报告 |
| `tech_improvement` | 技术改进 | 重构优化 |
| `meeting_note` | 会议纪要 | 会议记录 |
| `api_design` | API 设计 | 接口设计 |

## 优势

1. **更简单** - 无需中间表，直接外键关联
2. **更清晰** - 一个记录一个模板，语义明确
3. **更高效** - 减少 JOIN 操作，查询更快
4. **易维护** - 数据库结构更简洁
5. **符合需求** - 实际使用场景中，一个文档通常只需要一个模板

## 迁移指南

如果你已经使用了旧版本的 N:N 设计，需要迁移到 1:N：

### 1. 数据迁移

```ruby
# 将现有的多模板关系转换为单模板
# 策略：保留第一个模板，删除其他的

Post.find_each do |post|
  first_template = post.templates.first
  post.update(template: first_template) if first_template
end
```

### 2. 删除旧表

```ruby
# 迁移完成后删除中间表
drop_table :rails_templatable_assignments
```

### 3. 更新代码

- 将 `include RailsTemplatable::HasTemplates` 改为 `include RailsTemplatable::HasTemplate`
- 将 `post.templates` 改为 `post.template`
- 移除所有 `post.templates <<` 操作

## 文档更新

已更新的文档：

1. ✅ `docs/01-design.md` - 设计文档
2. ✅ `docs/02-usage.md` - 使用指南
3. ✅ `README.md` - 项目说明
4. ✅ `test/dummy/test_templatable.rb` - 测试脚本

## 总结

这次重构将 rails_templatable 从复杂的 N:N 关系简化为更符合实际需求的 1:N 关系：

- ✅ 删除了不必要的中间表
- ✅ 简化了模型关联
- ✅ 提升了查询效率
- ✅ 保持了灵活性（模板可复用）
- ✅ 增强了数据完整性（一个记录一个模板）

所有测试通过，可以投入使用！
