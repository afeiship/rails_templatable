#!/usr/bin/env ruby
# Test script for rails_templatable

require_relative "config/environment"

puts "🚀 Testing Rails Templatable Engine"
puts "=" * 50

# Clean up existing data
RailsTemplatable::Template.destroy_all
RailsTemplatable::TemplateAssignment.destroy_all
Post.destroy_all
WorkLog.destroy_all

# 1. Create templates
puts "\n📝 Creating templates..."
email_template = RailsTemplatable::Template.create!(
  category: "email_template",
  content: "<h1>Welcome!</h1><p>Hello {{name}}</p>",
  content_format: :html
)
puts "✓ Created HTML email template"

markdown_template = RailsTemplatable::Template.create!(
  category: "documentation",
  content: "# Documentation\n\nThis is a **markdown** template.",
  content_format: :markdown
)
puts "✓ Created Markdown documentation template"

txt_template = RailsTemplatable::Template.create!(
  category: "notification",
  content: "Simple text notification",
  content_format: :txt
)
puts "✓ Created text notification template"

# 2. Create posts and work_logs
puts "\n📄 Creating Posts and WorkLogs..."
post1 = Post.create!(title: "First Post", content: "Content 1")
post2 = Post.create!(title: "Second Post", content: "Content 2")
work_log1 = WorkLog.create!(title: "Daily Log", body: "Work completed")
work_log2 = WorkLog.create!(title: "Weekly Log", body: "Weekly summary")
puts "✓ Created 2 Posts and 2 WorkLogs"

# 3. Associate templates with models
puts "\n🔗 Associating templates with models..."
post1.templates << email_template
post1.templates << markdown_template
post2.templates << txt_template
work_log1.templates << email_template
work_log2.templates << markdown_template
puts "✓ Templates associated successfully"

# 4. Test queries
puts "\n🔍 Testing queries..."
puts "  Post1 has #{post1.templates.count} templates"
puts "  Post1 templates: #{post1.templates.pluck(:category).join(', ')}"

puts "  Post2 has #{post2.templates.count} templates"
puts "  Post2 templates: #{post2.templates.pluck(:category).join(', ')}"

puts "  WorkLog1 has #{work_log1.templates.count} templates"
puts "  WorkLog1 templates: #{work_log1.templates.pluck(:category).join(', ')}"

# 5. Test category filtering
puts "\n📂 Testing category filtering..."
email_templates = post1.templates.where(category: "email_template")
puts "  Post1 email templates: #{email_templates.count}"

# 6. Test assigned_to method
puts "\n🎯 Testing Template#assigned_to..."
posts_with_email = email_template.assigned_to(Post)
puts "  Posts with email template: #{posts_with_email.count}"
puts "  Post titles: #{posts_with_email.pluck(:title).join(', ')}"

# 7. Test Template.for_model
puts "\n📊 Testing Template.for_model..."
post_templates = RailsTemplatable::Template.for_model(Post)
puts "  Templates used on Posts: #{post_templates.count}"
puts "  Template categories: #{post_templates.pluck(:category).uniq.join(', ')}"

# 8. Test uniqueness constraint
puts "\n🔒 Testing uniqueness constraint..."
begin
  RailsTemplatable::TemplateAssignment.create!(
    template: email_template,
    templatable: post1
  )
  puts "✗ Failed - should not allow duplicate"
rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
  puts "✓ Uniqueness constraint works correctly"
end

puts "\n" + "=" * 50
puts "✅ All tests passed successfully!"
puts "=" * 50
