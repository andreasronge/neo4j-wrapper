module Neo4j
  module Wrapper
    module NodeMixin
      module ClassMethods

        # Creates a new node or loads an already existing Neo4j node.
        #
        # You can use two callback method to initialize the node
        # init_on_load - this method is called when the node is loaded from the database
        # init_on_create - called when the node is created, will be provided with the same argument as the new method
        #
        # == Does
        # * sets the neo4j property '_classname' to self.class.to_s
        # * creates a neo4j node java object (in @_java_node)
        #
        # If you want to provide your own initialize method you should instead implement the
        # method init_on_create method.
        #
        # @example Create your own Ruby wrapper around a Neo4j::Node java object
        #   class MyNode
        #     include Neo4j::NodeMixin
        #   end
        #
        #   node = MyNode.new(:name => 'jimmy', :age => 23)
        #
        # @example Using your own initialize method
        #   class MyNode
        #     include Neo4j::NodeMixin
        #
        #     def init_on_create(name, age)
        #        self[:name] = name
        #        self[:age] = age
        #     end
        #   end
        #
        #   node = MyNode.new('jimmy', 23)
        #
        # @param args typically a hash of properties, but could be anything which will be handled in the super method
        # @return the object return from the super method
        def new(*args)
          node = Neo4j::Node.create
          wrapped_node = super()
          Neo4j::IdentityMap.add(node, wrapped_node)
          wrapped_node.init_on_load(node)
          wrapped_node.init_on_create(*args)
          wrapped_node
        end

        alias_method :create, :new

        # Loads a wrapped node from the database given a neo id.
        # @param [#to_i, nil] neo_id
        # @raise an exception if the loaded node/relationship is not of the same kind as this class.
        # @return [Object, nil] If the node does not exist it will return nil otherwise the loaded node or wrapped node.
        def load_entity(neo_id)
          node = Neo4j::Node.load(neo_id)
          return nil if node.nil?
          return node if node.class == Neo4j::Node
          raise "Expected loaded node #{neo_id} to be of type #{self} but it was #{node.class}" unless node.kind_of?(self)
          node
        end

      end
    end
  end
end