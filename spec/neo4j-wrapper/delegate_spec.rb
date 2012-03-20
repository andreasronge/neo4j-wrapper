require 'spec_helper'

describe Neo4j::Wrapper::NodeMixin::Delegates do

  subject do
    klass = Class.new do
      include Neo4j::Wrapper::NodeMixin::Delegates
    end
    klass.new
  end

  it "delegates calls to the _java_entity" do
    subject.stub(:_java_entity) { Struct.new(:props).new({:name => 'foo'}) }
    subject.props.should == {:name => 'foo'}
  end

end