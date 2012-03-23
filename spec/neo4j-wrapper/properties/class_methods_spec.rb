require 'spec_helper'

describe Neo4j::Wrapper::Property::ClassMethods do

  let(:base) do
    Class.new do
      extend Neo4j::Wrapper::Property::ClassMethods
    end
  end

  let(:sub) do
    s = Class.new(base)
    s.inherited(base)
    s
  end

  context "for a base class" do
    describe "#property :foo" do
      before do
        base.property :foo
      end

      it "has a property" do
        base.property?(:foo).should be_true
      end
    end

    describe "#property :x, :conf1 => 'val1'" do
      before do
        base.property :x, :conf1 => 'val1'
      end

      it "should have configuration for property :x" do
        base._decl_props[:x].should == {:conf1 => 'val1'}
      end
    end

  end

  context "for a subclass" do

    before do
      base.property :baaz
      base.property :y, :conf1 => 'val2'
    end

    it "exist in the base class" do
      base.property?(:baaz).should be_true
    end

    it "should inherit the properties" do
      sub.property?(:baaz).should be_true
    end

    it "does not change the base class properties" do
      sub.property :subp
      base.property?(:subp).should be_false
      sub.property?(:subp).should be_true
    end

    it "inherits configuration properties as well" do
      base._decl_props[:y].should == {:conf1 => 'val2'}
      sub._decl_props[:y].should == {:conf1 => 'val2'}
    end
  end
end
