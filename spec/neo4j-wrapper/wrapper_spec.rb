require 'spec_helper'

module Foo
  class MyNodeWrapper42
    extend Neo4j::Wrapper::ClassMethods
    include Neo4j::Wrapper::NodeMixin::Initialize
  end

  class MyRelWrapper42
    extend Neo4j::Wrapper::ClassMethods
    include Neo4j::Wrapper::RelationshipMixin::Initialize
  end

end

describe Neo4j::Wrapper, 'wrapper' do


  context "when it has a _classname" do
    it "initialize the class given by the _classname property" do
      node = MockNode.new(:_classname => 'Foo::MyNodeWrapper42')
      Neo4j::Wrapper.wrapper(node).should be_kind_of(Foo::MyNodeWrapper42)
    end
  end

  context "when it has a _classname" do
    it "returns the node it was given" do
      node = MockNode.new
      Neo4j::Wrapper.wrapper(node).should == node
    end
  end

  describe "Neo4j::Node#wrapper" do
    it "uses the Neo4j::Wrapper#wrapper method" do
      node = MockNode.new(:_classname => 'Foo::MyNodeWrapper42')
      node.wrapper.should be_kind_of(Foo::MyNodeWrapper42)
    end
  end

  describe "Neo4j::Relationship#wrapper" do
    it "uses the Neo4j::Wrapper#wrapper method" do
      rel = MockRelationship.new
      rel[:_classname] = 'Foo::MyRelWrapper42'
      rel.wrapper.should be_kind_of(Foo::MyRelWrapper42)
    end
  end

  describe "inheritance" do
    it "inherit with spec_helper" do
      a = new_node_mixin_class
      b = new_node_mixin_class(a)
      c = new_node_mixin_class(b)
      trigger = a._indexer.config._trigger_on['_classname']
      trigger.size.should == 3
      trigger.should include(a.to_s, b.to_s, c.to_s)

      trigger = b._indexer.config._trigger_on['_classname']
      trigger.size.should == 2
      trigger.should include(b.to_s, c.to_s)

      trigger = c._indexer.config._trigger_on['_classname']
      trigger.size.should == 1
      trigger.should include(c.to_s)
    end

    it "inherit all the properties and index configurations" do
      class InheritA
        include Neo4j::NodeMixin
        property :a, :index => :exact
      end

      class InheritB < InheritA
        include Neo4j::NodeMixin
        property :b, :index => :exact
      end

      class InheritC < InheritB
        include Neo4j::NodeMixin
        property :c, :index => :exact
      end

      InheritA._decl_props.should include(:a)
      InheritA._decl_props.size.should == 1

      trigger = InheritA._indexer.config._trigger_on['_classname']
      trigger.size.should == 3
      trigger.should include("InheritA", "InheritB", "InheritC")

      InheritB._decl_props.should include(:a,:b)
      InheritB._decl_props.size.should == 2

      trigger = InheritB._indexer.config._trigger_on['_classname']
      trigger.size.should == 2
      trigger.should include("InheritB", "InheritC")

      InheritC._decl_props.should include(:a,:b,:c)
      InheritC._decl_props.size.should == 3

      InheritC._indexer.config._field_types.should ==  {"a"=>String, "b"=>String, "c"=>String}
      InheritC._indexer.config._index_type.should == {"a"=>:exact, "b"=>:exact, "c"=>:exact}
      trigger = InheritC._indexer.config._trigger_on['_classname']
      trigger.size.should == 1
      trigger.should include("InheritC")
    end
  end
end


