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


        # Get the indexed entity, creating it (exactly once) if no indexed entity exist.
        #
        # @example Creating a Unique node
        #
        #   class MyNode
        #     include Neo4j::NodeMixin
        #     property :email, :index => :exact, :unique => true
        #   end
        #
        #   node = MyNode.get_or_create(:email =>'jimmy@gmail.com', :name => 'jimmy')
        #
        # @see #put_if_absent
        def get_or_create(*args)
          props = args.first
          raise "Can't get or create entity since #{props.inspect} does not included unique key #{props[unique_factory_key]}'" unless props[unique_factory_key]
          index = index_for_type(_decl_props[unique_factory_key][:index])
          Neo4j::Core::Index::UniqueFactory.new(unique_factory_key, index) { |*| new(*args) }.get_or_create(unique_factory_key, props[unique_factory_key])
        end

        # @throws Exception if there are more then one property having unique index
        # @return [Symbol,nil] the property which has an unique index or nil
        def unique_factory_key
          @unique_factory_key ||= begin
            unique = []
            _decl_props.each_pair { |k, v| unique << k if v[:unique] }
            return nil if unique.empty?
            raise "Only one property can be unique, got #{unique.join(', ')}" if unique.size > 1
            unique.first
          end
        end

        # Loads a wrapped node from the database given a neo id.
        # @param [#to_i, nil] neo_id
        # @return [Object, nil] If the node does not exist it will return nil otherwise the loaded node or wrapped node.
        # @note it will return nil if the node returned is not kind of this class
        def load_entity(neo_id)
          node = Neo4j::Node.load(neo_id)
          return nil if node.nil?
          return node if node.class == Neo4j::Node
          node.kind_of?(self) ? node : nil
        end

      end
    end
  end
end