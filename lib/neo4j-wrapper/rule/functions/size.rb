module Neo4j
  module Wrapper
    module Rule
      module Functions

        # A function for counting number of nodes of a given class.
        class Size < Function
          def initialize
            @property = '_classname'
            @@lock ||= Java::java.lang.Object.new
          end

          def calculate?(changed_property)
            true
          end

          def delete(rule_name, rule_node, _)
            key = rule_node_property(rule_name)
            rule_node[key] ||= 0
            rule_node[key] -= 1
          end

          def add(rule_name, rule_node, _)
            key = rule_node_property(rule_name)
            rule_node[key] ||= 0
            rule_node[key] += 1
          end

          def update(*)
            # we are only counting, not interested in property changes
          end

          def classes_changed(rule_name, rule_node, class_change)
            key = rule_node_property(rule_name)
            @@lock.synchronized do
              rule_node[key] ||= 0
              rule_node[key] += class_change.net_change
            end
          end

          def self.function_name
            :size
          end
        end
      end
    end
  end
end