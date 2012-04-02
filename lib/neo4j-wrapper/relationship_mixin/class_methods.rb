module Neo4j
  module Wrapper
    module RelationshipMixin
      module ClassMethods

        # Creates a relationship between given nodes.
        #
        # You can use two callback method to initialize the relationship
        # init_on_load:: this method is called when the relationship is loaded from the database
        # init_on_create:: called when the relationship is created, will be provided with the same argument as the new method
        #
        # @param [String, Symbol] type the type of the relationships
        # @param [Neo4j::Node, Neo4j::NodeMixin] from_node create relationship from this node
        # @param [Neo4j::Node, Neo4j::NodeMixin] to_node create relationship to this node
        # @param [Hash] props optional hash of properties to initialize the create relationship with
        # @see http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Relationship Neo4j::Relationship
        def new(type, from_node, to_node, *props)
          rel = Neo4j::Relationship.create(type, from_node, to_node)
          wrapped_rel = super()
          Neo4j::IdentityMap.add(rel, wrapped_rel)
          wrapped_rel.init_on_load(rel)
          wrapped_rel.init_on_create(type, from_node, to_node, *props)
          wrapped_rel
        end

        alias_method :create, :new
      end
    end
  end
end