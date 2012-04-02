require 'spec_helper'

describe Neo4j::Wrapper::Rule::Functions::Count, :type => :integration do
  before(:each) { new_tx }
  after(:each) { finish_tx }

  context "rule :all, :functions => Count.new" do
    let(:klass) do
      clazz = new_node_mixin_class do
        property :age
      end
      clazz.rule(:all, :functions => Neo4j::Wrapper::Rule::Functions::Count.new)
      clazz
    end

    #before(:all) do
    #  klass = new_node_mixin_class do
    #    property :age
    #  end
    #  klass.rule(:all, :functions => Neo4j::Wrapper::Rule::Functions::Count.new)
    #end

    context "for a subclass" do
      class CountBaseClass
        include Neo4j::NodeMixin
        rule(:all, :functions => Count.new)
      end

      class CountSubClass < CountBaseClass
      end

      after(:each) do
        new_tx
        CountSubClass.all.each { |n| n.del }
        CountBaseClass.all.each { |n| n.del }
        new_tx
      end

      it "should update the counter when deleted" do
        CountBaseClass.count(:all).should == 0
        node = CountBaseClass.new
        new_tx
        CountBaseClass.count(:all).should == 1
        node.del
        new_tx
        CountBaseClass.count(:all).should == 0
      end

      it "should update the counter when deleted for subclass" do
        CountSubClass.count(:all).should == 0
        node = CountSubClass.new
        new_tx
        CountSubClass.count(:all).should == 1
        node.del
        new_tx
        CountSubClass.count(:all).should == 0
      end

      it "should update counter for only subclass when a new subclass is created" do
        CountSubClass.new
        new_tx
        CountBaseClass.count(:all).should == 1
        CountSubClass.count(:all).should == 1

        CountBaseClass.new
        new_tx
        CountBaseClass.count(:all).should == 2
        CountSubClass.count(:all).should == 1
        CountSubClass.all.count.should == 1
      end

      it "should update counter for both baseclass and subclass" do
        CountBaseClass.new
        new_tx
        CountSubClass.count(:all).should == 0
        CountBaseClass.count(:all).should == 1

        CountSubClass.new
        new_tx
        CountSubClass.count(:all).should == 1
        CountBaseClass.count(:all).should == 2
      end
    end


    context "when empty group" do
      it ".count(:all).should == 0" do
        klass.count(:all).should == 0
      end

      it ".count(:all).should == 1 when a new node has been created" do
        klass.new
        new_tx
        klass.count(:all).should == 1
      end
    end

    context "when one node" do
      before(:each) do
        @node = klass.new
        new_tx
      end

      it ".count(:all).should == 1" do
        klass.count(:all).should == 1
      end

      it "when deleted .count(:all).should == 0" do
        klass.count(:all).should == 1
        @node.del
        new_tx
        klass.count(:all).should == 0
      end

      it ".count(:all).should == 2 when another node is created" do
        klass.new
        new_tx
        klass.count(:all).should == 2
      end
    end
  end

  context "rule(:young, :functions => Count.new){ age < 30}" do

    let(:klass) do
      clazz = new_node_mixin_class do
        property :age
      end
      clazz.rule(:young, :functions => Neo4j::Wrapper::Rule::Functions::Count.new) { age && age < 30 }
      clazz
    end

    #before(:all) do
    #  klass = new_node_mixin_class do
    #    property :age
    #  end
    #  klass.rule(:young, :functions => Neo4j::Wrapper::Rule::Functions::Count.new) { age && age < 30 }
    #end


    context "when empty group" do
      it ".count(:young).should == 0" do
        klass.count(:young).should == 0
      end

      it ".count(:young) should == 1 when a new young node has been created" do
        klass.new :age => 5
        new_tx
        klass.count(:young).should == 1
      end

      it ".count(:young) should == 0 when a NOT new young node has been created" do
        klass.new :age => 124
        new_tx
        klass.count(:young).should == 0
      end

      it ".young.count should == 0" do
        klass.young.count.should == 0
      end
    end

    context "when there is one NOT young node" do
      before(:each) do
        @node = klass.new :age => 421
        new_tx
      end

      it ".count(:young).should == 0" do
        klass.count(:young).should == 0
      end

      it "when deleted the .count(:young).should == 0" do
        @node.del
        new_tx
        klass.count(:young).should == 0
        klass.young.count.should == 0
      end

      it "when the node is changed into a young node (changed property), .count(:young).should == 1" do
        @node.age = 4
        new_tx
        klass.count(:young).should == 1
        klass.young.count.should == 1
      end

      it "when creating two young nodes, .count(:young).should == 2" do
        klass.new :age => 4
        klass.new :age => 5
        new_tx
        klass.count(:young).should == 2
        klass.young.count.should == 2
      end
    end

    context "when there is one young node" do
      before(:each) do
        @node = klass.new :age => 5
        new_tx
      end

      it ".count(:young).should == 1" do
        klass.count(:young).should == 1
        klass.young.count.should == 1
      end

      it "when deleted the .count(:young).should == 0" do
        @node.del
        new_tx
        klass.count(:young).should == 0
        klass.young.count.should == 0
      end
    end
  end

