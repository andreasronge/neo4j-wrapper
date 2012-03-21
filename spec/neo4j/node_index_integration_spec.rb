require 'spec_helper'

describe "Neo4j::NodeMixin index", :type => :integration do

  let(:klass_name) { 'Foo123::Bar' }
  let(:klass) { MockNodeMixinClass.new(klass_name) }

  context "class Foo123::Bar - index :foo" do
    subject do
      klass.index :foo
      klass
    end

    its(:index?, :foo) { should be_true }
    its(:index_type, :foo) { should == :exact }
    its(:to_s) { should == "Foo123::Bar" }
    its(:index_name_for_type, :exact) { should == "Foo123_Bar_exact" }
    its(:_indexer) { should be_kind_of(Neo4j::Core::Index::Indexer) }

    describe "find" do
      it "can be found" do
        new_tx
        node = subject.new(:name => 'andreas', :foo => 'bar')
        finish_tx
        subject.find('foo: bar').first.should == node
      end

      it "is not found if it's been deleted" do
        new_tx
        node = subject.new(:name => 'andreas', :foo => 'hejhopp')
        finish_tx
        subject.find('foo: hejhopp').first.should == node
        new_tx
        node.del
        finish_tx
        subject.find('foo: hejhopp').first.should be_nil
      end

    end

    context "A Base class with one index and a sub klass with one index" do
      class BaseKlass1
        include Neo4j::NodeMixin
        index :base_foo
      end

      class SubClass1 < BaseKlass1
        index :sub_foo
      end

      it "should inherit index" do
        SubClass1.index?(:sub_foo).should be_true
        SubClass1.index?(:base_foo).should be_true
        SubClass1.index_name_for_type(:exact).should == "SubClass1_exact"
      end

      it "should not change the base class" do
        BaseKlass1.index?(:sub_foo).should be_false
        BaseKlass1.index?(:base_foo).should be_true
        SubClass1.index_name_for_type(:exact).should == "SubClass1_exact"
      end

      it "can not find base class nodes using subclass index" do
        new_tx
        node = BaseKlass1.new(:sub_foo => 'foo', :base_foo => 'foo')
        finish_tx
        BaseKlass1.find('base_foo: foo').first.should == node
        BaseKlass1.find('sub_foo: foo').first.should be_nil

        SubClass1.find('base_foo: foo').first.should be_nil
        SubClass1.find('sub_foo: foo').first.should be_nil
      end

      it "can find any sub class using base class index" do
        new_tx
        node = SubClass1.new(:sub_foo => 'foo2', :base_foo => 'foo2')
        finish_tx
        SubClass1.find('base_foo: foo2').first.should == node
        SubClass1.find('sub_foo: foo2').first.should == node
        BaseKlass1.find('base_foo: foo2').first.neo_id.should == node.neo_id
        BaseKlass1.find('base_foo: foo2').first.should == node
        BaseKlass1.find('sub_foo: foo2').first.should be_nil
      end

      it "should return the correct class" do
        pending
        new_tx
        node = SubClass1.new(:sub_foo => 'foo3', :base_foo => 'foo3')
        finish_tx
        BaseKlass1.find('base_foo: foo3').first.class.should == node.class
      end

    end

    context "A Base class with no index and a sub klass with one index" do
      class BaseKlass2
        include Neo4j::NodeMixin
      end

      class SubClass2 < BaseKlass2
        index :sub_foo
      end

      it "should inherit index" do
        SubClass2.index?(:sub_foo).should be_true
        SubClass2.index?(:base_foo).should be_false
      end

      it "should not change the base class" do
        BaseKlass2.index?(:sub_foo).should be_false
        BaseKlass2.index?(:base_foo).should be_false
      end
    end

    context "A Base class with one index and a sub klass with no index" do
      class BaseKlass3
        include Neo4j::NodeMixin
        index :foo
      end

      class SubClass3 < BaseKlass3
      end

      it "should inherit index" do
        SubClass3.index?(:foo).should be_true
        BaseKlass3.index?(:foo).should be_true
      end
    end

  end
end

