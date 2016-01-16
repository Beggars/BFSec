# coding:utf-8
require 'mysql2'
require 'active_record'

ActiveRecord::Base.configurations = YAML.load_file("#{$basedir}/config/database.yml")
ActiveRecord::Base.establish_connection(:development)
