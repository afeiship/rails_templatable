require_relative "lib/rails_templatable/version"

Gem::Specification.new do |spec|
  spec.name        = "rails_templatable"
  spec.version     = RailsTemplatable::VERSION
  spec.authors     = [ "aric.zheng" ]
  spec.email       = [ "1290657123@qq.com" ]
  spec.homepage    = "https://github.com/afeiship/rails_templatable"
  spec.summary     = "A Rails engine for templatable models."
  spec.description = "A lightweight Rails Engine that enables any ActiveRecord model to use templates for content generation and management."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/afeiship/rails_templatable/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://github.com/afeiship/rails_templatable/blob/main/README.md"
  spec.metadata["ai_assistant_uri"] = "https://github.com/afeiship/rails_templatable/blob/main/llms.txt"

  spec.required_ruby_version = ">= 3.0.0"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "llms.txt"]
  end

  spec.add_dependency "rails", ">= 6.0", "< 9.0"
end
