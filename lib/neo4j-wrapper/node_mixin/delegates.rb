module Neo4j
  module Wrapper
    module NodeMixin
      module Delegates

        class << self
          private
          # @macro  [new] node.delegate
          #   @method $1(*args, &block)
          #   Delegates the `$1` message to <tt>_java_entity</tt> instance with the supplied parameters.
          #   @see Neo4j::NodeMixin#_java_entity
          #   @see http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Node Neo4j::Core::Node#$1
          def delegate(method_name)
            class_eval(<<-EOM, __FILE__, __LINE__)
              def #{method_name}(*args, &block)
                _java_entity.send(:#{method_name}, *args, &block)
              end
            EOM
          end
        end

        # @macro  node.delegate
        delegate :[]=

        # @macro  node.delegate
        delegate :[]

        # @macro  node.delegate
        delegate :property?

        # @macro  node.delegate
        delegate :props

        # @macro  node.delegate
        delegate :update

        # @macro  node.delegate
        delegate :neo_id

        # @macro  node.delegate
        delegate :rels

        # @macro  node.delegate
        delegate :rel?

        # @macro  node.delegate
        delegate :node

        # @macro  node.delegate
        delegate :to_param

        # @macro  node.delegate
        delegate :getId

        # @macro  node.delegate
        delegate :rel

        # @macro  node.delegate
        delegate :del

        # @macro  node.delegate
        delegate :list?

        # @macro  node.delegate
        delegate :outgoing

        # @macro  node.delegate
        delegate :incoming

        # @macro  node.delegate
        delegate :both

        # @macro  node.delegate
        delegate :expand

        # @macro  node.delegate
        delegate :get_property

        # @macro  node.delegate
        delegate :set_property

        # @macro  node.delegate
        delegate :equal?

        # @macro  node.delegate
        delegate :eql?

        # @macro  node.delegate
        delegate :==

        # @macro  node.delegate
        delegate :exist?

        # @macro  node.delegate
        delegate :rel

        # @macro  node.delegate
        delegate :wrapped_entity

        # @macro  node.delegate
        delegate :_node

        # @macro  node.delegate
        delegate :_rels
      end
    end
  end
end
