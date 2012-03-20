module Neo4j

  # This mixin is used to wrap Neo4j Java Nodes in Ruby objects.
  #
  # {render:Neo4j::Wrapper::NodeMixin::ClassMethods#new}
  #
  module NodeMixin
    include Neo4j::Wrapper::NodeMixin::Delegates

    # @return the Neo4j::Node object that this instance wraps
    # @see http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Node Neo4j::Core::Node
    def _java_entity

    end

    # @private
    def self.included(klass)
      klass.extend Neo4j::Wrapper::NodeMixin::ClassMethods
    end

  end
end