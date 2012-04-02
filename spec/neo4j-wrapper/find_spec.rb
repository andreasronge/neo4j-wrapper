require 'spec_helper'


describe Neo4j::Wrapper::Find do
  let(:wrapper_class) do
    Class.new do
      def self.to_s
        "Foo::Bar"
      end

      extend Neo4j::Core::Index::ClassMethods
      extend Neo4j::Wrapper::Find
      extend Neo4j::Wrapper::ClassMethods
      include Neo4j::Wrapper::NodeMixin::Initialize

      klass = self
      node_indexer do
        index_names :exact => "#{klass._index_name}_exact", :fulltext => "#{klass._index_name}_fulltext"
        trigger_on :_classname => klass.to_s
        prefix_index_name &klass.method(:index_prefix)
      end
    end

  end

  describe "index_name_for_type" do
    it "returns the name even if the database has not started" do
      wrapper_class.index_name_for_type(:exact).should == "Foo_Bar_exact"
    end

    it "should not have a prefix if using default ref node" do
      Neo4j.stub(:running?) { true }
      Neo4j.stub(:ref_node) { MockNode.new }
      wrapper_class.index_name_for_type(:exact).should == "Foo_Bar_exact"
    end

    it "should have a prefix if not using default ref node" do
      Neo4j.stub(:running?) { true }
      my_ref_node = MockNode.new
      my_ref_node.stub(:index_prefix) { "Prefix" }
      Neo4j.stub(:ref_node) { my_ref_node }
      wrapper_class.index_name_for_type(:exact).should == "Prefix_Foo_Bar_exact"
    end

  end

end