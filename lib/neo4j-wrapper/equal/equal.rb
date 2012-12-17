module Neo4j
  module Wrapper

    # == This mixin is used for both nodes and relationships to decide if two entities are equal or not.
    #
    module Equal

      # check that this and the other node is both the same class and has the same node/relationship id.
      def eql?(other_node)
        other_node.respond_to?(:neo_id) && neo_id == other_node.neo_id
      end

      alias == eql?

    end
  end

end