module Neo4j
  module Core
    module Traversal
      # Extends the Neo4j::Core Traverser in order to add rule traversal methods.
      class Traverser
        def filter_method(name, &proc)
          # add method name
          singelton = class << self;
            self;
          end
          singelton.send(:define_method, name) { filter &proc }
          self
        end


        def functions_method(func, rule_node, rule_name)
          singelton = class << self;
            self;
          end
          singelton.send(:define_method, func.class.function_name) do |*args|
            function_id = args.empty? ? "_classname" : args[0]
            function = rule_node.find_function(rule_name, func.class.function_name, function_id)
            function.value(rule_node.rule_node, rule_name)
          end
          self
        end
      end
    end
  end
end
