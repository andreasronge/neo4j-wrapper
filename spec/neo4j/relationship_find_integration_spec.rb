require 'spec_helper'

describe Neo4j::NodeMixin, "find", :type => :integration do

  before(:each) { new_tx }
  after(:each) { finish_tx }

  let(:person_class) do
    new_node_mixin_class do
      property :name
    end
  end

  let(:from_node) { Neo4j::Transaction.run { person_class.new(:name => 'from node')}}
  let(:to_node) { Neo4j::Transaction.run { person_class.new(:name => 'to node')}}

  let(:knows_class) do
    new_relationship_mixin_class do
      property :wheels, :type => Fixnum, :index => :exact
      property :since, :type => Time, :index => :exact
      property :name
      property :weight, :type => Float, :index => :exact
    end
  end

  let(:friends_class) do
    new_relationship_mixin_class(knows_class) do
      property :brand, :index => :fulltext
      property :colour, :type => String, :index => :exact
    end
  end


  it "can find" do
    k1 = knows_class.new(:friends, from_node, to_node, :wheels => 42)
    finish_tx

    knows_class.find(:wheels => 42).first.should == k1
  end

  it "can find using a base class" do
    k1 = friends_class.new(:friends, from_node, to_node, :wheels => 42)
    finish_tx

    knows_class.find(:wheels => 42).first.should == k1
    friends_class.find(:wheels => 42).first.should == k1
  end

  it "can find using a Date" do
    pending
    today = Time.now
    k1 = friends_class.new(:friends, from_node, to_node, :since => today)
    finish_tx
    friends_class.find(:since => today).first.should == k1
  end
end
