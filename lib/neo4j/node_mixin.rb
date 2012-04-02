module Neo4j

  # This mixin is used to wrap Neo4j Java Nodes in Ruby objects.
  #
  # @example Declare and Use a Lucene Index
  #
  #   class Contact
  #      include Neo4j::NodeMixin
  #      property :phone, :index => :exact
  #   end
  #
  #   # Find an contact with a phone number
  #   Contact.find('phone: 12345').first #=> a phone object !
  #
  #
  # = Class Method Modules
  # * {Neo4j::Wrapper::ClassMethods}
  # * {Neo4j::Wrapper::NodeMixin::ClassMethods}
  # * {Neo4j::Wrapper::Property::ClassMethods}
  # * {Neo4j::Wrapper::HasN::ClassMethods}
  # * {Neo4j::Wrapper::Find}
  # * {http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Core/Index/ClassMethods Neo4j::Core::Index::ClassMethods}
  #
  # = Instance Method Modules
  # * {http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Core/Index Neo4j::Core::Index}
  module NodeMixin
    include Neo4j::Wrapper::NodeMixin::Delegates
    include Neo4j::Wrapper::NodeMixin::Initialize
    include Neo4j::Wrapper::HasN::InstanceMethods
    include Neo4j::Core::Index


    # @private
    def self.included(klass)
      klass.extend Neo4j::Wrapper::ClassMethods
      klass.extend Neo4j::Wrapper::NodeMixin::ClassMethods
      klass.extend Neo4j::Wrapper::Property::ClassMethods
      klass.extend Neo4j::Wrapper::HasN::ClassMethods
      klass.extend Neo4j::Core::Index::ClassMethods
      klass.extend Neo4j::Wrapper::Find


      klass.node_indexer do
        index_names :exact => "#{klass._index_name}_exact", :fulltext => "#{klass._index_name}_fulltext"
        trigger_on :_classname => klass.to_s
        prefix_index_name &klass.method(:index_prefix)
      end

      def klass.inherited(sub_klass)
        return super if sub_klass.to_s == self.to_s
        base_class = self

        # make the base class trigger on the sub class nodes
        base_class._indexer.config.trigger_on :_classname => sub_klass.to_s

        sub_klass.node_indexer do
          inherit_from base_class
          index_names :exact => "#{sub_klass._index_name}_exact", :fulltext => "#{sub_klass._index_name}_fulltext"
          trigger_on :_classname => sub_klass.to_s
          prefix_index_name &sub_klass.method(:index_prefix)
        end
        super
      end
      super
    end

  end
end