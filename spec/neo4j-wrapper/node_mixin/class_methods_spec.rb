require 'spec_helper'

describe Neo4j::Wrapper::NodeMixin::ClassMethods do


  describe "#new" do
    subject do
      #class MyTest1
      #  class << self
      #    alias_method :_orig_new, :new
      #  end
      #  extend Neo4j::Wrapper::NodeMixin::ClassMethods
      #end
      klass = Class.new do
        class << self
          alias_method :_orig_new, :new
        end
        extend Neo4j::Wrapper::NodeMixin::ClassMethods
      end
      #klass
    end

    it "creates a new node" do
      node = mock("Node")
      Neo4j::Node.stub(:create).and_return(node)
      subject.any_instance.should_receive(:init_on_load).with(node)
      subject.any_instance.should_receive(:init_on_create)
      subject.new.should be_instance_of(subject)
    end

  end

  describe "#get_or_create" do
    subject do
      klass = Class.new do
        extend Neo4j::Wrapper::NodeMixin::ClassMethods
        extend Neo4j::Wrapper::Property::ClassMethods
        extend Neo4j::Core::Index::ClassMethods
        include Neo4j::Wrapper::NodeMixin::Initialize

        def []=(key, value)
          @hash ||= {}
          @hash[key] = value
        end

        def [](key)
          @hash && @hash[key]
        end

        node_indexer do
          index_names :exact => 'unique_node_index_exact'
        end
      end
      TempModel.setup(klass)
      klass
    end

    it "creates a new node if it does not already exist" do
      subject.property :email, :index => :exact, :unique => true
      other = subject.get_or_create(:email => 'kalle2@gmail.com')
      node = subject.get_or_create(:email => 'kalle@gmail.com')
      node.should be_kind_of(subject)
      node._java_node.should_not == other._java_node
    end

    it "returns old node if it does already exist" do
      subject.property :email, :index => :exact, :unique => true
      old_node = subject.get_or_create(:email => 'kalle@gmail.com')
      node = subject.get_or_create(:email => 'kalle@gmail.com')
      node._java_node.should == old_node._java_node
    end

    it "raise an exception if trying to get an entity with no unique key" do
      lambda do
        subject.property :email, :index => :exact, :unique => true
        subject.get_or_create(:phone => '123')
      end.should raise_error
    end

    it "raise an exception there are more then one unique index" do
      lambda do
        subject.property :email, :index => :exact, :unique => true
        subject.property :phone, :index => :exact, :unique => true
        subject.get_or_create(:phone => '123')
      end.should raise_error
    end

  end


end
