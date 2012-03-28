require 'spec_helper'

describe Neo4j::Wrapper::RelationshipMixin::ClassMethods do

  subject do
    klass = Class.new do
      extend Neo4j::Wrapper::RelationshipMixin::ClassMethods
    end
    klass
  end

  describe "#new(:friend, node_a, node_b)" do
    it "creates a new relationship" do
      Neo4j::Relationship.should_receive(:create).with(:friend, 'node_a', 'node_b').and_return('new_relationship')
      subject.any_instance.should_receive(:init_on_load).with('new_relationship')
      subject.any_instance.should_receive(:init_on_create).with(:friend, 'node_a', 'node_b')

      # when
      result = subject.new(:friend, 'node_a', 'node_b')

      # then
      result.should be_instance_of(subject)
    end
  end

  describe "#new(:friend, node_a, node_b, :since => 1994)" do
    it "creates a new relationship" do
      Neo4j::Relationship.should_receive(:create).with(:friend, 'node_a', 'node_b').and_return('new_relationship')
      subject.any_instance.should_receive(:init_on_load).with('new_relationship')
      subject.any_instance.should_receive(:init_on_create).with(:friend, 'node_a', 'node_b', :since => 1994)

      # when
      result = subject.new(:friend, 'node_a', 'node_b', :since => 1994)

      # then
      result.should be_instance_of(subject)
    end
  end

end
