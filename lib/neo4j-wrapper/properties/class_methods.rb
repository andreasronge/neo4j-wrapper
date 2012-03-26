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
        # The generated accessor is a simple wrapper around the #[] and
        # #[]= operators.
        #
        # === Types
        # If a property is set to nil the property will be removed.
        # A property can be of any primitive type (Boolean, String, Fixnum, Float) and does not
        # even have to be the same. Arrays of primitive types is also supported. Array values must
        # be of the same type and are mutable, e.g. you have to create a new array if you want to change one value.
        #
        # === Index
        # You can declare a lucene index on the property like this:
        #
        # @example a property with an index
        #
        #   class Foo
        #     include Neo4j::NodeMixin
        #     property :description, :index => :fulltext
        #   end
        #
        # The <tt>:index</tt> parameter above can have to values. <tt>:fulltext</tt> and <tt>:exact</tt>
        # When the property is updated/deleted/created the lucene index will be changed.
        # If an index has been declared you can query the class.
        #
        # @example Lucene Query
        #   Foo.find("description: bla", :type => :fulltext)
        #   Foo.find(:description =>  "bla", :type => :fulltext)
        #
        # Notice that if you are using fulltext index you <b>must</b> specify the type parameter in the find method
        # (<tt>:exact</tt> is default).
        # Also, if you want to sort or do range query make sure use the same query parameters as the declared type
        # For example if you index with <tt>property :age, :index => :exact, :type => Fixnum)</tt> then you must query
        # with age parameter being a fixnum.
        #
        # @example Lucene Query Range
        #   Foo.find(:age =>  35)
        #   Foo.find("age: 35") # does not work !
        #
        # @see http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/TypeConverters Neo4j::Core::IndexClassMethods
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
        # You can write your own converter by writing a class that respond to <tt>:convert?</tt>, <tt>:to_ruby</tt> and
        # <tt>:to_java</tt> in the Neo4j::TypeConverters module.
        #
        # @param [Symbol, Hash] props one or more properties and optionally last a Hash for options
        # @see http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/TypeConverters Neo4j::TypeConverters
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
          Neo4j::TypeConverters::DefaultConverter unless prop_conf
          prop_conf[:converter]
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