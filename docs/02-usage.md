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

## 快速开始

### 1. 在模型中启用模板功能

```ruby
class Post < ApplicationRecord
  include RailsTemplatable::HasTemplates
end

class WorkLog < ApplicationRecord
  include RailsTemplatable::HasTemplates
end
```

### 2. 创建模板

```ruby
# HTML 模板
email_template = RailsTemplatable::Template.create!(
  category: "email_template",
  content: "<h1>Welcome!</h1><p>Hello {{name}}</p>",
  content_format: :html
)

# Markdown 模板
doc_template = RailsTemplatable::Template.create!(
  category: "documentation",
  content: "# Documentation\n\nThis is a **markdown** template.",
  content_format: :markdown
)

# 纯文本模板
notification_template = RailsTemplatable::Template.create!(
  category: "notification",
  content: "Simple text notification",
  content_format: :txt
)
```

### 3. 关联模板到模型

```ruby
post = Post.create(title: "My Post", content: "Post content")

# 方式 1: 通过关联添加
post.templates << email_template
post.templates << doc_template

# 方式 2: 通过 assignment 创建
RailsTemplatable::TemplateAssignment.create!(
  template: email_template,
  templatable: post
)
```

### 4. 查询模板

```ruby
# 获取对象的所有模板
post.templates

# 获取特定分类的模板
post.templates.where(category: "email_template")

# 检查是否有特定类型的模板
post.templates.where(category: "email_template").exists?

# 获取使用某个模板的所有对象
template.assigned_to(Post)

# 获取在特定模型上使用过的所有模板
RailsTemplatable::Template.for_model(Post)
```

## 数据库字段

### rails_templatable_templates

| 字段 | 类型 | 说明 |
|------|------|------|
| id | integer | 主键 |
| category | string | 模板分类（用户自定义） |
| content | text | 模板内容 |
| content_format | integer | 内容格式 (0: html, 1: markdown, 2: txt) |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |

### rails_templatable_assignments

| 字段 | 类型 | 说明 |
|------|------|------|
| id | integer | 主键 |
| template_id | integer | 关联的模板 ID（外键） |
| templatable_id | integer | 关联对象的 ID（多态） |
| templatable_type | string | 关联对象的类型（多态） |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |

## Content Format 枚举

```ruby
enum content_format: {
  html: 0,      # HTML 格式
  markdown: 1,  # Markdown 格式
  txt: 2        # 纯文本格式
}
```

## 验证规则

### Template 模型

- `category` - 必填
- `content` - 必填
- `content_format` - 必填，默认值为 `txt`

### TemplateAssignment 模型

- `template` - 必填
- `templatable` - 必填
- 唯一性约束：同一个模板不能重复关联到同一个对象

## 辅助方法

### Template 实例方法

```ruby
# 获取使用此模板的所有指定类型的对象
template.assigned_to(Post)       # 返回使用此模板的所有 Post
template.assigned_to(WorkLog)    # 返回使用此模板的所有 WorkLog
```

### Template 类方法

```ruby
# 获取在特定模型上使用过的所有模板
RailsTemplatable::Template.for_model(Post)
```

## 示例：完整的 Post + Template 工作流

```ruby
# 1. 创建模板
welcome_email = RailsTemplatable::Template.create!(
  category: "welcome_email",
  content: "<h1>Welcome {{username}}!</h1><p>Thanks for joining us.</p>",
  content_format: :html
)

# 2. 创建文章
post = Post.create!(
  title: "Introduction to Rails",
  content: "Rails is a web framework..."
)

# 3. 关联模板
post.templates << welcome_email

# 4. 查询
post.templates.where(category: "welcome_email").count  # => 1
post.templates.html.count                              # => 1

# 5. 获取所有使用 welcome_email 模板的文章
welcome_email.assigned_to(Post)

# 6. 获取所有在 Post 上使用过的模板
RailsTemplatable::Template.for_model(Post)
```

## 测试

在 dummy 应用中运行测试脚本：

```bash
cd test/dummy
ruby test_templatable.rb
```

## 架构设计

- 使用多态关联实现 N:N 关系
- 避免使用 `type` 保留字，改用 `category`
- 数据库级别的唯一性约束
- 参考 rails_badgeable 的设计模式

## 未来扩展

- 模板变量替换
- 模板版本管理
- 模板继承
- 模板预览
- I18n 多语言支持
