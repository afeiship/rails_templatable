class AddTemplateToWorkLogs < ActiveRecord::Migration[8.1]
  def change
    add_reference :work_logs, :template,
                  null: true,
                  foreign_key: { to_table: :rails_templatable_templates },
                  index: false
  end
end
