module TypeChecker
  class MethodDefinition
    attr_accessor :unbind_method, :type, :name
    
    def initialize(unbind_method, type, name)
      @unbind_method = unbind_method
      @type = type
      @name = name
    end
    
    def inspect
      "#{name}(#{type.join(", ")})"
    end
  end
end