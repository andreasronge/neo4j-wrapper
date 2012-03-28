require 'spec_helper'

describe Neo4j::Wrapper::NodeMixin::Delegates do

  subject do
    klass = Class.new do
      include Neo4j::Wrapper::NodeMixin::Delegates
    end
    klass.new
  end

  let(:java_node) { @java_node }
  before(:all) do
    @java_node = Neo4j::Transaction.run { Neo4j::Node.new }
  end

  describe "Neo4j::Node" do
    subject { java_node }
    Neo4j::Wrapper::NodeMixin::Delegates.instance_methods.each do |meth|
      it { should respond_to(meth) }
    end
  end

  it "s calls to the _java_entity" do
    subject.stub(:_java_entity) { Struct.new(:props).new({:name => 'foo'}) }
    subject.props.should == {:name => 'foo'}
  end

  context "when initialized" do
    let(:java_node) { MockNode.new }

    before do
      Neo4j::Node.stub(:create) { java_node }
    end

    subject do
      klass = Class.new do
        include Neo4j::Wrapper::NodeMixin::Delegates
        include Neo4j::Wrapper::NodeMixin::Initialize
        extend Neo4j::Wrapper::NodeMixin::ClassMethods

        def self.to_s
          "MyKlass"
        end
      end
      klass.new
    end

    its(:_java_entity) { should == java_node }
    its(:[], :_classname) { should == "MyKlass" }
    its(:props) { should == {:_classname => "MyKlass"} }
    its(:property?, :foo) { should be_false }
    it "[]= sets property" do
      subject[:foo] = "bar"
      subject[:foo].should == "bar"
    end

    it (":update, {:ko => 42} updates the node") do
      subject.update(:ko => 42)
      subject[:ko].should == 42
    end

    its(:neo_id) { should be_a(Fixnum) }

    it "exist? check if node exist" do
      java_node.should_receive(:exist?)
      subject.exist?
    end

  end

end