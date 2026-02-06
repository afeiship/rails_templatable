# Rails Templatable 需求文档

## 项目概述
创建一个 Rails engine，允许任何 ActiveRecord 模型与模板进行多对多关联。

## 核心功能

### 1. Template 模型
存储模板的基本信息，包含以下字段：

- **category** (string) - 模板分类，用户自定义字符串
  - 例如：email_template, page_template, notification_template 等
  - 不做枚举限制，完全由用户自定义
  - 注意：使用 `category` 而非 `type`，避免与 Rails STI 保留字冲突

- **content** (text) - 模板内容
  - 存储静态内容，不做变量替换

- **content_format** (enum) - 内容格式
  - 支持三种格式：`html`, `markdown`, `txt`
  - 使用 Rails enum 实现，方便未来扩展
  - 默认值：`txt`

### 2. 多态关联 (N:N 关系)
模板可以关联任意模型（如 Post, WorkLog, User 等）

- 使用中间表 `rails_templatable_assignments`
- 通过多态关联实现 N:N 关系
- 一个模型可以关联多个模板
- 一个模板可以被多个模型使用

## 架构设计

参考 rails_badgeable 的实现模式：

### 数据库表结构

#### rails_templatable_templates
```ruby
t.string :category, null: false    # 模板分类（避免使用 type 保留字）
t.text :content                    # 模板内容
t.integer :content_format, null: false, default: 2 # 内容格式枚举 (0: html, 1: markdown, 2: txt)
t.timestamps
```

索引：
- `category` 字段添加索引（可选，如果经常按分类查询）

#### rails_templatable_assignments
```ruby
t.references :template, null: false, foreign_key: { to_table: :rails_templatable_templates }
t.references :templatable, polymorphic: true, null: false, index: false
t.timestamps
```

索引：
- 唯一复合索引：`[:template_id, :templatable_type, :templatable_id]`
- 名称：`index_templatable_assignments`

### 模型关联

#### RailsTemplatable::Template
```ruby
class RailsTemplatable::Template < ApplicationRecord
  self.table_name = "rails_templatable_templates"

  has_many :assignments, class_name: "RailsTemplatable::TemplateAssignment", dependent: :destroy
  enum content_format: { html: 0, markdown: 1, txt: 2 }

  validates :category, presence: true
  validates :content, presence: true
  validates :content_format, presence: true
end
```

#### RailsTemplatable::TemplateAssignment
```ruby
class RailsTemplatable::TemplateAssignment < ApplicationRecord
  self.table_name = "rails_templatable_assignments"

  belongs_to :template, class_name: "RailsTemplatable::Template"
  belongs_to :templatable, polymorphic: true

  validates :template, presence: true
  validates :templatable, presence: true
  validates :template_id, uniqueness: { scope: [:templatable_type, :templatable_id] }
end
```

#### RailsTemplatable::HasTemplates (Concern)
```ruby
module RailsTemplatable
  module HasTemplates
    extend ActiveSupport::Concern

    included do
      has_many :rails_templatable_assignments,
               as: :templatable,
               class_name: "RailsTemplatable::TemplateAssignment",
               dependent: :destroy

      has_many :templates,
               through: :rails_templatable_assignments,
               class_name: "RailsTemplatable::Template"
    end
  end
end
```

## 使用示例

### 在模型中启用模板功能
```ruby
class Post < ApplicationRecord
  include RailsTemplatable::HasTemplates
end

class WorkLog < ApplicationRecord
  include RailsTemplatable::HasTemplates
end
```

### 创建模板
```ruby
# 创建 HTML 模板
email_template = RailsTemplatable::Template.create!(
  category: "email_template",
  content: "<h1>Welcome!</h1><p>Hello {{name}}</p>",
  content_format: :html
)

# 创建 Markdown 模板
doc_template = RailsTemplatable::Template.create!(
  category: "documentation",
  content: "# Documentation\n\nThis is a **markdown** template.",
  content_format: :markdown
)
```

### 关联模板到模型
```ruby
post = Post.create(title: "My Post")

# 关联模板
post.templates << email_template
post.templates << doc_template

# 或者通过 assignments 创建
RailsTemplatable::TemplateAssignment.create!(
  template: email_template,
  templatable: post
)
```

### 查询模板
```ruby
# 获取文章的所有模板
post.templates

# 获取特定分类的模板
post.templates.where(category: "email_template")

# 获取使用某个模板的所有文章
template.assigned_to(Post)
```

## 命名约定

- **引擎名**：`rails_templatable`
- **表名前缀**：`rails_templatable_`
- **主模块**：`RailsTemplatable`
- **多态关联名**：`templatable` (对应 badgeable 的 `assignable`)
- **Concern 名**：`HasTemplates` (对应 `HasBadges`)

## 与 rails_badgeable 的主要区别

| 特性 | rails_badgeable | rails_templatable |
|------|-----------------|-------------------|
| 主模型 | Badge | Template |
| 字段 | name, description | category, content, content_format |
| 枚举 | 无 | content_format (html/markdown/txt) |
| 多态名 | assignable | templatable |
| Concern | HasBadges | HasTemplates |

## 未来扩展

1. **模板变量支持** - 目前仅存储静态内容，未来可添加变量替换功能
2. **模板版本** - 支持模板的版本管理
3. **模板继承** - 支持模板的继承和覆盖
4. **模板预览** - 提供模板预览功能
5. **I18n 支持** - 多语言模板
