module Neo4j
  module Wrapper
    module HasN
      module ClassMethods

        # @return [Hash] a hash of all relationship and its configuration defined by has_n and has_one
        def _decl_rels
          @_decl_rels ||= {}
        end

        # make sure the inherited classes inherit the <tt>_decl_rels</tt> hash
        def inherited(klass)
          copy = _decl_rels.clone
          copy.each_pair{|k,v| copy[k] = v.inherit_new}
          klass.instance_variable_set(:@_decl_rels, copy)
          super
        end


        # Specifies a relationship between two node classes.
        # Generates assignment and accessor methods for the given relationship.
        # Both incoming and outgoing relationships can be declared, see {Neo4j::Wrapper::HasN::DeclRel}
        #
        # @example has_n(:files)
        #
        #   class FolderNode
        #      include Ne4j::NodeMixin
        #      has_n(:files)
        #   end
        #
        #   folder = FolderNode.new
        #   folder.files << Neo4j::Node.new << Neo4j::Node.new
        #   folder.files.inject {...}
        #
        #   FolderNode.files #=> 'files' the name of the relationship
        #
        # @example has_n(x).to(...)
        #
        #   # You can declare which class it has relationship to.
        #   # The generated relationships will be prefixed with the name of that class.
        #   class FolderNode
        #      include Ne4j::NodeMixin
        #      has_n(:files).to(File)
        #      Same as has_n(:files).to("File")
        #   end
        #
        #   FolderNode.files #=> 'File#files' the name of the relationship
        #
        # @example has_n(x).from(class, has_n_name)
        #
        #   # generate accessor method for traversing and adding relationship on incoming nodes.
        #   class FileNode
        #      include Ne4j::NodeMixin
        #      has_one(:folder).from(FolderNode.files)
        #      # or same as
        #      has_one(:folder).from(FolderNode, :files)
        #   end
        #
        # @example Using Cypher
        #   # from FolderNode example above
        #   folder.files.query{ cypher query DSL, see neo4j-core}
        #   folder.files{ } # same as above
        #   folder.files.query(:name => 'file.txt') # a cypher query with WHERE and statements
        #   folder.files(:name => 'file.txt') # same as above
        #   folder.files.query.to_s # the cypher query explained as a String
        #
        # @return [Neo4j::Wrapper::HasN::DeclRel] a DSL object where the has_n relationship can be further specified
        def has_n(rel_type)
          clazz = self
          module_eval(%Q{
                def #{rel_type}(cypher_hash_query = nil, &cypher_block)
                    dsl = _decl_rels_for('#{rel_type}'.to_sym)
                    Neo4j::Wrapper::HasN::Nodes.new(self, dsl, cypher_hash_query, &cypher_block)
                end}, __FILE__, __LINE__)


          module_eval(%Q{
                def #{rel_type}_rels
                    dsl = _decl_rels_for('#{rel_type}'.to_sym)
                    dsl.all_relationships(self)
                end}, __FILE__, __LINE__)

          instance_eval(%Q{
          def #{rel_type}
            _decl_rels[:#{rel_type}].rel_type
          end}, __FILE__, __LINE__)

          _decl_rels[rel_type.to_sym] = DeclRel.new(rel_type, false, clazz)
        end


        # Specifies a relationship between two node classes.
        # Generates assignment and accessor methods for the given relationship
        # Old relationship is deleted when a new relationship is assigned.
        # Both incoming and outgoing relationships can be declared, see {Neo4j::Wrapper::HasN::DeclRel}
        #
        # @example
        #
        #   class FileNode
        #      include Ne4j::NodeMixin
        #      has_one(:folder)
        #   end
        #
        #   file = FileNode.new
        #   file.folder = Neo4j::Node.new
        #   file.folder # => the node above
        #   file.folder_rel # => the relationship object between those nodes
        #
        # @return [Neo4j::Wrapper::HasN::DeclRel] a DSL object where the has_one relationship can be futher specified
        def has_one(rel_type)
          clazz = self
          module_eval(%Q{def #{rel_type}=(value)
                  dsl = _decl_rels_for(:#{rel_type})
                  rel = dsl.single_relationship(self)
                  rel.del unless rel.nil?
                  dsl.create_relationship_to(self, value) if value
              end}, __FILE__, __LINE__)

          module_eval(%Q{def #{rel_type}
                  dsl = _decl_rels_for('#{rel_type}'.to_sym)
                  dsl.single_node(self)
              end}, __FILE__, __LINE__)

          module_eval(%Q{def #{rel_type}_rel
                  dsl = _decl_rels_for(:#{rel_type})
                  dsl.single_relationship(self)
               end}, __FILE__, __LINE__)

          instance_eval(%Q{
          def #{rel_type}
            _decl_rels[:#{rel_type}].rel_type
          end}, __FILE__, __LINE__)

          _decl_rels[rel_type.to_sym] = DeclRel.new(rel_type, true, clazz)
        end

      end
    end
  end

end