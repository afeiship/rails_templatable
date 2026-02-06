# RailsTemplatable

A lightweight Rails Engine that enables any ActiveRecord model to associate with templates for content management. Built with a polymorphic many-to-many relationship, allowing any model to have multiple templates.

## Features

- 🎯 **Polymorphic Associations** - Attach templates to any ActiveRecord model
- 📝 **Multiple Content Formats** - Support for HTML, Markdown, and plain text
- 🔗 **Many-to-Many Relationship** - Models can have multiple templates, templates can be used by multiple models
- 🏷️ **Flexible Categories** - User-defined template categories (no hardcoded types)
- 🔒 **Database Constraints** - Unique constraints at database level
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

## Quick Start

### 1. Enable templates in your models

```ruby
class Post < ApplicationRecord
  include RailsTemplatable::HasTemplates
end

class WorkLog < ApplicationRecord
  include RailsTemplatable::HasTemplates
end
```

### 2. Create templates

```ruby
# HTML template
email_template = RailsTemplatable::Template.create!(
  category: "email_template",
  content: "<h1>Welcome!</h1><p>Hello {{name}}</p>",
  content_format: :html
)

# Markdown template
doc_template = RailsTemplatable::Template.create!(
  category: "documentation",
  content: "# Documentation\n\nThis is a **markdown** template.",
  content_format: :markdown
)
```

### 3. Associate templates with models

```ruby
post = Post.create(title: "My Post", content: "Content here")

# Add templates
post.templates << email_template
post.templates << doc_template

# Query templates
post.templates.where(category: "email_template")
```

## Content Formats

The engine supports three content formats out of the box:

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

## Database Schema

### rails_templatable_templates

| Column | Type | Description |
|--------|------|-------------|
| `category` | string | Template category (user-defined) |
| `content` | text | Template content |
| `content_format` | integer | Content format (0: html, 1: markdown, 2: txt) |
| `created_at` | datetime | Creation timestamp |
| `updated_at` | datetime | Update timestamp |

### rails_templatable_assignments

| Column | Type | Description |
|--------|------|-------------|
| `template_id` | integer | Foreign key to template |
| `templatable_id` | integer | Polymorphic foreign key ID |
| `templatable_type` | string | Polymorphic foreign key type |
| `created_at` | datetime | Creation timestamp |
| `updated_at` | datetime | Update timestamp |

## Advanced Usage

### Query helper methods

```ruby
# Get all objects using a specific template
template.assigned_to(Post)

# Get all templates used on a specific model class
RailsTemplatable::Template.for_model(Post)
```

### Checking template associations

```ruby
# Check if a post has email templates
post.templates.where(category: "email_template").exists?

# Get all HTML format templates
post.templates.html
```

## Why `category` instead of `type`?

We use `category` instead of `type` to avoid conflicts with Rails' Single Table Inheritance (STI) feature, which reserves the `type` column for storing class names.

## Development

### Running tests in the dummy app

```bash
cd test/dummy
ruby test_templatable.rb
```

### Database schema

After running migrations, your schema will include:

```ruby
create_table "rails_templatable_templates" do |t|
  t.string "category", null: false
  t.text "content"
  t.integer "content_format", default: 2, null: false
  t.index ["category"], name: "index_rails_templatable_templates_on_category"
end

create_table "rails_templatable_assignments" do |t|
  t.integer "template_id", null: false
  t.string "templatable_type", null: false
  t.integer "templatable_id", null: false
  t.index ["template_id", "templatable_type", "templatable_id"],
          name: "index_templatable_assignments", unique: true
end
```

## Architecture

This engine follows the same pattern as [rails_badgeable](https://github.com/afeiship/rails_badgeable):

- **Isolated namespace** - All models namespaced under `RailsTemplatable`
- **Polymorphic associations** - Using `templatable` for flexible model associations
- **Concern-based inclusion** - Simple `include RailsTemplatable::HasTemplates` to enable
- **Database-level constraints** - Unique indexes prevent duplicate associations

## Comparison with rails_badgeable

| Feature | rails_badgeable | rails_templatable |
|---------|-----------------|-------------------|
| Main Model | Badge | Template |
| Fields | name, description | category, content, content_format |
| Enum Support | No | Yes (content_format) |
| Polymorphic Name | assignable | templatable |
| Concern | HasBadges | HasTemplates |

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
