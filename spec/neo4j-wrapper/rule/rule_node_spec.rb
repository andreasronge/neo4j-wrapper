require 'spec_helper'


describe Neo4j::Wrapper::Rule::RuleNode do

  let(:ref_node) do
    r = MockNode.new
    java_node_klass = Class.new do
      def synchronized(&block)
        block.call
      end
    end

    r.stub(:_java_node) { java_node_klass.new }
    r
  end

  let(:node_class) do
    new_node_mixin_class
  end

  let(:ref_node_for_class) do
    MockNode.new
  end

  let(:global_model_class) do
    k = new_node_mixin_class
    r = ref_node_for_class
    k.stub(:ref_node_for_class) { r }
    k
  end

  before do
    Neo4j.stub(:ref_node) { ref_node }
    Neo4j::Transaction.stub(:run).and_yield
  end


  subject do
    Neo4j::Wrapper::Rule::RuleNode.new(node_class.to_s)
  end

  describe "to_s" do
    its(:to_s) { should be_a(String) }
  end

  describe "key" do
    it "is a Symbol" do
      subject.key.should be_a(Symbol)
    end
  end

  describe "rule_node" do
    let(:found_rule_node) { MockNode.new }
    context "when rule node already exists" do
      before do
        ref_node.should_receive(:rel?).with(:outgoing, node_class.to_s).and_return(true)
        ref_node.should_receive(:_node).with(:outgoing, node_class.to_s).and_return(found_rule_node)
      end

      it "returns the existing rule node" do
        subject.rule_node.should == found_rule_node
      end

      it "stores the found node" do
        subject.rule_node?(found_rule_node).should == false
        subject.rule_node
        subject.rule_node?(found_rule_node).should == true
      end
    end

    context "when rule node does not exists" do
      let(:new_rule_node) { MockNode.new }
      before do
        ref_node.should_receive(:rel?).with(:outgoing, node_class.to_s).and_return(false)
        Neo4j::Node.stub(:new) { new_rule_node }
        ref_node.should_receive(:create_relationship_to)
      end

      it "returns a new rule node" do
        subject.rule_node.should == new_rule_node
      end

      it "stores the new node" do
        subject.rule_node?(new_rule_node).should == false
        subject.rule_node
        subject.rule_node?(new_rule_node).should == true
      end
    end
  end

  describe "ref_node" do

    it "returns the Neo4j.ref_node" do
      #ref_node.should_receive(:rel?).with(:outgoing, node_class.to_s).and_return(false)
      rn = Neo4j::Wrapper::Rule::RuleNode.new(node_class.to_s)
      rn.ref_node.should == ref_node
    end

    it "returns the ref_node_for_class if initialized with a global ref node" do
      rn = Neo4j::Wrapper::Rule::RuleNode.new(global_model_class.to_s)
      rn.ref_node.should == ref_node_for_class
    end

  end
end