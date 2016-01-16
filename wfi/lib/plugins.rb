# 使用class_eval 打开类 mix 必须是extend, define_method 定义实例对象方法, instance_variable_set 给实例属性赋值
module PluginSugar
  def define_fields(*names)
    class_eval do
      names.each do |name|
        define_method(name) do |*args|
          instance_variable_set("@#{name}", *args)
        end
      end
    end
  end
end


class Plugin

  @registered_plugins = {}

  class << self
    attr_reader :registered_plugins, :plugin_name
  end


  def self.define(name, &block)
    plugin = new
    plugin.set_plugin_name(name)
    plugin.instance_eval(&block)
    Plugin.registered_plugins[name] = plugin
  end

  def set_plugin_name(name)
    @plugin_name = name
  end

  def init(target)
    @target = target
    @body = target.body
    @headers = target.headers
    @status=target.status
    @md5sum=target.md5sum
  end

  def make_matches(target, match)
    result = []
    context = target.body

    unless match[:text].nil?
      if match[:regexp_compiled] =~ context
        result << match
      end
    end
  end

  def run
    puts "run"
  end

  extend PluginSugar
  # 定义字段
  define_fields :author, :version, :description, :website, :matches
end

class PluginLoader

  def PluginLoader.load_plugins
    plugins_dir = File.expand_path('../plugins/', File.dirname(__FILE__))
    Dir.glob("#{plugins_dir}/*.rb").each do |plugin|
      load plugin
    end
    Plugin.registered_plugins
  end
end


p = PluginLoader.load_plugins
p.each do |item|
  p item[1].run
end
