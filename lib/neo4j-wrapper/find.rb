module Neo4j
  module Wrapper
    module Find
      Neo4j::Core::Index::ClassMethods.send(:alias_method, :_orig_find, :find)

      # If the #ref_node_for_class returns an object implementing the method #_index_prefix it
      # will use that as prefix, otherwise the empty string.
      # @return [String] the prefix name of the index
      def index_prefix
        return "" unless Neo4j.running?
        return "" unless respond_to?(:ref_node_for_class)
        ref_node = ref_node_for_class.wrapper
        prefix = ref_node.send(:index_prefix) if ref_node.respond_to?(:index_prefix)
        prefix ? prefix + "_" : ""
      end


      # @return [String] the name of the index, with index prefix
      def _index_name
        to_s.gsub("::", '_')
      end

      # Fall back to the threadlocal ref node by default.
      # You can set your own reference node using the #ref_node method
      # @return [Neo4j::Node] returns the Neo4j.ref_node
      def ref_node_for_class
        Neo4j.ref_node
      end

      # Assigns the reference node for a class via a supplied block.
      #
      # @example of usage:
      #   class Person
      #     include Neo4j::NodeMixin
      #     ref_node { Neo4j.default_ref_node }
      #   end
      #
      def ref_node(&block)
        singleton = class << self;
          self;
        end
        singleton.send(:define_method, :ref_node_for_class) { block.call }
      end

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
