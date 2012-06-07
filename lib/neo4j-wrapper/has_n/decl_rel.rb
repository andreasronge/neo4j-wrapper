module Neo4j
  module Wrapper
    module HasN


      # A DSL for declared relationships has_n and has_one
      # This DSL will be used to create accessor methods for relationships.
      # Instead of using the 'raw' Neo4j::NodeMixin#rels method where one needs to know
      # the name of relationship and direction one can use the generated accessor methods.
      #
      # The DSL can also be used to specify a mapping to a Ruby class for a relationship, see Neo4j::HasN::DeclRelationshipDsl#relationship
      #
      # @example
      #
      #   class Folder
      #      include Neo4j::NodeMixin
      #      property :name
      #      # Declaring a Many relationship to any other node
      #      has_n(:files)
      #    end
      #
      #   class File
      #     include Neo4j::NodeMixin
      #     # declaring a incoming relationship from Folder's relationship files
      #     has_one(:folder).from(Folder, :files)
      #   end
      #
      # The following methods will be generated:
      # <b>Folder#files</b> ::      returns an Enumerable of outgoing nodes for relationship 'files'
      # <b>Folder#files_rels</b> :: returns an Enumerable of outgoing relationships for relationship 'files'
      # <b>File#folder</b> ::       for adding one node for the relationship 'files' from the outgoing Folder node
      # <b>File#folder_rel</b> ::   for accessing relationship 'files' from the outgoing Folder node
      # <b>File#folder</b> ::       for accessing nodes from relationship 'files' from the outgoing Folder node
      #
      class DeclRel
        attr_reader :source_class, :dir, :rel_type

        def initialize(method_id, has_one, source_class)
          @method_id = method_id
          @has_one = has_one
          @dir = :outgoing
          @rel_type = method_id.to_sym
          @source_class = source_class
        end

        def inherit_new
          base = self
          dr = DeclRel.new(@method_id, @has_one, @source_class)
          dr.instance_eval do
            @dir = base.dir
            @rel_type = base.rel_type
            @target_name = base.target_name if base.target_name
            @source_class = base.source_class
          end
          dr
        end

        def to_s
          "DeclRel #{object_id} dir: #{@dir} rel_id: #{@method_id}, rel_type: #{@rel_type}, target_class:#{@target_name} rel_class:#{@relationship}"
        end

        # @return [true, false]
        def has_one?
          @has_one
        end

        # @return [true, false]
        def has_n?
          !@has_one
        end

        # @return [true,false]
        def incoming? #:nodoc:
          @dir == :incoming
        end


        # Declares an outgoing relationship type.
        # It is possible to prefix relationship types so that it's possible to distinguish different incoming relationships.
        # There is no validation that the added node is of the specified class.
        #
        # @example Example
        #   class FolderNode
        #     include Neo4j::NodeMixin
        #     has_n(:files).to(FileNode)
        #     has_one(:root).to("FileSystem") # also possible, if the class is not defined yet
        #   end
        #
        #  folder = FolderNode.new
        #  # generate a relationship between folder and file of type 'FileNode#files'
        #  folder.files << FileNode.new
        #
        # @example without prefix
        #
        #   class FolderNode
        #     include Neo4j::NodeMixin
        #     has_n(:files).to(:contains)
        #   end
        #
        #   file = FileNode.new
        #   # create an outgoing relationship of type 'contains' from folder node to file
        #   folder.files << FolderNode.new
        #
        # @param [Class, String, Symbol] target the other class to which this relationship goes (if String or Class) or the relationship (if Symbol)
        # @param [Class, String, Symbol] rel_type the rel_type postfix for the relationships, which defaults to the same as the has_n/one method id
        # @return self
        def to(target, rel_type = @method_id)
          @dir = :outgoing

          if Class === target || String === target
            # handle e.g. has_n(:friends).to(class)
            @target_name = target
            @rel_type = "#{@source_class}##{rel_type}".to_sym
          elsif Symbol === target
            # handle e.g. has_n(:friends).to(:knows) or to("Person#friends")
            @target_name = target.to_s.split("#")[0] if target.to_s.include?("#")
            @rel_type = target.to_sym
          else
            raise "Expected a class or a symbol for, got #{target}/#{target.class}"
          end
          self
        end

        # Specifies an incoming relationship.
        # Will use the outgoing relationship given by the from class.
        #
        # @example with prefix FileNode
        #   class FolderNode
        #     include Neo4j::NodeMixin
        #     has_n(:files).to(FileNode)
        #   end
        #
        #   class FileNode
        #     include Neo4j::NodeMixin
        #     # will only traverse any incoming relationship of type files from node FileNode
        #     has_one(:folder).from(FolderNode.files)
        #     # alternative: has_one(:folder).from(FolderNode, :files) 
        #   end
        #
        #   file = FileNode.new
        #   # create an outgoing relationship of type 'FileNode#files' from folder node to file (FileNode is the prefix).
        #   file.folder = FolderNode.new
        #
        # @example without prefix
        #
        #   class FolderNode
        #     include Neo4j::NodeMixin
        #     has_n(:files)
        #   end
        #
        #   class FileNode
        #     include Neo4j::NodeMixin
        #     has_one(:folder).from(:files)  # will traverse any incoming relationship of type files
        #   end
        #
        #   file = FileNode.new
        #   # create an outgoing relationship of type 'files' from folder node to file
        #   file.folder = FolderNode.new
        #
        #
        def from(*args)
          @dir = :incoming

          if args.size > 1
            # handle specified (prefixed) relationship, e.g. has_n(:known_by).from(clazz, :type)
            @target_name = args[0]
            @relationship_name = args[1].to_sym
            @rel_type = "#{@target_name}##{args[1]}".to_sym
          elsif Symbol === args[0]
            # handle unspecified (unprefixed) relationship, e.g. has_n(:known_by).from(:type)
            name = args[0].to_s
            if name.include?("#")
              @target_name, @relationship_name = name.split("#").map(&:to_sym)
            end
            @rel_type = args[0]
          else
            raise "Expected a symbol for, got #{args[0].inspect}"
          end
          self
        end

        # Specifies which relationship ruby class to use for the relationship
        #
        # @example
        #
        #   class OrderLine
        #     include Neo4j::RelationshipMixin
        #     property :units
        #     property :unit_price
        #   end
        #
        #   class Order
        #     property :total_cost
        #     property :dispatched
        #     has_n(:products).to(Product).relationship(OrderLine)
        #   end
        #
        #  order = Order.new
        #  order.products << Product.new
        #  order.products_rels.first # => OrderLine
        #
        def relationship(rel_class)
          @relationship = rel_class
          self
        end

        # @private
        def target_name
          @target_name
        end

        # @private
        def relationship_class # :nodoc:
          if @dir == :incoming
            other_class_dsl = target_class && target_class._decl_rels[@relationship_name]
            @relationship = other_class_dsl.relationship_class if other_class_dsl
           end
          @relationship
        end

        def target_class
          @target_name && (@target_name.is_a?(Class) ? @target_name : Neo4j::Wrapper.to_class(@target_name.to_s))
        end


        # @private
        def each_node(node, &block)
          node.rels(dir, rel_type).each do |rel|
            block.call(rel.other_node(node))
          end
        end

        # @private
        def _each_node(node, &block) #:nodoc:
          node._rels(dir, rel_type).each do |rel|
            block.call rel._other_node(node)
          end
        end

        # @private
        def single_node(node)
          rel = single_relationship(node)
          rel && rel.other_node(node)
        end

        # @private
        def single_relationship(node) #:nodoc:
          node.rel(dir, rel_type)
        end

        # @private
        def _all_relationships(node) #:nodoc:
          node._rels(dir, rel_type)
        end

        # @private
        def all_relationships(node)
          node.rels(dir, rel_type)
        end

        # @private
        def create_relationship_to(node, other) # :nodoc:
          from, to = incoming? ? [other, node] : [node, other]

          if relationship_class
            relationship_class.new(@rel_type, from._java_node, to._java_node)
          else
            Neo4j::Relationship.new(@rel_type, from, to)
          end
        end

      end
    end
  end
end
