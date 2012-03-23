module Neo4j
  module Wrapper
    module Property

      module ClassMethods

        def _decl_props
          @_decl_props ||= {}
        end

        def inherited(klass)
          klass.instance_variable_set(:@_decl_props, _decl_props.clone)
          super
        end

        # Generates accessor method and sets configuration for Neo4j node properties.
        # The generated accessor is a simple wrapper around the #[] and
        # #[]= operators.
        #
        # ==== Types
        # If a property is set to nil the property will be removed.
        # A property can be of any primitive type (Boolean, String, Fixnum, Float) and does not
        # even have to be the same. Arrays of primitive types is also supported. Array values must
        # be of the same type and are mutable, e.g. you have to create a new array if you want to change one value.
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
            options.each do |key, value|
              _decl_props[pname][key] = value
            end

            define_method(pname) do
              Neo4j::TypeConverters.to_ruby(self.class, pname, self[pname])
            end

            name = (pname.to_s() +"=").to_sym
            define_method(name) do |value|
              self[pname] = Neo4j::TypeConverters.to_java(self.class, pname, value)
            end
          end
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