class CreateWorkLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :work_logs do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
