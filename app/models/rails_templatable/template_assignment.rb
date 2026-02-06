module RailsTemplatable
  class TemplateAssignment < ApplicationRecord
    self.table_name = "rails_templatable_assignments"

    belongs_to :template, class_name: "RailsTemplatable::Template"
    belongs_to :templatable, polymorphic: true

    validates :template, presence: true
    validates :templatable, presence: true
    validates :template_id, uniqueness: { scope: [:templatable_type, :templatable_id] }
  end
end
