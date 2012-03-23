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
  end

  context "for a subclass" do

    before do
      base.property :baaz
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
  end
end
