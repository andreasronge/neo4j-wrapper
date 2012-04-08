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
      klass.setup_rel_index

      def klass.inherited(sub_klass)
        setup_neo4j_subclass(sub_klass)
        super
      end

      super

    end

  end
end
