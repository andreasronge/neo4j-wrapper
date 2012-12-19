require 'spec_helper'

describe "Date and Time converters" do

  # TODO: Add more specs, especially for time-zones!!!!

  describe "Date" do
    subject { Neo4j::TypeConverters::DateConverter }

    its(:convert?, Date)      { should be_true }
    its(:convert?, :date)     { should be_true }
    its(:convert?, DateTime)  { should be_false }
    its(:convert?, :datetime) { should be_false }
    its(:convert?, Time)      { should be_false }
    its(:convert?, :time)     { should be_false }

    its(:to_java, nil)        { should be_nil }
    its(:to_ruby, nil)        { should be_nil }
  end


  describe "Time" do
    subject { Neo4j::TypeConverters::TimeConverter }

    its(:convert?, Time)      { should be_true }
    its(:convert?, :time)     { should be_true }
    its(:convert?, DateTime)  { should be_false }
    its(:convert?, :datetime) { should be_false }

    its(:to_java, nil)        { should be_nil }
    its(:to_ruby, nil)        { should be_nil }
  end


  describe "DateTime" do
    before(:each) do
      @dt = 1352538487
      @hr = 3600
    end

    subject { Neo4j::TypeConverters::DateTimeConverter }

    its(:convert?, DateTime)  { should be_true }
    its(:convert?, :datetime) { should be_true }
    its(:convert?, Date)      { should be_false }
    its(:convert?, :time)     { should be_false }

    its(:to_java, nil)        { should be_nil }
    its(:to_ruby, nil)        { should be_nil }

    its(:to_java, DateTime.parse("2012-11-10T09:08:07-06:00")) { should === @dt + 6*@hr }
    its(:to_java, DateTime.parse("2012-11-10T09:08:07-04:00")) { should === @dt + 4*@hr }
    its(:to_java, DateTime.parse("2012-11-10T09:08:07-02:00")) { should === @dt + 2*@hr }
    its(:to_java, DateTime.parse("2012-11-10T09:08:07+00:00")) { should === @dt }
    its(:to_java, DateTime.parse("2012-11-10T09:08:07+02:00")) { should === @dt - 2*@hr }
    its(:to_java, DateTime.parse("2012-11-10T09:08:07+04:00")) { should === @dt - 4*@hr }
    its(:to_java, DateTime.parse("2012-11-10T09:08:07+06:00")) { should === @dt - 6*@hr }
  end

end
