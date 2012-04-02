require 'spec_helper'

describe "Multitenancy", :type => :integration do

  let(:domain_class) do
    new_node_mixin_class do
      def index_prefix
        self[:name]
      end
    end
  end

  let(:node_class) do
    new_node_mixin_class do
      property :name, :index => :exact
    end
  end

  before(:each) { new_tx}
  after(:each) { finish_tx; Neo4j.threadlocal_ref_node= Neo4j.default_ref_node}

  describe "find" do
    it "only finds nodes if the right domain was used" do
      n1 = node_class.new(:name => 'n1')
      new_tx
      node_class.find(:name => 'n1').first.should == n1

      # new domain
      domain = domain_class.new(:name => 'a')
      Neo4j.threadlocal_ref_node= domain
      node_class.find(:name => 'n1').first.should be_nil
      n2 = node_class.new(:name => 'n2')
      new_tx
      node_class.find(:name => 'n2').first.should == n2

      # old domain
      Neo4j.threadlocal_ref_node= Neo4j.default_ref_node
      node_class.find(:name => 'n1').first.should == n1
      node_class.find(:name => 'n2').first.should be_nil
    end
  end
end
