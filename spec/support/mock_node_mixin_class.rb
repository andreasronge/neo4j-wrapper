module MockNodeMixinClass
  def self.new(klass_name, sub_class = Object)
    klass = Class.new(sub_class)
    klass.class_eval <<-RUBY
    	def self.to_s
    	  "#{klass_name}"
    	end
      include Neo4j::NodeMixin
    RUBY
  end
end
