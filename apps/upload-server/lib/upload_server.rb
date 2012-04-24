module UploadServer
end

require 'sinatra/base'
require "active_record"
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
require 'upload_server/media_file_encode_resque'

require 'upload_server/multi_media'
require 'upload_server/slice_temp_file'
require 'upload_server/server'

PIN_2012_EDU_SITE = "http://dev.sns.yinyue.edu"

RAILS_ENV = ENV['RAILS_ENV'] || 'development'
yaml = YAML.load_file(File.join(File.dirname(__FILE__),"../config/database.yml"))[RAILS_ENV]
PROJECT_ROOT = File.expand_path('../..',__FILE__)
ActiveRecord::Base.establish_connection(yaml)




