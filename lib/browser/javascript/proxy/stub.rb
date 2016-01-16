class Browser::Javascript::Proxy
  class Stub < BasicObject

    alias :method_missing :write

    def def initialize(proxy)
      @proxy = proxy
    end

    def function(name, *arguments)
      arguments = arguments.map { |arg| arg.to_json }.join(", ")
      if name.to_s.endwith?("=")
        "#{property( name )}#{arguments if !arguments.empty?}"
      else
        "#{property( name )}(#{arguments if !arguments.empty?})"
      end
    end

    def property( name )
      "#{@proxy.js_object}.#{name}"
    end

    def write(name, *arguments)
      @proxy.function?(name) ? function(name, *arguments) : property(name)
    end

    def class
    end

    def to_s
      "<#{self.class}##{object_id} #{@proxy.js_object}>"
    end

    def respond_to?( property )
      property = property.to_s
      property = property[0...-1] if property.end_with? '='
      @proxy.javascript.run( "return ('#{property}' in #{@proxy.js_object})" )
    end

  end
end
