require_relative "lib/rails_templatable/version"

Gem::Specification.new do |spec|
  spec.name        = "rails_templatable"
  spec.version     = RailsTemplatable::VERSION
  spec.authors     = [ "aric.zheng" ]
  spec.email       = [ "1290657123@qq.com" ]
  spec.homepage    = "https://github.com/afeiship/rails_templatable"
  spec.summary     = "A Rails engine for template management with 1:N relationship."
  spec.description = "A lightweight Rails Engine that enables any ActiveRecord model to use predefined templates via a simple one-to-many relationship. Each record has one template, templates can be reused across multiple records. Supports HTML, Markdown, and plain text formats with flexible categories."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/afeiship/rails_templatable/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://github.com/afeiship/rails_templatable/blob/main/README.md"
  spec.metadata["ai_assistant_uri"] = "https://github.com/afeiship/rails_templatable/blob/main/llms.txt"

  spec.required_ruby_version = ">= 2.6.0"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "llms.txt"]
  end

  spec.add_dependency "rails", ">= 6.0", "< 9.0"
end
