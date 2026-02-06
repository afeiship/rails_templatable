# RailsTemplatable

A lightweight Rails Engine that enables any ActiveRecord model to use predefined templates for content management. Built with a simple one-to-many relationship, allowing each model instance to have one template while templates can be reused across multiple instances.

## Features

- 🎯 **Simple 1:N Relationship** - Each record has one template, templates can be reused
- 📝 **Multiple Content Formats** - Support for HTML, Markdown, and plain text
- 🏷️ **Flexible Categories** - Pre-defined categories (feature_request, bug_report, etc.) or custom
- 🔗 **Direct Foreign Key** - No join table needed, cleaner database schema
- 🚀 **Easy Integration** - Simple concern-based inclusion

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rails_templatable"
```

And then execute:
```bash
$ bundle install
$ bin/rails railties:install:migrations FROM=rails_templatable
$ bin/rails db:migrate
```

For each model that will use templates, add a foreign key:

```ruby
add_reference :posts, :template,
              foreign_key: { to_table: :rails_templatable_templates },
              index: false
```

## Quick Start

### 1. Enable templates in your models

```ruby
class Post < ApplicationRecord
  include RailsTemplatable::HasTemplate
end

class WorkLog < ApplicationRecord
  include RailsTemplatable::HasTemplate
end
```

### 2. Create templates

```ruby
# Feature request template
feature_template = RailsTemplatable::Template.create!(
  category: "feature_request",
  content: "# Feature Request\n\n## Description\n\n## Acceptance Criteria",
  content_format: :markdown
)

# Bug report template
bug_template = RailsTemplatable::Template.create!(
  category: "bug_report",
  content: "## Bug Description\n\n## Steps to Reproduce\n\n## Expected Behavior",
  content_format: :markdown
)
```

### 3. Assign templates to records

```ruby
post = Post.create!(
  title: "Add user authentication",
  content: "Implement OAuth2 login",
  template: feature_template
)

# View template
post.template.category  # => "feature_request"
post.template.content   # => "# Feature Request..."
```

## Template Categories

Common template categories included:

| Category | Description |
|----------|-------------|
| `feature_request` | Feature requests |
| `bug_report` | Bug reports |
| `tech_improvement` | Technical improvements |
| `meeting_note` | Meeting notes |
| `api_design` | API designs |

You can create any custom category as needed.

## Relationship Model

**One-to-Many (1:N)**
- One Post/WorkLog instance → One Template
- One Template → Many instances

Example:
```
Post 1 → Template A (feature_request)
Post 2 → Template B (bug_report)
Post 3 → Template A (feature_request)  # Reusable
```

## Content Formats

Three content formats are supported:

- `html` (0) - HTML content
- `markdown` (1) - Markdown content
- `txt` (2) - Plain text content (default)

```ruby
RailsTemplatable::Template.create!(
  category: "notification",
  content: "Simple text notification",
  content_format: :txt
)
```

## Query Examples

```ruby
# Get a record's template
post.template

# Query by category
Post.joins(:template).where(rails_templatable_templates: { category: 'feature_request' })

# Get all records using a specific template
Post.where(template: feature_template)

# Query by content format
Post.joins(:template).where(rails_templatable_templates: { content_format: 1 })
```

## Database Schema

### rails_templatable_templates

| Column | Type | Description |
|--------|------|-------------|
| `category` | string | Template category (user-defined) |
| `content` | text | Template content |
| `content_format` | integer | Content format (0: html, 1: markdown, 2: txt) |
| `created_at` | datetime | Creation timestamp |
| `updated_at` | datetime | Update timestamp |

### Target models (e.g., posts)

Add `template_id` foreign key:

| Column | Type | Description |
|--------|------|-------------|
| `template_id` | integer | Foreign key to rails_templatable_templates |

## Advanced Usage

### Change template

```ruby
# Assigning a new template replaces the old one
post.update(template: bug_template)
post.template.category  # => "bug_report"
```

### Remove template

```ruby
post.update(template: nil)
post.template  # => nil
```

### Assign template after creation

```ruby
post = Post.create(title: "New post")
post.update(template: feature_template)
```

## Migration Example

```ruby
class AddTemplateToPosts < ActiveRecord::Migration[6.0]
  def change
    add_reference :posts, :template,
                  foreign_key: { to_table: :rails_templatable_templates },
                  index: false
  end
end
```

## Development

### Running tests in the dummy app

```bash
cd test/dummy
ruby test_templatable.rb
```

## Architecture

- **Direct Foreign Key** - No join table needed
- **Simple & Clean** - One record = One template
- **Flexible** - Templates can be changed anytime
- **Efficient Queries** - Direct JOIN without intermediate table

## Comparison with N:N Design

If you need "one record has multiple templates", consider using a tag system or polymorphic many-to-many associations instead.

## Why `category` instead of `type`?

We use `category` instead of `type` to avoid conflicts with Rails' Single Table Inheritance (STI) feature, which reserves the `type` column for storing class names.

## Future Enhancements

- Template variable interpolation
- Template versioning
- Template inheritance
- Template preview functionality
- I18n multi-language support

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Built with inspiration from [rails_badgeable](https://github.com/afeiship/rails_badgeable).
