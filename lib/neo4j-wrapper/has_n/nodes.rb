module Neo4j
  module Wrapper
    module HasN

      # The object created by a has_n or has_one Neo4j::NodeMixin class method which enables creating and traversal of nodes.
      #
      # @see Neo4j::Wrapper::HasN::ClassMethods
      class Nodes
        include Enumerable
        include Neo4j::Core::ToJava

        def initialize(node, decl_rel, cypher_query_hash = nil, &cypher_block) # :nodoc:
          @node = node
          @decl_rel = decl_rel
          @cypher_block = cypher_block
          @cypher_query_hash = cypher_query_hash

          rule_node = Neo4j::Wrapper::Rule::Rule.rule_node_for(@decl_rel.target_class)

          singelton = class << self;
            self;
          end
          rule_node && rule_node.rules.each do |rule|
            next if rule.rule_name == :all
            singelton.send(:define_method, rule.rule_name) do |*cypher_query_hash, &cypher_block|

              proc = Proc.new do |m|
                r0 = m.incoming(:dangerous)
                if cypher_block
                  self.instance_exec(m, &cypher_block)
                end
              end
              query(cypher_query_hash.first, &proc)
            end
          end
        end

        def to_s
          "HasN::Nodes [#{@decl_rel.dir}, id: #{@node.neo_id} type: #{@decl_rel && @decl_rel.rel_type} decl_rel:#{@decl_rel}]"
        end

        def query(cypher_query_hash = nil, &block)
          Neo4j::Core::Traversal::CypherQuery.new(@node.neo_id, @decl_rel.dir, [@decl_rel.rel_type], cypher_query_hash, &block)
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
          if @cypher_block || @cypher_query_hash
            query(@cypher_query_hash, &@cypher_block).each { |i| yield i }
          else
            @decl_rel.each_node(@node) { |n| yield n } # Should use yield here as passing &block through doesn't always work (why?)
          end
        end

        # returns none wrapped nodes, you may get better performance using this method
        def _each
          @decl_rel._each_node(@node) { |n| yield n }
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
          @decl_rel.create_relationship_to(@node, other)
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
          @decl_rel.create_relationship_to(@node, other)
          self
        end
      end

    end
  end
end