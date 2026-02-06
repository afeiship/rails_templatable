module RailsTemplatable
  class Template < ApplicationRecord
    self.table_name = "rails_templatable_templates"

    has_many :assignments, class_name: "RailsTemplatable::TemplateAssignment", dependent: :destroy

    enum :content_format, { html: 0, markdown: 1, txt: 2 }

    validates :category, presence: true
    validates :content, presence: true
    validates :content_format, presence: true

    # Returns all associated records of the given class that have this template
    def assigned_to(klass)
      templatable_ids = assignments.where(templatable_type: klass.base_class.name).pluck(:templatable_id)
      klass.where(id: templatable_ids)
    end

    # Class method: Returns all templates ever used on the given model class
    def self.for_model(klass)
      template_ids = TemplateAssignment.where(templatable_type: klass.base_class.name).distinct.pluck(:template_id)
      where(id: template_ids)
    end
  end
end
