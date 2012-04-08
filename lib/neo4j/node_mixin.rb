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
  # * {Neo4j::Wrapper::NodeMixin::ClassMethods} - redefines the <tt>new</tt> method
  # * {Neo4j::Wrapper::Property::ClassMethods} - defines <tt>property</tt> method
  # * {Neo4j::Wrapper::HasN::ClassMethods} - defines <tt>has_n</tt>  and <tt>has_one</tt> method
  # * {Neo4j::Wrapper::Find} - defines <tt>find</tt> method
  # * {Neo4j::Wrapper::Rule::ClassMethods} - defines <tt>rule</tt> method
  # * {http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Core/Index/ClassMethods Neo4j::Core::Index::ClassMethods}
  #
  # = Instance Method Modules
  # * {http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Core/Index Neo4j::Core::Index}
  module NodeMixin
    include Neo4j::Wrapper::NodeMixin::Delegates
    include Neo4j::Wrapper::NodeMixin::Initialize
    include Neo4j::Wrapper::HasN::InstanceMethods
    include Neo4j::Wrapper::Rule::InstanceMethods
    include Neo4j::Wrapper::Property::InstanceMethods
    include Neo4j::Core::Index

    # @private
    def self.included(klass)
      klass.extend Neo4j::Wrapper::ClassMethods
      klass.extend Neo4j::Wrapper::NodeMixin::ClassMethods
      klass.extend Neo4j::Wrapper::Property::ClassMethods
      klass.extend Neo4j::Wrapper::HasN::ClassMethods
      klass.extend Neo4j::Core::Index::ClassMethods
      klass.extend Neo4j::Wrapper::Find
      klass.extend Neo4j::Wrapper::Rule::ClassMethods
      klass.send(:include, Neo4j::Wrapper::Rule::Functions)
      klass.setup_node_index

      def klass.inherited(sub_klass)
        setup_neo4j_subclass(sub_klass)
        super
      end

      super
    end

  end
end