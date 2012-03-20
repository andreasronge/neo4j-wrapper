require 'neo4j/property/class_methods'

module Neo4j
  module Property

    # Returns a hash of all properties
    # It also include the id of the node with the key <tt>_neo_id</tt>
    #
    def props
      ret = {"_neo_id" => neo_id}
      iter = getPropertyKeys.iterator
      while (iter.hasNext) do
        key = iter.next
        ret[key] = get_property(key)
      end
      ret
    end

    # Returns the unique id of this node.
    # Ids are garbage collected over time so they are only guaranteed to be unique during a specific time span:
    # if the node is deleted, it's likely that a new node at some point will get the old id. Note:
    # this makes node ids brittle as public APIs.
    def neo_id
      getId
    end

    # Returns a hash of properties with keys not starting with <tt>_</tt>
    # That means that the neo_id will not be included in the returned hash.
    #
    def attributes
      attr = props
      ret = {}
      attr.each_pair { |k, v| ret[k] = wrapper.respond_to?(k) ? wrapper.send(k) : v unless k.to_s[0] == ?_ }
      ret
    end

    # Checks if the given key exist as a property.
    def property?(key)
      has_property?(key.to_s)
    end

    # Updates this node/relationship's properties by using the provided struct/hash.
    # If the option <code>{:strict => true}</code> is given, any properties present on
    # the node but not present in the hash will be removed from the node.
    #
    # ==== Parameters
    # struct_or_hash:: the key and value to be set, should respond to <tt>each_pair</tt>
    # options:: further options defining the context of the update, should be a Hash
    #
    # ==== Returns
    # self
    #
    def update(struct_or_hash, options={})
      strict = options[:strict]
      keys_to_delete = props.keys - %w(_neo_id _classname) if strict
      struct_or_hash.each_pair do |key, value|
        next if %w(_neo_id _classname).include? key.to_s
        # do not allow special properties to be mass assigned
        keys_to_delete.delete(key) if strict
        setter_meth = "#{key}=".to_sym
        if @_wrapper && @_wrapper.respond_to?(setter_meth)
          @_wrapper.send(setter_meth, value)
        else
          self[key] = value
        end
      end
      keys_to_delete.each { |key| remove_property(key) } if strict
      self
    end


    # Returns the value of the given key or nil if the property does not exist.
    def [](key)
      return unless property?(key)
      val = get_property(key.to_s)
      val.class.superclass == ArrayJavaProxy ? val.to_a : val
    end

    # Sets the property of this node.
    # Property keys are always strings. Valid property value types are the primitives(<tt>String</tt>, <tt>Fixnum</tt>, <tt>Float</tt>, <tt>FalseClass</tt>, <tt>TrueClass</tt>) or array of those primitives.
    #
    # ==== Gotchas
    # * Values in the array must be of the same type.
    # * You can *not* delete or add one item in the array (e.g. person.phones.delete('123')) but instead you must create a new array instead.
    #
    def []=(key, value)
      k = key.to_s
      if value.nil?
        remove_property(k)
      elsif (Array === value)
        case value[0]
          when NilClass
            set_property(k, [].to_java(:string))
          when String
            set_property(k, value.to_java(:string))
          when Float
            set_property(k, value.to_java(:double))
          when FalseClass, TrueClass
            set_property(k, value.to_java(:boolean))
          when Fixnum
            set_property(k, value.to_java(:long))
          else
            raise "Not allowed to store array with value #{value[0]} type #{value[0].class}"
        end
      else
        set_property(k, value)
      end
    end

  end
end
