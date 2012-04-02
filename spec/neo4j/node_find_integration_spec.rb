require 'spec_helper'

describe Neo4j::NodeMixin, "find", :type => :integration do

  before(:each) { new_tx }
  after(:each) { finish_tx }

  let(:vehicle_class) do
    new_node_mixin_class do
      property :wheels, :type => Fixnum, :index => :exact
      property :built_date, :type => Date
      property :name, :type => String, :index => :exact
      property :weight, :type => Float, :index => :exact
    end
  end

  let(:car_class) do
    new_node_mixin_class(vehicle_class) do
      property :brand, :index => :fulltext
      property :colour, :type => String, :index => :exact
    end
  end

  context "with type conversion: property :year, :type => Fixnum" do
    let(:klass) do
      new_node_mixin_class do
        property :year, :type => Fixnum, :index => :exact
        property :month, :day, :type => Fixnum, :index => :exact
        property :day, :type => Fixnum, :index => :exact

        def to_s
          "Year #{year}"
        end
      end
    end


    before(:each) do
      @x49 = klass.new(:year => 49, :month => 1, :day => 11)
      @x50 = klass.new(:year => 50, :month => 2, :day => 12)
      @x51 = klass.new(:year => 51, :month => 3, :day => 13)
      @x52 = klass.new(:year => 52, :month => 4, :day => 14)
      @x53 = klass.new(:year => 53, :month => 5, :day => 15)
      new_tx
    end


    it "find(:year => 50) does work because year is declared as a Fixnum" do
      res = klass.find(:year => 50) #.between(45,45,true,true)
      res.first.should == @x50
    end

    it "find(:year => 50..52) returns all integer between 50 and 52" do
      res = [*klass.find(:year => 50..52)]
      res.should_not include(@x49, @x53)
      res.should include(@x50, @x51, @x52)
    end

    it "find(:year => 50...52) returns all integer between 50 and 51" do
      res = [*klass.find(:year => 50...52)]
      res.should include(@x50, @x51)
      res.should_not include(@x49, @x52, @x53)
    end

    it "find(:month=> 2..5, :day => 11...14) finds nodes matching both conditions" do
      res = [*klass.find(:month => 2..5, :day => 11...14)]
      res.should include(@x50, @x51)
      res.should_not include(@x49, @x52, @x53)
    end

  end


  context "on arrays of properties" do
    let(:klass) do
      new_node_mixin_class do
        property :items, :index => :exact
      end
    end

    it "should index all values in the array" do
      node = klass.new :items => %w[hej hopp oj]
      new_tx
      result = klass.find('items: hej')
      result.size.should == 1
      result.should include(node)

      result = klass.find('items: hopp')
      result.size.should == 1
      result.should include(node)

      result = klass.find('items: oj')
      result.size.should == 1
      result.should include(node)
    end

    it "when an item in the array is removed it should not be found" do
      node = klass.new :items => %w[hej hopp oj]
      new_tx
      #node.items.delete('hopp') # does not work
      node.items = %w[hej oj]
      new_tx

      result = klass.find('items: hej')
      result.size.should == 1
      result.should include(node)

      result = klass.find('items: hopp')
      result.size.should == 0

      result = klass.find('items: oj')
      result.size.should == 1
      result.should include(node)
    end


  end


  context "hash queries, find(hash)" do

    before(:each) do
      @bike = vehicle_class.new(:name => 'bike', :wheels => 2)
      @car = vehicle_class.new(:name => 'car', :wheels => 4)
      @old_bike = vehicle_class.new(:name => 'old bike', :wheels => 2)
      new_tx
    end

    it "find(:name => 'bike', :wheels => 2)" do
      vehicle_class.find(:name => 'bike', :wheels => 2).to_a.should =~ [@bike]
    end

    it "find({}) should return nothing" do
      vehicle_class.find({}).should be_empty
    end

    it "find(:name => 'bike').and(:wheels => 2) should return same thing as find(:name => 'bike', :wheels => 2)" do
      vehicle_class.find(:name => 'bike').and(:wheels => 2).to_a.should =~ [@bike]
    end

    it "find(:name => 'bike').or(:name => 'car') should return bike and car" do
      vehicle_class.find(:name => 'bike').or(:name => 'car').to_a.should =~ [@bike, @car]
    end

    it "find(:name => 'bike').or(:wheels => 4) should return bike and car" do
      vehicle_class.find(:name => 'bike').or(:wheels => 4).to_a.should =~ [@bike, @car]
    end

    it "find(:wheels => 2).not(:name => 'bike') should return only 'old bike'" do
      vehicle_class.find(:wheels => 2).not(:name => 'bike').to_a.should =~ [@old_bike]
    end

    it "find(:wheels => 2).or(:wheels => 4).not(:name => 'old bike') should return bike and car" do
      vehicle_class.find(:wheels => 2).or(:wheels => 4).not(:name => 'old bike').to_a.should =~ [@bike, @car]
    end

    it "find(:wheels => 2).not(:name => 'old bike').not(:name => 'bike') should return nothing" do
      vehicle_class.find(:wheels => 2).not(:name => 'old bike').not(:name => 'bike').should be_empty
    end
  end

  context "range queries, index :name, :type => String" do
    let(:klass) do
      new_node_mixin_class do
        property :name, :type => String
        index :name
      end
    end

    before(:each) do
      @bike = klass.new(:name => 'bike')
      @car = klass.new(:name => 'car')
      @old_bike = klass.new(:name => 'old bike')
      new_tx
    end

    it "find(:name).between('f', 'q')" do
      result = [*klass.find(:name).between('f', 'q')]
      result.should include(@old_bike)
      result.size.should == 1
    end

    it "find(:name).between(5.0, 10.0).asc(:name)" do
      result = [*klass.find(:name).between('a', 'z').asc(:name)]
      result.size.should == 3
      result.should == [@bike, @car, @old_bike]
    end

    it "find(:name).between(5.0, 10.0).desc(:name)" do
      result = [*klass.find(:name).between('a', 'z').desc(:name)]
      result.size.should == 3
      result.should == [@old_bike, @car, @bike]
    end
  end

  context "range queries, index :weight; property :weight, :type => Float" do
    let(:klass) do
      new_node_mixin_class do
        property :weight, :type => Float, :index => :exact
        property :name, :index => :exact
      end
    end

    before(:each) do
      @bike = klass.new(:name => 'bike', :weight => 9.23)
      @car = klass.new(:name => 'car', :weight => 1042.99)
      @old_bike = klass.new(:name => 'old bike', :weight => 21.42)
      new_tx
    end

    it "find(:weight).between(5.0, 10.0)" do
      result = [*klass.find(:weight).between(5.0, 10.0)]
      result.should include(@bike)
      result.size.should == 1
    end

    it "find(:weight).between(5.0, 10.0).asc(:weight)" do
      result = [*klass.find(:weight).between(1.0, 10000.0).asc(:weight)]
      result.should == [@bike, @old_bike, @car]
      result.size.should == 3
    end

    it "find(:weight).between(5.0, 10.0).desc(:weight)" do
      result = [*klass.find(:weight).between(1.0, 10000.0).desc(:weight)]
      result.should == [@car, @old_bike, @bike]
      result.size.should == 3
    end

    it "find(:weight).between(5.0, 100000.0).and(:name).between('a', 'd')" do
      result = [*klass.find(:weight).between(5.0, 100000.0).and(:name).between('a', 'd')]
      result.size.should == 2
      result.should include(@bike, @car)
    end
  end

  context "range queries, index :items; property :items, :type => Fixnum" do
    let(:klass) do
      klass = new_node_mixin_class do
        property :items, :type => Fixnum, :index => :exact
        property :name, :index => :exact
      end
    end

    before(:each) do
      @bike = klass.new(:name => 'bike', :items => 9)
      @car = klass.new(:name => 'car', :items => 1042)
      @old_bike = klass.new(:name => 'old bike', :items => 21)
      new_tx
    end

    it "find(:items).between(5, 10)" do
      @bike.items.should == 9
      @bike.items.class.should == Fixnum
      @bike._java_node.get_property('items').class.should == Fixnum
      result = [*klass.find(:items).between(5, 10)]
      result.should include(@bike)
      result.size.should == 1
    end

    it "find(:items).between(5, 10).asc(:items)" do
      result = [*klass.find(:items).between(1, 10000).asc(:items)]
      result.should == [@bike, @old_bike, @car]
      result.size.should == 3
    end

    it "find(:items).between(5, 10).desc(:items)" do
      result = [*klass.find(:items).between(1, 10000).desc(:items)]
      result.should == [@car, @old_bike, @bike]
      result.size.should == 3
    end

    it "find(:items).between(5, 100000).and(:name).between('a', 'd')" do
      result = [*klass.find(:items).between(5, 100000).and(:name).between('a', 'd')]
      result.size.should == 2
      result.should include(@bike, @car)
    end

  end

  context "string queries" do

    let(:klass) do
      new_node_mixin_class do
        property :city, :index => :exact
      end
    end

    it "#index should add an index" do
      n = klass.new(:city => 'malmoe')
      new_tx
      klass.find('city: malmoe').first.should == n
    end

    it "#index should keep the index in sync with the property value" do
      n = klass.new
      n[:city] = 'malmoe'
      new_tx
      n[:city] = 'stockholm'
      new_tx
      klass.find('city: malmoe').first.should_not == n
      klass.find('city: stockholm').first.should == n
    end

    it "can index and search on two properties if index has the same type" do
      c = car_class.new(:wheels => 4, :colour => 'blue')
      new_tx
      vehicle_class.find(:wheels => 4).size.should == 1
      car_class.find(:wheels => 4).size.should == 1
      car_class.find('colour: blue').size.should == 1
      car_class.find(:colour => 'blue').size.should == 1
      car_class.find('colour: "blue"').size.should == 1
      car_class.find('colour: "blue"').and(:wheels => 4).first.should be_kind_of(vehicle_class)
      car_class.find('colour: blue').and(:wheels => 4).first.should be_kind_of(car_class)
      car_class.find('colour: blue').and(:wheels => 4).should include(c)
    end

    it "can not found if searching on two indexes of different type" do
      c = car_class.new(:brand => 'Saab Automobile AB', :wheels => 4, :colour => 'blue')
      new_tx
      car_class.find('brand: "Saab"', :type => :fulltext).should include(c)
      car_class.find('brand:"Saab" AND wheels: "4"', :type => :exact).should_not include(c)
    end

    it "does allow superclass searching on a subclass" do
      c = car_class.new(:wheels => 4, :colour => 'blue')
      new_tx
      car_class.find(:wheels => 4).first.should == c
      vehicle_class.find(:wheels => 4).first.should == c
    end

    it "doesn't use the same index for a subclass" do
      bike = vehicle_class.new(:brand => 'monark', :wheels => 2)
      volvo = car_class.new(:brand => 'volvo', :wheels => 4)

      # then
      new_tx
      car_class.find('brand: volvo', :type => :fulltext).first.should == volvo
      car_class.find({:wheels => 4}, {:type => :exact}).first.should == volvo
      vehicle_class.find(:wheels => 2).first.should == bike
      car_class.find(:wheels => 2).first.should be_nil
    end

    it "returns an empty Enumerable if not found" do
      car_class.find(:wheels =>999).first.should be_nil
      car_class.find(:wheels =>999).should be_empty
    end

    it "will remove the index when the node is deleted" do
      c = car_class.new(:brand => 'Saab Automobile AB', :wheels => 4, :colour => 'blue')
      new_tx
      vehicle_class.find(:wheels =>4).should include(c)

      # when
      c.del
      new_tx

      # then
      car_class.find('wheels:"4"').should_not include(c)
      vehicle_class.find('colour:"blue"').should_not include(c)
      vehicle_class.find('wheels:"4" AND colour: "blue"').should_not include(c)
    end


    it "should work when inserting a lot of data in a single transaction" do
      # Much much fast doing inserting in one transaction
      100.times do |x|
        Neo4j::Node.new
        car_class.new(:brand => 'volvo', :wheels => x)
      end
      new_tx


      100.times do |x|
        car_class.find(:wheels => x).should_not be_empty
      end
    end
  end

  context "sorting on date" do
    it "should sort on date" do
      clazz = new_node_mixin_class do
        property :date_property, :type => Date
        index :date_property
      end
      first_date = clazz.new(:date_property => Date.new(1902, 1, 1))
      second_date = clazz.new(:date_property => Date.new(2002, 1, 1))
      third_date = clazz.new(:date_property => Date.new(2012, 1, 1))
      new_tx
      result = [*clazz.find("date_property: *").desc(:date_property)]
      result.should == [third_date, second_date, first_date]
    end

    it "should sort on date_time" do
      clazz = new_node_mixin_class do
        property :date_property, :type => DateTime
        index :date_property
      end
      first_date = clazz.new(:date_property => DateTime.new(1902, 1, 1, 10, 30))
      second_date = clazz.new(:date_property => DateTime.new(2002, 1, 1, 11, 30))
      third_date = clazz.new(:date_property => DateTime.new(2012, 1, 1, 12, 30))
      new_tx
      result = [*clazz.find("date_property: *").desc(:date_property)]
      result.should == [third_date, second_date, first_date]
    end

    it "should sort on time" do
      clazz = new_node_mixin_class do
        property :date_property, :type => Time
        index :date_property
      end
      first_date = clazz.new(:date_property => Time.utc(1902, 1, 1, 1, 2, 0))
      second_date = clazz.new(:date_property => Time.utc(2002, 1, 1, 1, 2, 0))
      third_date = clazz.new(:date_property => Time.utc(2012, 1, 1, 1, 2, 0))
      new_tx
      result = [*clazz.find("date_property: *").desc(:date_property)]
      result.should == [third_date, second_date, first_date]
    end
  end
end
