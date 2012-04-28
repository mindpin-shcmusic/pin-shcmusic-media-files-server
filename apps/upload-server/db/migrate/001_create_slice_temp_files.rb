class CreateSliceTempFiles < ActiveRecord::Migration
  def change
    create_table(:slice_temp_files) do |t|
      t.integer :creator_id
      t.integer :media_file_id

      t.string :entry_file_name
      t.string :entry_content_type
      t.integer :entry_file_size
      t.datetime :entry_updated_at

      t.integer :saved_size
      t.boolean :merged
      t.string :real_file_name
      t.timestamps
    end
  end
end
