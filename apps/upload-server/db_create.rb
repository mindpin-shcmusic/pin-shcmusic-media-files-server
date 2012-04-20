#! /usr/bin/env ruby

require 'rubygems'
require "active_record"

 RAILS_ENV = (ENV['RAILS_ENV'] || 'development')

if !%w(development test production).include?(RAILS_ENV)
	p "RAILS_ENV 必须是 development test production 中的一个"
	exit 1
end

p "RAILS_ENV #{RAILS_ENV}"

yaml = YAML.load_file(File.join(File.dirname(__FILE__),"config/database.yml"))[RAILS_ENV]
# 创建数据库
yaml_clone = yaml.clone
database = yaml_clone.delete("database")
begin
	ActiveRecord::Base.establish_connection(yaml_clone)
	ActiveRecord::Migration.create_database database, :charset => 'utf8', :collation => 'utf8_unicode_ci'
rescue Exception=>ex
	if ex.message.match("database exists")
		p "database #{database} is already"
	end
end

# 创建数据表
begin
	ActiveRecord::Base.establish_connection(yaml)
	ActiveRecord::Migration.create_table(:slice_temp_files) do |t|
		t.integer :creator_id
		t.string :file_name
		t.integer :file_size
		t.string :path
		t.integer :saved_size
		t.integer :saved_blob_num
		t.timestamps
	end
rescue Exception=>ex
	if ex.message.match("already exists")
		p "table slice_temp_files is already"
	end
end