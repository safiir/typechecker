require "typechecker/version"
require "typechecker/exception"
require "typechecker/definition"

module TypeChecker    
  class ::Object
    def self.method_added(name, &block)
      if $force_terminate_recursion
        @@expect = nil
        $force_terminate_recursion = false
        return 
      end
      
      return if !signature_declared?
      
      return if name.to_s.end_with?("__hook")

      @@poly_definition ||= {}
      @@poly_definition[name] ||= []
      method = self.instance_method(name)
      
      if method.arity != @@expect.size
        @@expect = nil
        raise Err::Inconsistent.new(self), "The implementation is inconsistent with the declaration"
      end
      
      if @@poly_definition[name].find{ |definition|
        definition.type.size == method.arity && @@expect.zip(definition.type).all?{ |curr, prev| curr == prev }
      } then
        @@expect = nil
        raise Err::ConflictDefinition.new(self), "Conflict definition" 
      end
      @@poly_definition[name] << MethodDefinition.new(method, @@expect, name)

      self.define_method("#{name}__hook") do |*args, &block|
        definitions = @@poly_definition[name].select{ |definition|
          definition.type.size == args.size && definition
                                              .type
                                              .zip(args.map(&:class))
                                              .all?{ |expect, actual| actual.ancestors.include?(expect) }
        }

        if definitions.empty?
          raise NoMethodError.new(self), "#{name}(#{args.map(&:class).join(", ")})"
        else
          definition_set = args.map(&:class).map.with_index{ |clazz, i|
            ancestors = clazz.ancestors
            precise_subtype = definitions
                              .min_by{ |definition| ancestors.index(definition.type[i]) }
                              .type[i]
            Set.new(definitions.select{ |definition| definition.type[i] == precise_subtype })
          }.reduce(Set.new(definitions), :&)
          
          if definition_set.empty?
            raise Err::AmbiguousMethodCall.new(self), "Ambiguous method call"
          end
        end
        
        definition_set.first.unbind_method.bind(self).call(*args, &block)
      end

      $force_terminate_recursion = true
      self.class_eval "alias #{name} #{name}__hook"
    end
    
    def self.sig(*expect)
      if signature_declared?
        @@expect = nil
        raise Err::DuplicateSignature.new(self), "Duplicate signature"
      end
      @@expect = expect
    end
    
    def signature_declared?
      class_variable_defined?("@@expect") && !@@expect.nil?
    end
    
    def overloading_methods(name)
      @@poly_definition[name.to_sym]&.map(&:inspect) || []
    end
    
    def typed_methods
      @@poly_definition.keys
    end
  end
end