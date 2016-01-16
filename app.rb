# coding:utf-8
$basedir = File.dirname(__FILE__)

require 'sinatra'
require 'active_record'
require 'sinatra/contrib'
require 'sinatra/activerecord'

require File.expand_path('../db/connection',__FILE__)


class BaiduUser < ActiveRecord::Base
  self.table_name = "bd_users"
end

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  register Sinatra::Namespace
  register Sinatra::Reloader

  set :root, "#{$basedir}"
  set :views, "#{$basedir}/app/views"
  set :public_folder, 'public'

end

require_relative "app/init"
