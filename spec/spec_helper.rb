require 'rubygems'
require "bundler/setup"
require 'rspec'
require 'fileutils'
require 'tmpdir'
require 'its'
require 'logger'

require 'neo4j-wrapper'


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }


#unless ENV['TRAVIS'] == 'true'
#  puts "Use test db"
#  Neo4j::Community.load_test_jars!
#  #Neo4j::Core::Database.default_embedded_db = Java::OrgNeo4jTest::ImpermanentGraphDatabase
#  $NEO4J_SERVER = Java::OrgNeo4jTest::ImpermanentGraphDatabase.new
#end

# Config
Neo4j::Config[:logger_level] = Logger::ERROR
Neo4j::Config[:debug_java] = true
EMBEDDED_DB_PATH = File.join(Dir.tmpdir, "neo4j-wrapper-rspec-db")

def embedded_db
  @@db ||= begin
    FileUtils.rm_rf EMBEDDED_DB_PATH
    db = Java::OrgNeo4jKernel::EmbeddedGraphDatabase.new(EMBEDDED_DB_PATH, Neo4j.config.to_java_map)
    at_exit do
      db.shutdown
      FileUtils.rm_rf EMBEDDED_DB_PATH
    end
    db
  end
end

def new_java_tx(db)
  finish_tx if @tx
  @tx = db.begin_tx
end

def finish_tx
  return unless @tx
  @tx.success
  @tx.finish
  @tx = nil
end

def new_tx
  finish_tx if @tx
  @tx = Neo4j::Transaction.new
end

Neo4j::Config[:storage_path] = File.join(Dir.tmpdir, "neo4j_core_integration_rspec")
FileUtils.rm_rf Neo4j::Config[:storage_path]

RSpec.configure do |c|
  c.filter_run_excluding :slow => ENV['TRAVIS'] != 'true'

  c.after(:each, :type => :integration) do
    finish_tx
  end

  c.before(:all, :type => :mock_db) do
    Neo4j.shutdown
    Neo4j::Config[:storage_path] = File.join(Dir.tmpdir, "neo4j_core_integration_rspec")
    FileUtils.rm_rf Neo4j::Config[:storage_path]
    Neo4j::Core::Database.default_embedded_db= MockDb
    Neo4j.start
  end

  c.after(:all, :type => :mock_db) do
    Neo4j.shutdown
    Neo4j::Core::Database.default_embedded_db = nil
  end
end


module TempModel
  @@_counter = 1

  def self.set(klass)
    name = "TestClass_#{@@_counter}"
    @@_counter += 1
    klass.class_eval <<-RUBY
        def self.to_s
          "#{name}"
        end
    RUBY
    klass.send(:include,  Neo4j::NodeMixin) unless klass.kind_of?(Neo4j::NodeMixin)
    Kernel.const_set(name, klass)
    klass
  end
end

def new_node_mixin_class(base_class = Object, &block)
  klass = Class.new(base_class)
  TempModel.set(klass)
  base_class.inherited(klass) if base_class.respond_to?(:inherited)
  klass.class_eval(&block) if block
  klass
end