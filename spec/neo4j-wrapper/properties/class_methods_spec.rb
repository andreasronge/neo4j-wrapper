require 'spec_helper'

describe Neo4j::Wrapper::Property::ClassMethods do

  let(:base) do
    Class.new do
      extend Neo4j::Wrapper::Property::ClassMethods
      extend Neo4j::Core::Index::ClassMethods

      node_indexer do
        index_names :exact => "Foo44_exact", :fulltext => "Foo44_fulltext"
        trigger_on :_classname => self.to_s
      end

      def self.to_s
        "Foo44"
      end
    end
  end

  let(:sub) do
    s = Class.new(base)
    s.inherited(base)
    s
  end

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
      base._decl_props[:x][:conf1].should == 'val1'
    end

    it "should have a default converter" do
      base._decl_props[:x][:converter].should == Neo4j::TypeConverters::DefaultConverter
    end

  end

  describe "#property :y, :type => Fixnum, :index => :exact" do
    before do
      base.property :y, :type => Fixnum, :index => :exact
    end

    it "creates an index configuration" do
      base._indexer.config.field_type('y').should == Fixnum
    end

    it "specifies a FixnumConverter converter" do
      base._decl_props[:y][:converter].should == Neo4j::TypeConverters::FixnumConverter
    end
  end

  describe "#property :z, :converter => MyConverter" do
    it "can use any converter" do
      base.property :z, :converter => 'MyConverter'
      base._decl_props[:z][:converter].should == 'MyConverter'
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
      base._decl_props[:y][:conf1].should == 'val2'
      sub._decl_props[:y][:conf1].should == 'val2'
    end
  end
end
