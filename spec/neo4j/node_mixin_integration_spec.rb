require 'spec_helper'

describe Neo4j::NodeMixin, :type => :integration do

  let(:person_class) do
    new_node_mixin_class do
      property :name
      has_n :friends
      index :name
    end
  end

  let(:base_class) do
    new_node_mixin_class
  end

  let(:sub_class) do
    new_node_mixin_class(base_class)
  end

  let(:other_class) do
    new_node_mixin_class do
      property :name
    end
  end

  before(:each) { new_tx }
  after(:each) { finish_tx }

  describe "incoming relationships from same class" do
    before do
      person_class.has_n(:known_by).from(:friends)
    end

    it "can access incoming relationship" do
      n = person_class.new
      other = person_class.new
      n.friends << other
      finish_tx
      n.friends.should include(other)
      other.known_by.should include(n)
      n.friends.count.should == 1
      other.known_by.count.should == 1
    end
  end

  describe "incoming relationships from other class" do
    let(:other_class) do
      other = new_node_mixin_class
      person_class.has_n(:actors).to(other)
      other.has_n(:acted_in).from(person_class, :actors)
      other
    end

    it "can access incoming relationship" do
      n = person_class.new
      other = other_class.new
      n.actors << other
      finish_tx
      n.actors.count.should == 1
      n.actors.should include(other)
      other.acted_in.count.should == 1
      other.acted_in.should include(n)
    end
  end

  describe "properties" do
    it "can access the property using the defined property method" do
      n = person_class.new
      n.name.should be_nil
      n.name = 'kalle'
      n.name.should == 'kalle'
      n[:name].should == 'kalle'
      n[:name] = 'sune'
      n.name.should == 'sune'
    end
  end

  describe "Neo4j::Node.load" do
    it "should load the correct class" do
      n = person_class.new
      finish_tx
      Neo4j::Node.load(n.neo_id).should == n
    end
  end

  describe "NodeMixin.load_entity" do
    it "should load the correct class" do
      n = base_class.new
      finish_tx
      base_class.load_entity(n.neo_id).should == n
    end

    it "can't be loaded by a different class" do
      n = base_class.new
      finish_tx
      other_class.load_entity(n.neo_id).should be_nil
    end

    it "can be loaded by a baseclass" do
      n = sub_class.new
      finish_tx
      n.should be_kind_of(base_class)
      base_class.load_entity(n.neo_id).should == n
    end

    it "can not be loaded by a subclass" do
      n = base_class.new
      finish_tx
      n.should be_kind_of(base_class)
      sub_class.load_entity(n.neo_id).should be_nil
    end

  end


  describe "a inherited class" do
    let(:employee_class) do
      new_node_mixin_class(person_class) do
        property :employee_id, :ssn
        property :weight, :height, :type => Float
        has_n :contracts
      end
    end


    it "can use all the defined rels and properties in the base class" do
      empl = employee_class.new(:name => 'andreas', :employee_id => 123, :ssn => 1000, :height => '6.3')
      empl[:name].should == 'andreas'
      empl.ssn == 1000
      empl.height.class.should == Float
      empl.height.should == 6.3
    end

    it "can create new relationship using base class has_n definition" do
      empl = employee_class.new
      node = Neo4j::Node.new
      empl.friends << node
      empl.friends.should include(node)
    end
  end

end


