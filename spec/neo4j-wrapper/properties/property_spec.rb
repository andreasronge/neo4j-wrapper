require 'spec_helper'


describe Neo4j::Wrapper::Property do

  describe "property with no type converter" do
    let(:klass) do
      Class.new(Hash) do
        extend Neo4j::Wrapper::Property::ClassMethods
        extend Neo4j::Core::Index::ClassMethods
        property :myprop
      end
    end

    subject { klass.new }
    it "can set the property and read the property" do
      subject.myprop = 42
      subject[:myprop].should == 42
    end
  end

  describe "property with type converter" do
    let(:klass) do
      Class.new(Hash) do
        extend Neo4j::Wrapper::Property::ClassMethods
        extend Neo4j::Core::Index::ClassMethods

        property :myprop, :type => :fixnum
      end
    end

    subject { klass.new }

    it "uses the type converter" do
      subject.myprop = "42"
      subject[:myprop].should == 42
    end

  end

  describe "property with custom type converter" do
    class MyConverter
      class << self
        def to_java(val)
          "TO_JAVA #{val}"
        end

        def to_ruby(val)
          "TO_RUBY #{val}"
        end
      end
    end

    let(:klass) do
      Class.new(Hash) do
        extend Neo4j::Wrapper::Property::ClassMethods
        extend Neo4j::Core::Index::ClassMethods

        property :myprop, :converter => MyConverter
      end
    end

    subject { klass.new }

    it "uses the type converter" do
      subject.myprop = "42"
      subject[:myprop].should == "TO_JAVA 42"
      subject.myprop.should == "TO_RUBY TO_JAVA 42"
    end

  end
end
