module Neo4j
  module Wrapper
    module Find
      Neo4j::Core::Index::ClassMethods.send(:alias_method, :_orig_find, :find)

      # Overrides the Neo4j::Core::Index::ClassMethods#find method to check
      # if any of the query parameters needs to be converted, (e.g. DateTime to Fixnum)
      #
      # @example
      #   Person.find(:since => (1.year.ago .. Time.now))
      # @see http://rdoc.info/github/andreasronge/neo4j-core/Neo4j/Core/Index/Indexer#find-instance_method Neo4j::Core::Index::ClassMethods#find
      def find(*query_params)
        query = query_params.first
        if query.is_a?(Hash)
          query.each_pair do |k, v|
            converter = _converter(k)
            value = v.is_a?(Range) ? Range.new(converter.to_java(v.begin), converter.to_java(v.end), v.exclude_end?) : converter.to_java(v)
            query[k] = value
          end
        end
        _orig_find(*query_params)
      end

    end
  end
end
