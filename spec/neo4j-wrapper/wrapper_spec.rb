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
end


