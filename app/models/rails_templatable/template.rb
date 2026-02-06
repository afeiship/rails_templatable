module RailsTemplatable
  class Template < ApplicationRecord
    self.table_name = "rails_templatable_templates"

    # Rails 6 compatible enum syntax
    # For Rails 8+, use: enum :content_format, { html: 0, markdown: 1, txt: 2 }
    enum content_format: { html: 0, markdown: 1, txt: 2 }

    validates :category, presence: true
    validates :content, presence: true
    validates :content_format, presence: true

    # Note: This template can be referenced by any model that includes HasTemplate concern.
    # Target models should define their own has_many relationship if needed.
    #
    # Example in target model:
    #   class Post < ApplicationRecord
    #     include RailsTemplatable::HasTemplate
    #
    #     # Optional: define reverse association
    #     has_many :feature_posts, class_name: "Post", foreign_key: :template_id
    #   end
  end
end
