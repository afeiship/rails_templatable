# frozen_string_literal: true

# This migration comes from rails_templatable (originally 20250207000000)
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

    # Create join table for polymorphic associations
    # To add custom fields to assignments, add columns here, e.g.:
    #   t.integer :priority
    #   t.boolean :active, default: true
    create_table :rails_templatable_assignments do |t|
      t.references :template, null: false, foreign_key: { to_table: :rails_templatable_templates }
      t.references :templatable, polymorphic: true, null: false, index: false

      t.timestamps
    end

    # Custom composite index with short name
    add_index :rails_templatable_assignments,
              [:template_id, :templatable_type, :templatable_id],
              unique: true,
              name: "index_templatable_assignments"
  end
end
