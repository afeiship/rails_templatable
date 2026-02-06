# Rails Templatable 设计文档

## 项目概述
创建一个 Rails engine，允许任何 ActiveRecord 模型使用预定义的模板。

**核心关系：一个模型实例对应一个模板，一个模板可被多个模型实例使用。**

## 核心功能

### 1. Template 模型
存储模板的基本信息，包含以下字段：

- **category** (string) - 模板分类，用户自定义字符串
  - 例如：feature_request, bug_report, tech_improvement, meeting_note, api_design 等
  - 不做枚举限制，完全由用户自定义
  - 注意：使用 `category` 而非 `type`，避免与 Rails STI 保留字冲突

- **content** (text) - 模板内容
  - 存储静态内容，不做变量替换

- **content_format** (enum) - 内容格式
  - 支持三种格式：`html`, `markdown`, `txt`
  - 使用 Rails enum 实现，方便未来扩展
  - 默认值：`txt`

### 2. 一对多关系 (1:N)
- 一个 Post/WorkLog 等模型实例 **只能有一个** 模板
- 一个 Template 模板可以 **被多个** 模型实例使用
- 使用直接外键关联，无需中间表

## 模板分类预设

系统中常用的模板分类：

| 分类 | 说明 |
|------|------|
| `feature_request` | 功能需求 |
| `bug_report` | Bug 修复 |
| `tech_improvement` | 技术改进 |
| `meeting_note` | 会议纪要 |
| `api_design` | API 设计 |

用户可以自定义任意分类，不限于以上预设。

## 架构设计

参考 rails_badgeable 的实现模式，但简化为一对多关系：

### 数据库表结构

#### rails_templatable_templates
```ruby
t.string :category, null: false    # 模板分类（避免使用 type 保留字）
t.text :content                    # 模板内容
t.integer :content_format, null: false, default: 2 # 内容格式枚举 (0: html, 1: markdown, 2: txt)
t.timestamps
```

索引：
- `category` 字段添加索引（便于按分类查询）

#### 目标模型（如 posts, work_logs）
在目标模型表上添加外键：
```ruby
t.references :template, foreign_key: { to_table: :rails_templatable_templates }, index: false
```

**注意：不需要中间表 `rails_templatable_assignments`**

### 模型关联

#### RailsTemplatable::Template
```ruby
class RailsTemplatable::Template < ApplicationRecord
  self.table_name = "rails_templatable_templates"

  # 一个模板可以被多个模型实例使用
  has_many :posts, class_name: "Post", foreign_key: :template_id, optional: true
  has_many :work_logs, class_name: "WorkLog", foreign_key: :template_id, optional: true
  # ... 其他模型

  enum :content_format, { html: 0, markdown: 1, txt: 2 }

  validates :category, presence: true
  validates :content, presence: true
  validates :content_format, presence: true
end
```

#### RailsTemplatable::HasTemplate (Concern)
```ruby
module RailsTemplatable
  module HasTemplate
    extend ActiveSupport::Concern

    included do
      # 每个模型实例只能有一个模板
      belongs_to :template,
                 class_name: "RailsTemplatable::Template",
                 optional: true
    end
  end
end
```

## 使用示例

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
```ruby
# 创建功能需求模板
feature_template = RailsTemplatable::Template.create!(
  category: "feature_request",
  content: "# Feature Request\n\n## Description\n\n## Acceptance Criteria",
  content_format: :markdown
)

# 创建 Bug 报告模板
bug_template = RailsTemplatable::Template.create!(
  category: "bug_report",
  content: "## Bug Description\n\n## Steps to Reproduce\n\n## Expected Behavior",
  content_format: :markdown
)

# 创建会议纪要模板
meeting_template = RailsTemplatable::Template.create!(
  category: "meeting_note",
  content: "# Meeting: {title}\n\nDate: {date}\n\n## Attendees\n\n## Agenda\n\n## Action Items",
  content_format: :markdown
)
```

### 3. 为模型实例分配模板
```ruby
# 创建文章并分配模板
post = Post.create(
  title: "Add user authentication",
  template: feature_template  # 直接指定模板
)

# 或者之后分配
work_log = WorkLog.create(title: "Daily standup")
work_log.update(template: meeting_template)

# 检查文章使用的模板
post.template  # => #<RailsTemplatable::Template category: "feature_request">
post.template.category  # => "feature_request"
post.template.content  # => "# Feature Request..."
```

