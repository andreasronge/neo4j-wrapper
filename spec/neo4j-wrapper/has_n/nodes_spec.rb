require 'spec_helper'


describe Neo4j::Wrapper::HasN::Nodes do

  let(:node) do
    MockNode.new
  end

  let(:target_class) do
    klass = Class.new
    TempModel.setup(klass)
    klass
  end

  let(:decl_rel) do
    Neo4j::Wrapper::HasN::DeclRel.new(:friends, false, target_class)
  end

  subject do
    Neo4j::Wrapper::HasN::Nodes.new(node, decl_rel)
  end

  describe "#to_s" do
    its(:to_s) { should be_a(String) }
  end

  describe "#to_s" do
    its(:to_s) { should be_a(String) }
  end

  describe "#[]" do
    it "calls each x times and returns the outgoing node" do
      result = [MockRelationship.new(:friends, node), MockRelationship.new(:friends, node)]
      node.should_receive(:rels).with(:outgoing, :friends).and_return(result)
      subject[1].should == result[1].end_node
    end
  end

  describe "is_a?" do
    its(:is_a?, Array) { should be_true }
  end

  describe "_each" do
    context "when outgoing" do
      it "returns all end nodes" do
        a, b = MockRelationship.new(:friends, node), MockRelationship.new(:friends, node)
        result = [a, b]
        node.should_receive(:_rels).with(:outgoing, :friends).and_return(result)

        q = []
        subject._each do |x|
          q << x
        end
        q[0].should == a.end_node
        q[1].should == b.end_node
      end
    end

    context "when incoming" do
      before do
        decl_rel.from(:other)
      end

      it "returns all end nodes" do
        a, b = MockRelationship.new(:friends, MockNode.new, node), MockRelationship.new(:friends, MockNode.new, node)
        result = [a, b]
        node.should_receive(:_rels).with(:incoming, :other).and_return(result)

        q = []
        subject._each do |x|
          q << x
        end
        q[0].should == a.start_node
        q[1].should == b.start_node
      end
    end

  end

  describe "each" do
    context "when outgoing" do
      it "returns all end nodes" do
        a, b = MockRelationship.new(:friends, node), MockRelationship.new(:friends, node)
        result = [a, b]
        node.should_receive(:rels).with(:outgoing, :friends).and_return(result)

        q = []
        subject.each do |x|
          q << x
        end
        q[0].should == a.end_node
        q[1].should == b.end_node
      end
    end

    context "when incoming" do
      before do
        decl_rel.from(:other)
      end

      it "returns all end nodes" do
        a, b = MockRelationship.new(:friends, MockNode.new, node), MockRelationship.new(:friends, MockNode.new, node)
        result = [a, b]
        node.should_receive(:rels).with(:incoming, :other).and_return(result)

        q = []
        subject.each do |x|
          q << x
        end
        q[0].should == a.start_node
        q[1].should == b.start_node
      end
    end

  end


  describe "<<" do
    it "creates a relationship" do
      new_node = MockNode.new
      decl_rel.should_receive(:create_relationship_to).with(node, new_node)
      res = subject << new_node
      res.should be_kind_of(Neo4j::Wrapper::HasN::Nodes)
    end

  end

end
