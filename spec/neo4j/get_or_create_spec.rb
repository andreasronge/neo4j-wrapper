require 'spec_helper'

describe Neo4j::NodeMixin, "get_or_create", :type => :integration do

  let(:clazz) do
    new_node_mixin_class do
      property :foo
      property :email, :index => :exact, :unique => true
    end
  end

  context "no running transaction" do
    before(:each) do
      finish_tx
    end
    it "should create a new node if it does not exist" do
      node = clazz.get_or_create(:email => 'jimmy2@gmail.com')
      node.email.should == 'jimmy2@gmail.com'
    end

    it "should return existing node if it already exists" do
      node = clazz.get_or_create(:email => 'jimmy@gmail.com', :foo => 42)
      node.foo.should == 42

      # when
      node2 = clazz.get_or_create(:email => 'jimmy@gmail.com', :foo => 123)
      node2.foo.should == 42
    end
  end

end