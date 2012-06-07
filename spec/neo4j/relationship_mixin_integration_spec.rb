require 'spec_helper'

describe Neo4j::RelationshipMixin, :type => :integration do

  let(:person_class) do
    new_node_mixin_class do
      property :name
    end
  end

  let(:friend_class) do
    new_relationship_mixin_class do
      property :since, :type => Fixnum#, :index => :exact
      property :strength, :type => Float
      property :location
    end
  end

  let(:person_a) do
    Neo4j::Transaction.run { person_class.new(:name => 'person_a') }
  end

  let(:person_b) do
    Neo4j::Transaction.run { person_class.new(:name => 'person_b') }
  end

  before(:each) { new_tx }
  after(:each) { finish_tx }

  describe "#new(:knows, person_a, person_b)" do
    it "creates a new relationship" do
      friend_class.new(:knows, person_a, person_b)
    end

  end

  describe "start_node" do
    it "loads the wrapped start node" do
      f = friend_class.new(:knows, person_a, person_b)
      f.start_node.class.should == person_class
    end

    it "loads the wrapped end_node node" do
      f = friend_class.new(:knows, person_a, person_b)
      f.end_node.class.should == person_class
    end

  end

  describe "load_entity" do
    it "should load the correct class" do
      n = friend_class.new(:knows, person_a, person_b)
      finish_tx
      friend_class.load_entity(n.neo_id).should == n
    end

    it "should return nil if given nil" do
      friend_class.load_entity(nil).should be_nil
    end
  end

end