### 4. 查询使用某个模板的所有记录
```ruby
# 获取所有使用功能需求模板的文章
feature_template.posts  # => [#<Post id: 1>, #<Post id: 3>]

# 获取所有使用会议纪要模板的工作日志
meeting_template.work_logs  # => [#<WorkLog id: 1>, #<WorkLog id: 2>]
```

### 5. 按模板分类查询
```ruby
# 获取所有功能需求类型的文章
Post.joins(:template).where(rails_templatable_templates: { category: 'feature_request' })

# 获取所有使用 Markdown 格式模板的工作日志
WorkLog.joins(:template).where(rails_templatable_templates: { content_format: 1 })
```

### 6. 更改模板
```ruby
# 一篇文章只能有一个模板，分配新模板会替换旧的
post.update(template: bug_template)
post.template.category  # => "bug_report"
```

### 7. 移除模板
```ruby
# 移除模板关联
post.update(template: nil)
post.template  # => nil
```

## 命名约定

- **引擎名**：`rails_templatable`
- **表名前缀**：`rails_templatable_`
- **主模块**：`RailsTemplatable`
- **Concern 名**：`HasTemplate`（单数，因为只有一个模板）
- **外键名**：`template_id`（在目标模型表上）

## 与 rails_badgeable 的主要区别

| 特性 | rails_badgeable | rails_templatable |
|------|-----------------|-------------------|
| 主模型 | Badge | Template |
| 关系类型 | N:N（多对多） | 1:N（一对多） |
| 中间表 | badge_assignments | 无（直接外键） |
| 模型关联 | has_many :badges | belongs_to :template |
| 字段 | name, description | category, content, content_format |
| 枚举 | 无 | content_format (html/markdown/txt) |
| Concern | HasBadges | HasTemplate |

## 数据库示例

### rails_templatable_templates 表
| id | category | content_format | content | created_at |
|----|----------|----------------|---------|------------|
| 1 | feature_request | 1 | # Feature Request\n\n... | 2024-01-01 |
| 2 | bug_report | 1 | ## Bug Description\n\n... | 2024-01-01 |
| 3 | meeting_note | 1 | # Meeting: {title}\n\n... | 2024-01-01 |

### posts 表（示例）
| id | title | template_id | created_at |
|----|-------|-------------|------------|
| 1 | Add auth | 1 | 2024-01-02 |
| 2 | Fix bug | 2 | 2024-01-02 |
| 3 | New feature | 1 | 2024-01-03 |

**说明：**
- Post 1 使用 template_id = 1 (feature_request)
- Post 2 使用 template_id = 2 (bug_report)
- Post 3 使用 template_id = 1 (feature_request) - 多个 Post 可以使用同一个 Template

## 迁移示例

为已有模型添加模板支持：

```ruby
# 为 posts 表添加模板外键
class AddTemplateToPosts < ActiveRecord::Migration[6.0]
  def change
    add_reference :posts, :template,
                  foreign_key: { to_table: :rails_templatable_templates },
                  index: false
  end
end

# 为 work_logs 表添加模板外键
class AddTemplateToWorkLogs < ActiveRecord::Migration[6.0]
  def change
    add_reference :work_logs, :template,
                  foreign_key: { to_table: :rails_templatable_templates },
                  index: false
  end
end
```

## 优势

1. **简单直接** - 无需中间表，直接外键关联
2. **数据完整性** - 一个实例只能有一个模板，避免歧义
3. **查询高效** - 直接 JOIN，无需通过中间表
4. **易于理解** - 语义清晰："这篇文章使用哪个模板"
5. **灵活扩展** - 模板可以随时更改

## 限制

1. **一个实例只能有一个模板** - 如果需要多个模板，应使用多态关联或标签系统
2. **需要手动添加外键** - 每个需要模板的模型都要添加 template_id 列

## 未来扩展

1. **模板变量支持** - 目前仅存储静态内容，未来可添加变量替换功能
2. **模板版本** - 支持模板的版本管理
3. **模板继承** - 支持模板的继承和覆盖
4. **模板预览** - 提供模板预览功能
5. **I18n 支持** - 多语言模板
6. **模板验证** - 根据模板结构验证内容完整性
