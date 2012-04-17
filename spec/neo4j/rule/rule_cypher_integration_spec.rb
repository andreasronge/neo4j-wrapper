#require 'spec_helper'
#
#class Monster
#  include Neo4j::NodeMixin
#  property :age
#  rule :all
#  rule(:dangerous) { |m| m[:strength] > 15}
#end
#
#class Dungeon
#  include Neo4j::NodeMixin
#  has_n(:monsters).to(Monster)
#end
#
#class Room
#  include Neo4j::NodeMixin
#  has_n(:monsters).to(Monster)
#end
#
#describe "cypher queries for and has_n", :type => :integration do
#
#  before(:all) do
#    new_tx
#    @basilisk = Monster.new(:strength => 17, :name => 'Basilisk')
#    @bugbear = Monster.new(:strength => 13, :name => 'Bugbear')
#    @ghost = Monster.new(:strength => 10, :name => 'Ghost')
#
#    @treasure_room = Room.new(:name => 'Treasure Room')
#    @guard_room = Room.new(:name => 'Guard Room')
#
#    @dungeon = Dungeon.new
#    @dungeon.monsters << @basilisk << @bugbear << @ghost
#
#    @treasure_room.monsters << @basilisk
#    @guard_room.monsters << @bugbear << @ghost
#    finish_tx
#  end
#
#  pending
#
#  describe "dungeon.monsters(:name => 'Ghost', :strength => 10)" do
#    it "uses cypher" do
#      @dungeon.monsters(:name => 'Ghost', :strength => 10).first[:strength].should == 10
#    end
#  end
#
#  describe "dungeon.monsters.query(:name => 'Ghost', :strength => 10)" do
#    it "uses cypher" do
#      @dungeon.monsters.query(:name => 'Ghost', :strength => 10).first[:strength].should == 10
#    end
#  end
#
#  describe "dungeon.monsters{|m| m > 8}" do
#    it "uses cypher" do
#      @dungeon.monsters { |m| m[:strength] > 16 }.first[:strength].should == 17
#    end
#  end
#
#  describe "dungeon.monsters{|m| m.incoming(Room.monsters}[:name] == 'Treasure Room'" do
#    it "uses cypher" do
#      @dungeon.monsters { |m| (m.incoming(Room.monsters)[:name] == 'Guard Room') & (m[:strength] > 12) }.first.should == @bugbear
#      # Same as (!)
#      # START n0=node(6) MATCH (n0)-[:`Dungeon#monsters`]->(default_ret),(default_ret)<-[:`Room#monsters`]-(v1) WHERE (v1.name = "Guard Room") and (default_ret.strength > 12) RETURN default_ret'
#    end
#  end
#
#  describe "Monster.all(:strength => 17)" do
#
#    it "uses cypher" do
#      #Monster.all(:strength => 17).first.should == @basilisk
#      puts "RET #{Monster.all(:strength => 17).class}"
#      #Monster.all(:strength => 17){|x| x.distinct}.to_a.size.should == 1
#      #Monster.dangerous(:strength => 17).to_a.size.should == 1
#      #Monster.dangerous.query.count.should == 1
#
#      rule_node = Neo4j::Wrapper::Rule::Rule.rule_node_for(Monster)
#      puts "rule_node=#{rule_node.inspect}, #{rule_node}"
#      rule_node.rules.each {|r| puts "Rule #{r.rule_name.inspect}"}
#      proc = Proc.new{|m| m[:bla?] == 123}
#      @dungeon.monsters.dangerous.to_a.size.should == 1
#      @dungeon.monsters.dangerous{|m| m[:weapon?] == 'sword'}.to_a.size.should == 1
#
#      #@dungeon.monsters{|m| m.incoming(:dangerous); instance_exec(m, &proc)}.count.should == 1
#    end
#  end
#
#  #describe "all.query method" do
#  #  it "uses cypher" do
#  #    new_tx
#  #    a = Monster.new(:age => 1)
#  #    b = Monster.new(:age => 3)
#  #    c = Monster.new(:age => 2)
#  #    finish_tx
#  #
#  #    Monster.all.should include(a,b,c)
#  #    Monster.all.query.should include(a,b,c)
#  #    Monster.all.query { |m| m[:age] == 3 }.first[:age].should == 3
#  #  end
#  #end
#
#end