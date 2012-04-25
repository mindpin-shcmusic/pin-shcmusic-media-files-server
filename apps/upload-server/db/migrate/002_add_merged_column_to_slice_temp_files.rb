class AddMergedColumnToSliceTempFiles < ActiveRecord::Migration
  def change
    add_column :slice_temp_files,:merged,:boolean
  end
end