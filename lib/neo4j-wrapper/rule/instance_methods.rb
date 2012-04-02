module Neo4j
  module Wrapper
    module Rule
      module InstanceMethods
        # Trigger rules.
        # You don't normally need to call this method (except in Migration) since
        # it will be triggered automatically by the Neo4j::Wrapper::Rule::Rule
        # @see Neo4j::Wrapper::Rule::ClassMethods
        def trigger_rules
          self.class.trigger_rules(self)
        end
      end
    end
  end

end