end

describe Neo4j::Wrapper::Rule::Functions::Sum, :type => :integration do

  before(:each) { new_tx }
  after(:each) { finish_tx }

  context "rule :all, :functions => Sum.new(:age)" do
    let(:klass) do
      clazz = new_node_mixin_class do
        property :age
      end
      clazz.rule :all, :functions => Neo4j::Wrapper::Rule::Functions::Sum.new(:age)
      clazz
    end

    context "when empty group" do
      it "is zero" do
        klass.sum(:all, :age).should == 0
      end

      it "when creating a node it should add it's age" do
        klass.new :age => 42
        new_tx
        klass.sum(:all, :age).should == 42
      end

      it "when creating a node and it does not have a age property it should not change the sum" do
        klass.new
        new_tx
        klass.sum(:all, :age).should == 0
      end
    end

    context "when group has one node" do
      before(:each) do
        @node = klass.new :age => 10
        new_tx
      end

      it "when node is deleted it should subtract it's age from the sum" do
        @node.del
        new_tx
        klass.sum(:all, :age).should == 0
        klass.all.sum(:age).should == 0
      end

      it "when age property is changed it should change the sum" do
        @node[:age] = 20
        new_tx
        klass.sum(:all, :age).should == 20
      end

      it "when removing the age property it should remove the old age from the sum" do
        @node[:age] = nil
        new_tx
        klass.sum(:all, :age).should == 0
      end

      it "when creating two nodes it should add it's ages to the sum" do
        @node = klass.new :age => 100
        @node = klass.new :age => 1000
        new_tx
        klass.sum(:all, :age).should == 1110
      end
    end
  end

  context "rule :old, :functions => Sum.new(:age)" do

    let(:klass) do
      clazz = new_node_mixin_class do
        property :age
      end
      clazz.rule(:all, :functions => Neo4j::Wrapper::Rule::Functions::Sum.new(:age))
      clazz.rule(:old, :functions => Neo4j::Wrapper::Rule::Functions::Sum.new(:age)) { age && age > 20 }
      clazz
    end

    context "when empty group" do
      it "is zero" do
        klass.sum(:old, :age).should == 0
        klass.old.sum(:age).should == 0
      end

      it "when creating an old node it should add it's age" do
        klass.new :age => 42
        new_tx
        klass.sum(:old, :age).should == 42
        klass.old.sum(:age).should == 42
      end

      it "when creating a NOT old node it should NOT add it's age" do
        klass.new :age => 1
        new_tx
        klass.sum(:old, :age).should == 0
        klass.old.sum(:age).should == 0
      end

      it "when creating a node and it does not have an age property it should not change the sum" do
        klass.new
        new_tx
        klass.sum(:old, :age).should == 0
        klass.old.sum(:age).should == 0
      end
    end

    context "when group has one node" do


      let(:node) do
        node = klass.new :age => 30
        new_tx
        node
      end

      it "when node is deleted it should subtract it's age from the sum" do
        node.del
        new_tx
        klass.sum(:old, :age).should == 0
        klass.old.sum(:age).should == 0
      end

      it "when age property is changed it should change the sum" do
        node[:age] = 50
        new_tx
        klass.sum(:old, :age).should == 50
        klass.old.sum(:age).should == 50
      end

      it "when age property is changed so that it node is no longer in the old rule group it should subtract the age from the sum" do
        node[:age] = 10
        new_tx
        klass.sum(:old, :age).should == 0
        klass.old.sum(:age).should == 0
      end

      it "when age property is changed so that it node is no longer it should still update the other rule group sum it is member of" do
        node[:age] = 10
        new_tx
        klass.sum(:all, :age).should == 10
        klass.all.sum(:age).should == 10
      end

      it "when removing the age property it should remove the old age from the sum" do
        node[:age] = nil
        new_tx
        klass.sum(:old, :age).should == 0
        klass.sum(:all, :age).should == 0
      end

      it "when creating two nodes it should add it's ages to the sum" do
        node = klass.new :age => 100
        node = klass.new :age => 1000
        new_tx
        klass.sum(:old, :age).should == 1100
        klass.old.sum(:age).should == 1100
        klass.sum(:all, :age).should == 1100
        klass.all.sum(:age).should == 1100
      end
    end

  end

end
