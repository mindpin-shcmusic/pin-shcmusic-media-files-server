require 'rubygems'

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

$:.unshift "#{File.dirname(__FILE__)}/lib"
require "upload_server"

root = ::File.dirname(__FILE__)
logfile = ::File.join(root,'log','requests.log')
require 'logger'
class ::Logger; alias_method :write, :<<; end
logger  = ::Logger.new(logfile,'weekly')
use Rack::CommonLogger, logger


run UploadServer::Server