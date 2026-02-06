# frozen_string_literal: true

class CreateRailsTemplatableTables < ActiveRecord::Migration[6.0]
  def change
    # Create templates table
    # To add custom fields to templates, add columns here, e.g.:
    #   t.string :name
    #   t.text :description
    create_table :rails_templatable_templates do |t|
      t.string :category, null: false
      t.text :content
      t.integer :content_format, null: false, default: 2

      t.timestamps
    end

    add_index :rails_templatable_templates, :category

    # Note: No join table needed.
    # Target models (posts, work_logs, etc.) should add their own template_id foreign key:
    #
    #   add_reference :posts, :template,
    #                 foreign_key: { to_table: :rails_templatable_templates },
    #                 index: false
    #   add_reference :work_logs, :template,
    #                 foreign_key: { to_table: :rails_templatable_templates },
    #                 index: false
  end
end
