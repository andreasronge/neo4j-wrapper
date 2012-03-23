require 'spec_helper'


describe Neo4j::Wrapper::HasN::DeclRel do

  let(:original_target_class) do
    Class.new do
      def self.to_s
        "OriginalTargetClass"
      end
    end
  end

  let(:new_target_class) do
    Class.new do
      def self.to_s
        "NewTargetClass"
      end
    end
  end

  let(:decl_rel) do
    Neo4j::Wrapper::HasN::DeclRel.new(:friends, false, original_target_class)
  end

  let(:relation_class) do
    Class.new do
      def self.to_s
        "MyRelationship"
      end
    end
  end

  describe "#relationship(a_class)" do
    subject do
      decl_rel.relationship(relation_class)
    end
    its(:relationship_class) { should == relation_class }
  end

  describe "#from" do
    context "from(Symbol)" do
      subject do
        decl_rel.from(:other)
      end

      its(:rel_type) { should == 'other' }
      its(:dir) { should == :incoming }
      its(:target_class) { should == original_target_class }
      its(:source_class) { should == original_target_class }
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

      its(:rel_type) { should == 'FromClass#other' }
      its(:dir) { should == :incoming }
      its(:target_class) { should == from_class }
      its(:source_class) { should == original_target_class }
      it "relationship_class should use the incoming relationship_class" do
        other = Neo4j::Wrapper::HasN::DeclRel.new(:other, false, original_target_class)
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

      its(:rel_type) { should == "bar" }
      its(:dir) { should == :outgoing }
      its(:target_class) { should == original_target_class }
      its(:source_class) { should == original_target_class }
      its(:relationship_class) { should be_nil }
    end

    context "to(Class)" do
      subject do
        decl_rel.to(new_target_class)
      end

      its(:rel_type) { should == "OriginalTargetClass#friends" }
      its(:dir) { should == :outgoing }
      its(:target_class) { should == new_target_class }
      its(:source_class) { should == original_target_class }
      its(:relationship_class) { should be_nil }
    end

  end
end
