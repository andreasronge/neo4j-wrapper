# external neo4j dependencies
require 'neo4j/index/index'
require 'neo4j/property/property'

# internal dependencies
require 'neo4j/relationship_mixin/class_methods'


module Neo4j

  # Use this mixin to wrap Neo4j Relationship Java object.
  # This mixin is similar to Neo4j::NodeMixin which wraps Neo4j::Node Java objects.
  #
  # ==== Instance Methods, Mixins
  # * Neo4j::Index :: relationships can also be indexed just like nodes
  # *
  # ==== Class Methods, Mixins
  # * Neo4j::Index::ClassMethods :: for declaration for keeping lucene index and neo4j property in sync
  # * Neo4j::Property::ClassMethods :: for declaration of convenience accessors of property
  #
  module RelationshipMixin
    extend Forwardable
    include Neo4j::Index

    def_delegators :@_java_rel, :[]=, :[], :property?, :props, :attributes, :update, :neo_id, :id, :to_param, :getId,
                   :equal?, :eql?, :==, :delete, :getStartNode, :getEndNode, :getOtherNode, :exist?



    # --------------------------------------------------------------------------
    # Initialization methods
    #


    # Init this node with the specified java neo4j relationship.
    #
    def init_on_load(java_rel) # :nodoc:
      @_java_rel = java_rel
    end


    # Creates a new node and initialize with given properties.
    #
    def init_on_create(*args) # :nodoc:
      type, from_node, to_node, props = args
      self[:_classname] = self.class.to_s
      if props.respond_to?(:each_pair)
        props.each_pair { |k, v| respond_to?("#{k}=") ? self.send("#{k}=", v) : @_java_rel[k] = v }
      end
    end


    # --------------------------------------------------------------------------
    # Instance Methods
    #

    # Returns the org.neo4j.graphdb.Relationship wrapped object
    def _java_rel
      @_java_rel
    end

    def _java_entity
      @_java_rel
    end

    # Returns the end node of this relationship
    def end_node
      id = getEndNode.getId
      Neo4j::Node.load(id)
    end

    # Returns the start node of this relationship
    def start_node
      id = getStartNode.getId
      Neo4j::Node.load(id)
    end

    # Deletes this relationship
    def del
      delete
    end

    def exist?
      Neo4j::Relationship.exist?(self)
    end

    # A convenience operation that, given a node that is attached to this relationship, returns the other node.
    # For example if node is a start node, the end node will be returned, and vice versa.
    # This is a very convenient operation when you're manually traversing the node space by invoking one of the #rels operations on node.
    #
    # This operation will throw a runtime exception if node is neither this relationship's start node nor its end node.
    #
    # ==== Example
    # For example, to get the node "at the other end" of a relationship, use the following:
    #   Node endNode = node.rel(:some_rel_type).other_node(node)
    #
    def other_node(node)
      neo_node = node.respond_to?(:_java_node)? node._java_node : node
      id = getOtherNode(neo_node).getId
      Neo4j::Node.load(id)
    end


    # Returns the neo relationship type that this relationship is used in.
    # (see java API org.neo4j.graphdb.Relationship#getType  and org.neo4j.graphdb.RelationshipType)
    #
    # ==== Returns
    # the relationship type (of type Symbol)
    #
    def relationship_type
      @_java_rel.getType.name.to_sym
    end

    # --------------------------------------------------------------------------
    # Class Methods
    #

    class << self
      def included(c) # :nodoc:
        c.instance_eval do
          class << self
            alias_method :orig_new, :new
          end
        end
        
        c.class_inheritable_accessor :_decl_props
        c._decl_props ||= {}

        c.extend ClassMethods
        c.extend Neo4j::Property::ClassMethods
        c.extend Neo4j::Index::ClassMethods

        def c.inherited(subclass)
          subclass.rel_indexer self
          super
        end

        c.rel_indexer c
      end
    end
  end
end
