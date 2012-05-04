require 'upload_server/r'
module UploadServer
end

require 'sinatra/base'
require "active_record"
require "paperclip"
require 'json'
require 'haml'
require 'yaml'
require 'mime/types'
require 'net/http'
require 'uuidtools'
require 'fileutils'
require 'upload_server/extend_method'
require 'resque'
require 'upload_server/video_util'
require 'upload_server/copy_media_file_resque'
require 'upload_server/media_file_encode_resque'
require "upload_server/merge_slice_temp_file_resque"

require 'upload_server/media_file_info'
require 'upload_server/slice_temp_file'
require 'upload_server/server'


RAILS_ENV = ENV['RAILS_ENV'] || 'development'
if !%w(development test production).include?(RAILS_ENV)
  p "#{RAILS_ENV} 不是合法的 RAILS_ENV， 必须是 development test production 中的一个"
  exit 1
end

yaml = YAML.load_file(File.join(File.dirname(__FILE__),"../config/database.yml"))[RAILS_ENV]
PROJECT_ROOT = File.expand_path('../..',__FILE__)
ActiveRecord::Base.establish_connection(yaml)


