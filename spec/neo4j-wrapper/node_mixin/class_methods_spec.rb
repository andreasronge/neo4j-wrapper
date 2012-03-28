require 'spec_helper'

describe Neo4j::Wrapper::NodeMixin::ClassMethods do

  subject do
    klass = Class.new do
      extend Neo4j::Wrapper::NodeMixin::ClassMethods
    end
    klass
  end

  describe "#new" do
    it "creates a new node" do
      node = mock("Node")
      Neo4j::Node.stub(:create).and_return(node)
      subject.any_instance.should_receive(:init_on_load).with(node)
      subject.any_instance.should_receive(:init_on_create)
      subject.new.should be_instance_of(subject)
    end

  end
end
