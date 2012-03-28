module Neo4j
  module Wrapper
    module NodeMixin
      module Initialize

        # Init this node with the specified java neo node
        # @param [Neo4j::Node] java_node the node this instance wraps
        def init_on_load(java_node)
          @_java_node = java_node
        end


        # Creates a new node and initialize with given properties.
        # You can override this to provide your own initialization.
        #
        # @param [Object, :each_pair] args if the first item in the list implements :each_pair then it will be initialize with those properties
        def init_on_create(*args)
          _java_entity[:_classname] = self.class.to_s
          if args[0].respond_to?(:each_pair)
            args[0].each_pair { |k, v| respond_to?("#{k}=") ? self.send("#{k}=", v) : _java_entity[k] = v }
          end
        end

        # @return [Neo4j::Node] Returns the org.neo4j.graphdb.Node wrapped object
        # @see http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Node
        def _java_node
          @_java_node
        end

        alias_method :_java_entity, :_java_node

      end
    end
  end

end