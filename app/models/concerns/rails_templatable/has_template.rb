module RailsTemplatable
  module HasTemplate
    extend ActiveSupport::Concern

    included do
      # Each model instance can have only one template
      belongs_to :template,
                 class_name: "RailsTemplatable::Template",
                 optional: true
    end
  end
end
