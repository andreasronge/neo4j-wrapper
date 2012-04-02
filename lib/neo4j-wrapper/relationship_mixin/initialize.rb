module Neo4j
  module Wrapper
    module RelationshipMixin
      module Initialize

        # Init this node with the specified java neo4j relationship.
        def init_on_load(java_rel)
          @_java_rel = java_rel
        end


        # Creates a new node and initialize with given properties.
        # You can override this to provide your own initialization.
        #
        # @param (see Neo4j::Wrapper::RelationshipMixin::ClassMethods#new)
        def init_on_create(rel_type, from_node, to_node, *props) # :nodoc:
          _java_entity[:_classname] = self.class.to_s
          if props.first.respond_to?(:each_pair)
            props.first.each_pair { |k, v| respond_to?("#{k}=") ? self.send("#{k}=", v) : @_java_rel[k] = v }
          end
        end

        # @returns [Neo4j::Relationship] the wrapped relationship object
        # @see http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Relationship Neo4j::Relationship
        def _java_rel
          @_java_rel
        end

        alias_method :_java_entity, :_java_rel

      end
    end
  end

end