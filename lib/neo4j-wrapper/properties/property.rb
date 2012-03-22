module Neo4j
  module Wrapper
    module Property
      # @return [Hash] a hash of properties with keys not starting with <tt>_</tt>
      def attributes
        attr = props
        ret = {}
        attr.each_pair { |k, v| ret[k] = wrapper.respond_to?(k) ? wrapper.send(k) : v unless k.to_s[0] == ?_ }
        ret
      end
    end
  end
end