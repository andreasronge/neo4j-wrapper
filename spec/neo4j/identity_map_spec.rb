require 'spec_helper'

def reload_entity(wrapper)
  wrapper.kind_of?(Neo4j::NodeMixin) ? Neo4j::Node.load(wrapper.neo_id) : Neo4j::Relationship.load(wrapper.neo_id)
end

share_examples_for "containing the entity" do
  after(:each) { finish_tx }

  it "exist in the identity map" do
    Neo4j::IdentityMap.get(subject._java_entity).should_not be_nil
  end

  it "has the same object id" do
    Neo4j::IdentityMap.get(subject._java_entity).object_id.should == subject.object_id
  end

  context "when loaded" do
    before(:each) { @loaded = reload_entity(subject) }

    it "exist in the identity map" do
      Neo4j::IdentityMap.get(subject._java_entity).should_not be_nil
    end

    it "has the same object id" do
      Neo4j::IdentityMap.get(subject._java_entity).object_id.should == subject.object_id
    end

    it "the loaded object is the same" do
      @loaded.object_id.should == subject.object_id
    end
  end
end

share_examples_for "not containing the entity" do
  after(:each) { finish_tx }

  it "does not exist in the identity map" do
    Neo4j::IdentityMap.get(subject._java_entity).should be_nil
  end

  context "when loaded" do
    before(:each) { @loaded = reload_entity(subject) }

    it "exist in the identity map" do
      Neo4j::IdentityMap.get(subject._java_entity).should_not be_nil
    end

    it "has the same object id" do
      Neo4j::IdentityMap.get(subject._java_entity).object_id.should == @loaded.object_id
    end

    it "when loading again it should return the same instance" do
      reload_entity(subject).object_id.should == @loaded.object_id
    end
  end
end


describe "Identity Map", :identity_map => true do

  before(:all) do
    Neo4j.db.event_handler.add(Neo4j::IdentityMap)
    @old_identity_map_enabled = Neo4j::IdentityMap.enabled?
    Neo4j::IdentityMap.enabled = true
  end

  after(:all) do
    Neo4j::IdentityMap.enabled = @old_identity_map_enabled
  end

  class ClassIncludedNodeMixin
    include Neo4j::NodeMixin
    property :name
  end


  context "Created a Neo4j::NodeMixin class but not committed it" do
    before(:each) { new_tx; @instance = ClassIncludedNodeMixin.new }
    subject { @instance }
    it_should_behave_like "containing the entity"
  end

  context "Created and committed a Neo4j::NodeMixin class" do
    before(:each) { new_tx; @instance = ClassIncludedNodeMixin.new; finish_tx }
    subject { @instance }
    it_should_behave_like "not containing the entity"
  end

  class ClassIncludedRelationshipMixin
    include Neo4j::RelationshipMixin
    property :name
  end

  context "Created a Neo4j::RelationshipMixin class but not committed it" do
    before(:each) do
      new_tx
      @a = Neo4j::Node.new(:name => 'a')
      @b = Neo4j::Node.new(:name => 'b')
      @instance = ClassIncludedRelationshipMixin.new(:foo, @a, @b)
    end

    subject { @instance }
    it_should_behave_like "containing the entity"
  end

  context "Created and committed a Neo4j::RelationshipMixin class" do
    before(:each) do
      new_tx
      @a = Neo4j::Node.new(:cname => 'a')
      @b = Neo4j::Node.new(:name => 'b')
      @instance = ClassIncludedRelationshipMixin.new(:foo, @a, @b)
      finish_tx
    end
    subject { @instance }
    it_should_behave_like "not containing the entity"
  end

end
