require 'spec_helper'

describe Neo4j::Wrapper::RelationshipMixin::Initialize do

  subject do
    klass = Class.new do
      include Neo4j::Wrapper::RelationshipMixin::Initialize

      def self.to_s
        "MyClass"
      end
    end
    klass.new
  end

  describe "#init_on_load" do
    it "stores the relationship" do
      subject.init_on_load("Foo")
      subject._java_rel.should == "Foo"
      subject._java_entity.should == "Foo"
    end
  end

  describe "#init_on_create" do
    before do
      subject.init_on_load({})
    end

    it "sets the _classname _java_entity property" do
      subject.init_on_create(:friends, 'from_node', 'to_node', :prop1 => 'value1')
      subject._java_entity[:_classname].should == "MyClass"
    end

    context "('friends', from_node, to_node, :prop1 => 'value1') argument" do
      it "sets the property of the relationship" do
        subject.init_on_create('hej', 'from_node', 'to_node', :prop1 => 'value1')
        subject._java_entity[:_classname].should == "MyClass"
        subject._java_entity[:prop1].should == "value1"
        subject._java_entity.size.should == 2
      end
    end

  end

end