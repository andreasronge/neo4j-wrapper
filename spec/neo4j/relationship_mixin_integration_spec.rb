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
end