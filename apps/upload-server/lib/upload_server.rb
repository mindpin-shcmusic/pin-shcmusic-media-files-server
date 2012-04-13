module UploadServer
end

require 'sinatra/base'
require 'json'
require 'haml'
require 'net/http'
require 'uuidtools'
require 'fileutils'
require 'upload_server/extend_method'
require 'resque'
require 'upload_server/video_util'
require 'upload_server/media_file_encode_resque'

require 'upload_server/multi_media'
require 'upload_server/server'