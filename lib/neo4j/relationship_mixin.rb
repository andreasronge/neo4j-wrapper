module Neo4j
  # Use this mixin to wrap Neo4j Relationship Java object.
  # This mixin is similar to Neo4j::NodeMixin which wraps Neo4j::Node Java objects.
  #
  # @example
  #   class Friend
  #      include Neo4j::RelationshipMixin
  #      property :since, :type => Fixnum, :index => :exact
  #      property :strength, :type => Float
  #      property :location
  #    end
  #
  #  Friend.new(:knows, node_a, node_b, :strength => 3.14)
  #  Friend.find(:strength => (2..5)).first
  #
  # = Class Method Modules
  # * {Neo4j::Wrapper::RelationshipMixin::ClassMethods}
  # * {Neo4j::Wrapper::Property::ClassMethods}
  # * {Neo4j::Core::Index::ClassMethods}
  # * {Neo4j::Wrapper::Find}
  module RelationshipMixin

    include Neo4j::Wrapper::RelationshipMixin::Initialize
    include Neo4j::Wrapper::RelationshipMixin::Delegates
    include Neo4j::Wrapper::Property::InstanceMethods

    # @private
    def self.included(klass)
      klass.extend Neo4j::Wrapper::ClassMethods
      klass.extend Neo4j::Wrapper::RelationshipMixin::ClassMethods
      klass.extend Neo4j::Wrapper::Property::ClassMethods
      klass.extend Neo4j::Core::Index::ClassMethods
      klass.extend Neo4j::Wrapper::Find

      index_name = klass.to_s.gsub("::", '_')

      klass.rel_indexer do
        index_names :exact => "#{index_name}_exact", :fulltext => "#{index_name}_fulltext"
        trigger_on :_classname => klass.to_s
      end

      def klass.inherited(sub_klass)
        return super if sub_klass.to_s == self.to_s
        index_name = sub_klass.to_s.gsub("::", '_')
        base_class = self

        # make the base class trigger on the sub class nodes
        base_class._indexer.config.trigger_on :_classname => sub_klass.to_s

        sub_klass.rel_indexer do
          inherit_from base_class
          index_names :exact => "#{index_name}_exact", :fulltext => "#{index_name}_fulltext"
          trigger_on :_classname => sub_klass.to_s
        end
        super
      end

      super

    end

  end
end
