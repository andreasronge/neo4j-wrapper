require 'spec_helper'

describe Neo4j::Wrapper::NodeMixin::Delegates do

  describe "Neo4j::NodeMixin delegates" do

    subject do
      klass = Class.new do
        include Neo4j::Wrapper::NodeMixin::Delegates
      end
      klass.new
    end

    it "can use the Neo4j::Wrapper::Delegate" do
      subject.stub(:_java_entity) { Struct.new(:props).new({:name => 'foo'}) }
      subject.props.should == {:name => 'foo'}
    end
  end


end