module Neo4j

  # This mixin is used to wrap Neo4j Java Nodes in Ruby objects.
  #
  # @example Declare and Use a Lucene Index
  #
  #   class Contact
  #      include Neo4j::NodeMixin
  #      index :phone
  #      property :phone
  #   end
  #
  #   # Find an contact with a phone number
  #   Contact.find('phone: 12345').first #=> a phone object !
  #
  # {render:Neo4j::Wrapper::NodeMixin::ClassMethods#new}
  #
  # = Class Method Modules
  # * {Neo4j::Wrapper::ClassMethods}
  # * {Neo4j::Wrapper::NodeMixin::ClassMethods}
  # * {http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Core/Index/ClassMethods Neo4j::Core::Index::ClassMethods}
  #
  # = Instance Method Modules
  # * {http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Core/Index Neo4j::Core::Index}
  module NodeMixin
    include Neo4j::Wrapper::NodeMixin::Delegates
    include Neo4j::Wrapper::NodeMixin::Initialize
    include Neo4j::Core::Index


    # @private
    def self.included(klass)
      klass.extend Neo4j::Wrapper::ClassMethods
      klass.extend Neo4j::Wrapper::NodeMixin::ClassMethods
      klass.extend Neo4j::Core::Index::ClassMethods

      # TODO
      #klass.class_inheritable_accessor :_decl_rels
      #klass._decl_rels ||= {}

      index_name = klass.to_s.gsub("::", '_')

      klass.node_indexer do
        index_names :exact => "#{index_name}_exact", :fulltext => "#{index_name}_fulltext"
        trigger_on :_classname => klass.to_s
      end

      def klass.inherited(sub_klass)
        index_name = sub_klass.to_s.gsub("::", '_')
        base_class = self

        # make the base class trigger on the sub class nodes
        base_class._indexer.config.trigger_on :_classname => sub_klass.to_s

        sub_klass.node_indexer do
          inherit_from base_class
          index_names :exact => "#{index_name}_exact", :fulltext => "#{index_name}_fulltext"
          trigger_on :_classname => sub_klass.to_s
        end
        super
      end
    end

    # TODO
    #def self._index_prefix
    #  return "" unless Neo4j.running?
    #  return "" unless respond_to?(:ref_node_for_class)
    #  ref_node = ref_node_for_class.wrapper
    #  prefix = ref_node.send(:_index_prefix) if ref_node.respond_to?(:_index_prefix)
    #  prefix ||= ref_node[:name] # To maintain backward compatiblity
    #  prefix.blank? ? "" : prefix + "_"
    #end

  end
end