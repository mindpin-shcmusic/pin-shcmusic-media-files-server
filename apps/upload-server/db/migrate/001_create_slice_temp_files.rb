class CreateSliceTempFiles < ActiveRecord::Migration
  def change
    create_table(:slice_temp_files) do |t|
      t.integer :creator_id
      t.string :file_name
      t.integer :file_size
      t.integer :saved_size
      t.integer :saved_blob_num
      t.boolean :merged
      t.string :uuid
      t.timestamps
    end
  end
end
