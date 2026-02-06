# Rails Templatable 使用指南

## 安装

在 Gemfile 中添加：

```ruby
gem 'rails_templatable'
```

然后执行：

```bash
bundle install
bin/rails railties:install:migrations FROM=rails_templatable
bin/rails db:migrate
```

为需要使用模板的模型添加外键：

```ruby
# 在迁移中为每个模型添加
add_reference :posts, :template,
              foreign_key: { to_table: :rails_templatable_templates },
              index: false
```

## 快速开始

### 1. 在模型中启用模板功能

```ruby
class Post < ApplicationRecord
  include RailsTemplatable::HasTemplate
end

class WorkLog < ApplicationRecord
  include RailsTemplatable::HasTemplate
end
```

### 2. 创建模板

支持的模板分类（示例）：

```ruby
# 功能需求模板
feature_template = RailsTemplatable::Template.create!(
  category: "feature_request",
  content: "# Feature Request\n\n## Description\n\n## Acceptance Criteria",
  content_format: :markdown
)

# Bug 报告模板
bug_template = RailsTemplatable::Template.create!(
  category: "bug_report",
  content: "## Bug Description\n\n## Steps to Reproduce\n\n## Expected Behavior",
  content_format: :markdown
)

# 技术改进模板
tech_template = RailsTemplatable::Template.create!(
  category: "tech_improvement",
  content: "## Current State\n\n## Proposed Improvement\n\n## Benefits",
  content_format: :markdown
)

# 会议纪要模板
meeting_template = RailsTemplatable::Template.create!(
  category: "meeting_note",
  content: "# Meeting: {title}\n\nDate: {date}\n\n## Attendees\n\n## Agenda",
  content_format: :markdown
)

# API 设计模板
api_template = RailsTemplatable::Template.create!(
  category: "api_design",
  content: "## Endpoint\n\n## Request\n\n## Response",
  content_format: :markdown
)
```

### 3. 为模型实例分配模板

```ruby
# 创建时指定模板
post = Post.create!(
  title: "Add user authentication",
  content: "Implement OAuth2 login",
  template: feature_template
)

# 之后分配模板
work_log = WorkLog.create!(title: "Daily standup")
work_log.update(template: meeting_template)

# 查看模板
post.template.category  # => "feature_request"
post.template.content   # => "# Feature Request..."
```

### 4. 更改模板

```ruby
# 一个实例只能有一个模板，分配新模板会替换旧的
post.update(template: bug_template)
post.template.category  # => "bug_report"
```

### 5. 移除模板

```ruby
post.update(template: nil)
post.template  # => nil
```

## 模板分类

系统中常用的模板分类：

| 分类 | 说明 |
|------|------|
| `feature_request` | 功能需求 |
| `bug_report` | Bug 修复 |
| `tech_improvement` | 技术改进 |
| `meeting_note` | 会议纪要 |
| `api_design` | API 设计 |

用户可以自定义任意分类。

## 查询模板

```ruby
# 获取实例的模板
post.template

# 按分类查询
Post.joins(:template).where(rails_templatable_templates: { category: 'feature_request' })

# 获取使用某个模板的所有实例
Post.where(template: feature_template)

# 按内容格式查询
Post.joins(:template).where(rails_templatable_templates: { content_format: 1 })
```

## Content Format 枚举

```ruby
enum content_format: {
  html: 0,      # HTML 格式
  markdown: 1,  # Markdown 格式
  txt: 2        # 纯文本格式（默认）
}
```

## 关系说明

**1:N 关系**
- 一个 Post/WorkLog 实例 **只能有一个** 模板
- 一个 Template 可以被 **多个** 实例使用

示例：
```
Post 1 → Template A (feature_request)
Post 2 → Template B (bug_report)
Post 3 → Template A (feature_request)  # 多个实例可使用同一模板
```

## 数据库 Schema

### rails_templatable_templates

| 字段 | 类型 | 说明 |
|------|------|------|
| id | integer | 主键 |
| category | string | 模板分类（用户自定义） |
| content | text | 模板内容 |
| content_format | integer | 内容格式 (0: html, 1: markdown, 2: txt) |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |

### 目标模型（如 posts）

需要添加 `template_id` 外键：

| 字段 | 类型 | 说明 |
|------|------|------|
| template_id | integer | 外键，关联到 rails_templatable_templates |

## 迁移示例

```ruby
# 为已有模型添加模板支持
class AddTemplateToPosts < ActiveRecord::Migration[6.0]
  def change
    add_reference :posts, :template,
                  foreign_key: { to_table: :rails_templatable_templates },
                  index: false
  end
end
```

## 验证规则

- `category` - 必填
- `content` - 必填
- `content_format` - 必填，默认值为 `txt`
- 模板关联是可选的（optional: true）

## 测试

运行测试脚本：

```bash
cd test/dummy
ruby test_templatable.rb
```

## 架构设计

- **直接外键关联** - 无需中间表
- **简单高效** - 一个实例只能有一个模板
- **灵活扩展** - 模板可随时更改

## 与 N:N 设计的区别

如果需要"一个实例有多个模板"，应该使用标签系统或多态关联，而非此引擎。
