require 'spec_helper'

describe Neo4j::Wrapper::NodeMixin::Initialize do

  subject do
    klass = Class.new do
      include Neo4j::Wrapper::NodeMixin::Initialize

      def self.to_s
        "MyClass"
      end

      def _java_entity
        @_x ||= {}
      end
    end
    klass.new
  end

  describe "#init_on_create" do
    it "sets the _classname _java_entity property" do
      subject.init_on_create
      subject._java_entity[:_classname].should == "MyClass"
    end

    context "('hej') argument" do
      it "ignores none Hash args" do
        subject.init_on_create('hej')
        subject._java_entity[:_classname].should == "MyClass"
        subject._java_entity.size.should == 1
      end
    end

    context %{{:name => 'a', :age => 4}, "silly" argument"} do
      it "initialize the _java_entity with the given hash" do
#        subject.stub(:_java_entity) { Struct.new(:props).new({:name => 'foo'}) }
        subject.init_on_create({:name => 'a', :age => 4}, "silly")
        subject._java_entity[:_classname].should == "MyClass"
        subject._java_entity[:name].should == 'a'
        subject._java_entity[:age].should == 4
        subject._java_entity.size.should == 3
      end
    end

  end

end