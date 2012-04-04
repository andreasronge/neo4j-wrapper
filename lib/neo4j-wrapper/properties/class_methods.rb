module Neo4j
  module Wrapper
    module Property

      module ClassMethods

        # @return [Hash] a hash of all properties and its configuration defined by property class method
        def _decl_props
          @_decl_props ||= {}
        end

        # make sure the inherited classes inherit the <tt>_decl_props</tt> hash
        def inherited(klass)
          klass.instance_variable_set(:@_decl_props, _decl_props.clone)
          super
        end

        # Generates accessor method and sets configuration for Neo4j node properties.
        # The generated accessor creates a wrapper around the <tt>#[]</tt> and <tt>#[]=</tt> operators and
        # support conversion of values before it is read or written to the database, using the <tt>:type</tt> config parameter.
        # If a property is set to nil the property will be removed (just like the <tt>#[]=</tt>accessor])
        # A lucene index can also be specified, using the <tt>:index</tt> config parameter.
        # If you want to add index on a none declared property you can (still) use the <tt>index</tt> class method, see
        # {Neo4j::Core::Index::Indexer}[http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Core/Index/Indexer]
        #
        # === :type
        # A property can be of any primitive type (Boolean, String, Fixnum, Float)
        # and does not even have to be the same. Arrays of primitive types is also supported. Array values must
        # be of the same type and are mutable, e.g. you have to create a new array if you want to change one value.
        # To make sure a property is always stored as the same type you can use the TypeConverter, which is specified using
        # either the <tt>:type</tt> or the <tt>:converter</tt> parameter. This is also important when indexing, e.g finding a
        # property which has been declared as a Fixnum but queried as a String will not work.
        #
        # === :converter
        # You can implement your own converter, see Neo4j::TypeConverters.
        # You can write your own converter by writing a class that respond to <tt>:index_as</tt>, <tt>:to_ruby</tt> and
        # <tt>:to_java</tt>.
        #
        # === :index
        # If a <tt>:index</tt> is specified the property will be automatically indexed.
        # By default, there are two different indices available: <tt>:fulltext</tt> and <tt>:exact</tt>
        # If not specified in a query it will use by default an <tt>:exact</tt> index.
        # Notice, that you can't combine a fulltext and exact lucene query in the same query.
        # If you are using fulltext index you <b>must</b> specify the type parameter in the find method
        # (<tt>:exact</tt> is default).
        # Also, if you want to sort or do range query make sure use the same query parameters as the declared type
        # For example if you index with <tt>property :age, :index => :exact, :type => Fixnum)</tt> then you must query
        # with age parameter being a fixnum, see examples below.
        #
        # @example a property with an index
        #
        #   class Foo
        #     include Neo4j::NodeMixin
        #     property :description, :index => :fulltext
        #   end
        #
        # @example Lucene Query
        #   Foo.find("description: bla", :type => :fulltext)
        #   Foo.find({:description =>  "bla"}, {:type => :fulltext})
        #
        # @example Lucene Query with a Fixnum index
        #   Foo.find(:age =>  35)
        #   Foo.find(:age =>  (32..37))
        #   Foo.find("age: 35") # does not work !
        #
        # === More Examples
        #
        # @example declare a property
        #   class Foo
        #     include Neo4j::NodeMixin
        #     property :age
        #   end
        #
        # @example use a declared property
        #   foo = Foo.new
        #   foo.age = "hej" # first set it to string
        #   foo.age = 42  # change it to a Fixnum
        #
        # However, you can specify an type for the index, see Neo4j::Index::Indexer#index
        #
        # @example conversion of none primitive types
        #
        #   class Foo
        #     include Neo4j::NodeMixin
        #     property :since, :type => DateTime  # will be converted into a fixnum
        #   end
        #
        # @example declare several properties in one line
        #
        #   class Foo
        #     include Neo4j::NodeMixin
        #     property :name, :description, :type => String, :index => :exact
        #   end
        #
        # @param [Symbol, Hash] props one or more properties and optionally last a Hash for options
        # @see Neo4j::TypeConverters
        # @see http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Core/Index/LuceneQuery Neo4j::Core::Index::LuceneQuery
        # @see http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Core/Index/Indexer Neo4j::Core::Index::Indexer
        def property(*props)
          options = props.last.kind_of?(Hash) ? props.pop : {}

          props.uniq.each do |prop|
            pname = prop.to_sym
            _decl_props[pname] ||= {}
            options.each { |key, value| _decl_props[pname][key] = value }

            converter = options[:converter] || Neo4j::TypeConverters.converter(_decl_props[pname][:type])
            _decl_props[pname][:converter] = converter

            if options.include?(:index)
              index(pname, :type => options[:index], :field_type => converter.index_as)
            end

            define_method(pname) do
              self.class._converter(pname).to_ruby(self[pname])
            end

            name = (pname.to_s() +"=").to_sym
            define_method(name) do |value|
              self[pname] = self.class._converter(pname).to_java(value)
            end
          end
        end


        # @param [String, Symbol] prop_name the name of the property
        # @return [#to_java, #to_ruby, #field_type] a converter for the given property name
        # @note if the property has not been defined it will return the DefaultConverter
        # @see Neo4j::TypeConverters::DefaultConverter
        def _converter(prop_name)
          prop_conf = _decl_props[prop_name.to_sym]
          (prop_conf && prop_conf[:converter]) || Neo4j::TypeConverters::DefaultConverter
        end

        # Returns true if the given property name has been defined with the class
        # method property or properties.
        #
        # Notice that the node may have properties that has not been declared.
        # It is always possible to set an undeclared property on a node.
        #
        # @return [true, false]
        def property?(prop_name)
          return false if _decl_props[prop_name.to_sym].nil?
          !_decl_props[prop_name.to_sym].nil?
        end
      end
    end
  end
end