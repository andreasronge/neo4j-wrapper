require 'spec_helper'


describe Neo4j::Wrapper::Rule::Rule do

  let(:model_class) do
    new_node_mixin_class
  end

  let(:sub_model_class) do
    new_node_mixin_class(model_class)
  end

  describe "add" do
    it "stores the rule" do
      rule = Neo4j::Wrapper::Rule::Rule.add(model_class, "sum", {})
      rule_node = Neo4j::Wrapper::Rule::Rule.rule_node_for(model_class)
      rule_node.find_rule('sum').should == rule
    end
  end

  describe "inherit" do
    it "inherit all functions from the base class" do
      Neo4j::Wrapper::Rule::Rule.add(model_class, "sum", {})
      Neo4j::Wrapper::Rule::Rule.add(model_class, "count", {})
      Neo4j::Wrapper::Rule::Rule.inherit(model_class, sub_model_class)
      sub = Neo4j::Wrapper::Rule::Rule.rule_node_for(sub_model_class)
      sub.rules.map(&:rule_name).should =~ %w[sum count]
      base = Neo4j::Wrapper::Rule::Rule.rule_node_for(model_class)
      base.rules.map(&:rule_name).should =~ %w[sum count]
    end
  end

end