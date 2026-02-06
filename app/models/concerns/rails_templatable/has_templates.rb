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
