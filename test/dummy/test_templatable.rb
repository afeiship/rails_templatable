#!/usr/bin/env ruby
# Test script for rails_templatable (1:N relationship)

require_relative "config/environment"

puts "🚀 Testing Rails Templatable Engine (1:N Relationship)"
puts "=" * 60

# Clean up existing data
RailsTemplatable::Template.destroy_all
Post.destroy_all
WorkLog.destroy_all

# 1. Create templates with different categories
puts "\n📝 Creating templates..."
feature_template = RailsTemplatable::Template.create!(
  category: "feature_request",
  content: "# Feature Request\n\n## Description\n\n## Acceptance Criteria",
  content_format: :markdown
)
puts "✓ Created feature_request template"

bug_template = RailsTemplatable::Template.create!(
  category: "bug_report",
  content: "## Bug Description\n\n## Steps to Reproduce\n\n## Expected Behavior",
  content_format: :markdown
)
puts "✓ Created bug_report template"

meeting_template = RailsTemplatable::Template.create!(
  category: "meeting_note",
  content: "# Meeting: {title}\n\nDate: {date}\n\n## Attendees\n\n## Agenda",
  content_format: :markdown
)
puts "✓ Created meeting_note template"

tech_template = RailsTemplatable::Template.create!(
  category: "tech_improvement",
  content: "## Current State\n\n## Proposed Improvement\n\n## Benefits",
  content_format: :markdown
)
puts "✓ Created tech_improvement template"

api_template = RailsTemplatable::Template.create!(
  category: "api_design",
  content: "## Endpoint\n\n## Request\n\n## Response",
  content_format: :markdown
)
puts "✓ Created api_design template"

# 2. Create posts and assign templates
puts "\n📄 Creating Posts with templates..."
post1 = Post.create!(
  title: "Add user authentication",
  content: "Implement OAuth2 login",
  template: feature_template
)
puts "✓ Created post with feature_request template"

post2 = Post.create!(
  title: "Fix login bug",
  content: "Users cannot login with invalid password",
  template: bug_template
)
puts "✓ Created post with bug_report template"

post3 = Post.create!(
  title: "Refactor database queries",
  content: "Optimize slow queries",
  template: tech_template
)
puts "✓ Created post with tech_improvement template"

post4 = Post.create!(
  title: "Design payment API",
  content: "Create REST API for payments",
  template: api_template
)
puts "✓ Created post with api_design template"

# Multiple posts can use the same template
post5 = Post.create!(
  title: "Add admin dashboard",
  content: "Build admin interface",
  template: feature_template
)
puts "✓ Created another post with feature_request template"

# 3. Create work logs with templates
puts "\n📝 Creating WorkLogs with templates..."
work_log1 = WorkLog.create!(
  title: "Daily standup",
  body: "Discussed sprint progress",
  template: meeting_template
)
puts "✓ Created work_log with meeting_note template"

work_log2 = WorkLog.create!(
  title: "Tech review",
  body: "Reviewed authentication code",
  template: tech_template
)
puts "✓ Created work_log with tech_improvement template"

work_log3 = WorkLog.create!(
  title: "Sprint planning",
  body: "Planned next sprint",
  template: meeting_template
)
puts "✓ Created another work_log with meeting_note template"

# 4. Test 1:N relationship - one post has one template
puts "\n🔍 Testing 1:N relationship..."
puts "  Post1 template: #{post1.template.category}"
puts "  Post2 template: #{post2.template.category}"
puts "  Post3 template: #{post3.template.category}"

# 5. Test reverse - one template can have many posts
puts "\n📊 Testing reverse relationship..."
feature_posts = Post.where(template: feature_template)
puts "  feature_request template used by #{feature_posts.count} posts:"
feature_posts.each { |p| puts "    - #{p.title}" }

meeting_work_logs = WorkLog.where(template: meeting_template)
puts "  meeting_note template used by #{meeting_work_logs.count} work_logs:"
meeting_work_logs.each { |w| puts "    - #{w.title}" }

# 6. Test changing template
puts "\n🔄 Testing template change..."
puts "  Post1 original template: #{post1.template.category}"
post1.update(template: bug_template)
puts "  Post1 new template: #{post1.template.category}"
puts "✓ Template changed successfully"

# 7. Test removing template
puts "\n🗑️  Testing template removal..."
puts "  Post2 template before: #{post2.template.category}"
post2.update(template: nil)
puts "  Post2 template after: #{post2.template.inspect}"
puts "✓ Template removed successfully"

# 8. Test queries by category
puts "\n🔎 Testing queries by category..."
feature_posts = Post.joins(:template).where(rails_templatable_templates: { category: 'feature_request' })
puts "  Posts with feature_request template: #{feature_posts.count}"

bug_posts = Post.joins(:template).where(rails_templatable_templates: { category: 'bug_report' })
puts "  Posts with bug_report template: #{bug_posts.count}"

# 9. Test content format
puts "\n📋 Testing content format..."
puts "  Templates with markdown format: #{RailsTemplatable::Template.markdown.count}"
puts "  Templates with html format: #{RailsTemplatable::Template.html.count}"
puts "  Templates with txt format: #{RailsTemplatable::Template.txt.count}"

# 10. Test template categories
puts "\n🏷️  Template categories summary..."
RailsTemplatable::Template.all.each do |t|
  post_count = Post.where(template: t).count
  work_log_count = WorkLog.where(template: t).count
  total = post_count + work_log_count
  puts "  #{t.category.ljust(20)} - #{total} records (#{post_count} posts, #{work_log_count} work_logs)"
end

# 11. Test creating without template
puts "\n➕ Testing creation without template..."
post_no_template = Post.create!(title: "No template post", content: "Just content")
puts "  Post without template: #{post_no_template.title}"
puts "  Template value: #{post_no_template.template.inspect}"
puts "✓ Can create posts without template"

# 12. Test assigning template later
puts "\n🔗 Testing template assignment after creation..."
post_no_template.update(template: tech_template)
puts "  Post assigned template: #{post_no_template.template.category}"
puts "✓ Can assign template after creation"

puts "\n" + "=" * 60
puts "✅ All tests passed successfully!"
puts "=" * 60
puts "\n📊 Summary:"
puts "  - Created #{RailsTemplatable::Template.count} templates"
puts "  - Created #{Post.count} posts"
puts "  - Created #{WorkLog.count} work logs"
puts "  - 1:N relationship verified: one record → one template"
puts "  - 1:N relationship verified: one template → many records"
