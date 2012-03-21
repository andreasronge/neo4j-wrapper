require 'spec_helper'

describe "Neo4j::NodeMixin index", :type => :integration do


  context "index :foo" do
    subject do
      Class.new do
        def self.to_s
          "Foo123::Bar"
        end
        include Neo4j::NodeMixin
        index :foo
      end
    end


    its(:index?, :foo) { should be_true }
    its(:index_type, :foo) { should == :exact }
    its(:to_s) { should == "Foo123::Bar" }
    its(:index_name_for_type, :exact) { should == "Foo123_Bar_exact" }

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
  end

end