class AddTemplateToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :template,
                  null: true,
                  foreign_key: { to_table: :rails_templatable_templates },
                  index: false
  end
end
