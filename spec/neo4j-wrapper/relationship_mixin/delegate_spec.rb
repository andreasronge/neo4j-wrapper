require 'spec_helper'

describe Neo4j::Wrapper::RelationshipMixin::Delegates do

  subject do
    klass = Class.new do
      include Neo4j::Wrapper::RelationshipMixin::Delegates
    end
    klass.new
  end

  let(:java_rel) { @java_rel }

  before(:all) do
    @java_rel = Neo4j::Transaction.run { a = Neo4j::Node.new;  b = Neo4j::Node.new; Neo4j::Relationship.new(:friends, a, b)}
  end

  describe "Neo4j::Relationship" do
    subject { java_rel }
    Neo4j::Wrapper::RelationshipMixin::Delegates.instance_methods.each do |meth|
      it { should respond_to(meth) }
    end
  end

  it "s calls to the _java_entity" do
    subject.stub(:_java_entity) { Struct.new(:props).new({:name => 'foo'}) }
    subject.props.should == {:name => 'foo'}
  end

  context "when initialized" do
    let(:java_rel) { MockNode.new }

    before do
      Neo4j::Relationship.stub(:create) { java_rel }
    end

    subject do
      klass = Class.new do
        include Neo4j::Wrapper::RelationshipMixin::Delegates
        include Neo4j::Wrapper::RelationshipMixin::Initialize
        extend Neo4j::Wrapper::RelationshipMixin::ClassMethods

        def self.to_s
          "MyKlass"
        end
      end
      klass.new(:friends, 'node_a', 'node_b')
    end

    its(:_java_entity) { should == java_rel }
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
      java_rel.should_receive(:exist?)
      subject.exist?
    end

  end

end