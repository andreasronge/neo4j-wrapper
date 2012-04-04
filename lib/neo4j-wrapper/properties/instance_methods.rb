module Neo4j
  module Wrapper
    module Property
      module InstanceMethods
        # Return a hash of 'public' properties.
        # If there is an accessor method available it will use that.
        # That means you can override the returned value of the property by implementing a method of the same name
        # as the property. All properteis not starting with <tt>_</tt> are considered public.
        # @return [Hash] hash of properties with keys not starting with <tt>_</tt>
        def attributes
          attr = props
          ret = {}
          attr.each_pair { |k, v| ret[k] = respond_to?(k) ? send(k) : v unless k.to_s[0] == ?_ }
          ret
        end
      end
    end
  end
end
