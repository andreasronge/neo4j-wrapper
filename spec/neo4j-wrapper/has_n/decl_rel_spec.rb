require 'spec_helper'
require 'active_support/core_ext/string/inflections'

describe Neo4j::Wrapper::HasN::DeclRel do

  class OriginalTargetClass; end
  class NewTargetClass; end
  class RelationClass; end

  let(:decl_rel) do
    Neo4j::Wrapper::HasN::DeclRel.new(:friends, false, OriginalTargetClass)
  end

  describe "#create_relationship_to" do

    context "outgoing relationship" do
      it "creates a new relationship" do
        from = MockNode.new
        to = MockNode.new
        Neo4j::Relationship.should_receive(:new).with(:friends, from, to)
        decl_rel.create_relationship_to(from, to)
      end
    end

    context "incoming relationship" do
      it "creates a new relationship" do
        from = MockNode.new
        to = MockNode.new
        decl_rel.from(:bla)
        Neo4j::Relationship.should_receive(:new).with(:bla, to, from)
        decl_rel.create_relationship_to(from, to)
      end
    end

    context "a defined relationship class" do
      it "should create a new relationship mixin wrapper" do
        from = MockNode.new
        to = MockNode.new
        rel_wrapper = Class.new
        decl_rel.relationship(rel_wrapper)
        rel_wrapper.should_receive(:new).with(:friends, from, to)
        decl_rel.create_relationship_to(from, to)
      end
    end
  end


  describe "#relationship(a_class)" do
    subject do
      decl_rel.relationship(RelationClass)
    end
    its(:relationship_class) { should == RelationClass }
  end

  describe "#relationship(a_class_string)" do
    subject do
      decl_rel.relationship('RelationClass')
    end
    its(:relationship_class) { should == RelationClass }
  end

  describe "#from" do
    context "from(Symbol)" do
      subject do
        decl_rel.from(:other)
      end

      its(:rel_type) { should == :other }
      its(:dir) { should == :incoming }
      its(:target_class) { should be_nil }
      its(:source_class) { should == OriginalTargetClass }
      its(:relationship_class) { should be_nil }
    end

    context "from(Class, Symbol)" do
      let(:from_class) do
        Class.new do
          def self.to_s
            "FromClass"
          end
        end
      end

      subject do
        decl_rel.from(from_class, :other)
      end

      its(:rel_type) { should == :'FromClass#other' }
      its(:dir) { should == :incoming }
      its(:target_class) { should == from_class }
      its(:source_class) { should == OriginalTargetClass }
      it "relationship_class should use the incoming relationship_class" do
        other = Neo4j::Wrapper::HasN::DeclRel.new(:other, false, OriginalTargetClass)
        other.relationship(Class.new)
        from_decl_rels = {:other => other}
        from_class.should_receive(:_decl_rels).and_return(from_decl_rels)

        subject.relationship_class.should == other.relationship_class
      end
    end

  end

  describe "#to" do

    context "to(symbol)" do
      subject do
        decl_rel.to(:bar)
      end

      its(:rel_type) { should == :bar }
      its(:dir) { should == :outgoing }
      its(:target_class) { should be_nil }
      its(:source_class) { should == OriginalTargetClass }
      its(:relationship_class) { should be_nil }
    end

    context "to(Class)" do
      subject do
        decl_rel.to(NewTargetClass)
      end

      its(:rel_type) { should == :"OriginalTargetClass#friends" }
      its(:dir) { should == :outgoing }
      its(:target_class) { should == NewTargetClass }
      its(:source_class) { should == OriginalTargetClass }
      its(:relationship_class) { should be_nil }
    end

  end
end
