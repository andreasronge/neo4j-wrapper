module Neo4j
  module NodeMixin
    include Neo4j::Wrapper::NodeMixin::Delegates
    # @return the Neo4j::Node object that this instance wraps
    def _java_entity

    end


  end
end