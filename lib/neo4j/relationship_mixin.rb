module Neo4j
  # Use this mixin to wrap Neo4j Relationship Java object.
  # This mixin is similar to Neo4j::NodeMixin which wraps Neo4j::Node Java objects.
  #
  # @example
  #   class Friend
  #      include Neo4j::RelationshipMixin
  #      property :since, :type => Fixnum, :index => :exact
  #      property :strength, :type => Float
  #      property :location
  #    end
  #
  #  Friend.new(:knows, node_a, node_b, :strength => 3.14)
  #  Friend.find(:strength => (2..5)).first
  module RelationshipMixin

  end
end
