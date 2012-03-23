module Neo4j
  module Wrapper
    module HasN

      # The object created by a has_n or has_one Neo4j::NodeMixin class method which enables creating and traversal of nodes.
      #
      # @see Neo4j::Wrapper::HasN::ClassMethods
      class Nodes
        include Enumerable
        include Neo4j::Core::ToJava

        def initialize(node, dsl) # :nodoc:
          @node = node
          @dsl = dsl
        end

        def to_s
          "HasN::Nodes [#{@dsl.dir}, id: #{@node.neo_id} type: #{@dsl && @dsl.rel_type} dsl:#{@dsl}]"
        end

        # Traverse the relationship till the index position
        # @return [Neo4j::NodeMixin,Neo4j::Node,nil] the node at the given position
        def [](index)
          i = 0
          each { |x| return x if i == index; i += 1 }
          nil # out of index
        end

        # Pretend we are an array - this is necessarily for Rails actionpack/actionview/formhelper to work with this
        def is_a?(type)
          # ActionView requires this for nested attributes to work
          return true if Array == type
          super
        end

        # Required by the Enumerable mixin.
        def each
          @dsl.each_node(@node) { |n| yield n } # Should use yield here as passing &block through doesn't always work (why?)
        end

        # returns none wrapped nodes, you may get better performance using this method
        def _each
          @dsl._each_node(@node) { |n| yield n }
        end

        # Returns an real ruby array.
        def to_ary
          self.to_a
        end

        # Returns true if there are no node in this type of relationship
        def empty?
          first == nil
        end


        # Creates a relationship instance between this and the other node.
        # Returns the relationship object
        def new(other)
          @dsl.create_relationship_to(@node, other)
        end


        # Creates a relationship between this and the other node.
        #
        # @example Person includes the Neo4j::NodeMixin and declares a has_n :friends
        #
        #   p = Person.new # Node has declared having a friend type of relationship
        #   n1 = Node.new
        #   n2 = Node.new
        #
        #   p.friends << n2 << n3
        #
        # @return self
        def <<(other)
          @dsl.create_relationship_to(@node, other)
          self
        end
      end

    end
  end
end