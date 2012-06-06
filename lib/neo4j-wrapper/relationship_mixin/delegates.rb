module Neo4j
  module Wrapper
    module RelationshipMixin
      module Delegates

        class << self
          private
          # @macro  [new] node.delegate
          #   @method $1(*args, &block)
          #   Delegates to {http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Core/$2#$1-instance_method Neo4j::Core::Relationship#$1} using the <tt>_java_entity</tt> instance with the supplied parameters.
          #   @see Neo4j::Relationship#_java_entity
          #   @see http://rdoc.info/github/andreasronge/neo4j-core/master/Neo4j/Core/$2#$1-instance_method Neo4j::Relationship#$1
          def delegate(*args)
            method_name = args.first
            class_eval(<<-EOM, __FILE__, __LINE__)
              def #{method_name}(*args, &block)
                _java_entity.send(:#{method_name}, *args, &block)
              end
            EOM
          end
        end


        # Methods included from Core::Property
        # [], #[]=, #neo_id, #property?, #props, #update

        # @macro  node.delegate
        delegate :[]=, 'Property'

        # @macro  node.delegate
        delegate :[], 'Property'

        # @macro  node.delegate
        delegate :property?, 'Property'

        # @macro  node.delegate
        delegate :props, 'Property'

        # @macro  node.delegate
        delegate :update, 'Property'

        # @macro  node.delegate
        delegate :neo_id, 'Property'

        # Methods included from Core::Relationship

        # @macro  node.delegate
        delegate :_end_node, 'Relationship'

        # @macro  node.delegate
        delegate :end_node, 'Relationship'


        # @macro  node.delegate
        delegate :_start_node, 'Relationship'

        # @macro  node.delegate
        delegate :start_node, 'Relationship'

        # @macro  node.delegate
        delegate :end_node, 'Relationship'

        # @macro  node.delegate
        delegate :other_node, 'Relationship'

        # @macro  node.delegate
        delegate :_other_node, 'Relationship'

        # @macro  node.delegate
        delegate :del, 'Relationship'

        # @macro  node.delegate
        delegate :exist?, 'Relationship'

        # @macro  node.delegate
        delegate :rel_type, 'Relationship'

        # Methods included from Core::Property::Java
        #get_property, #graph_database, #property_keys, #remove_property, #set_property

        # @macro  node.delegate
        delegate :get_property, 'Property/Java'

        # @macro  node.delegate
        delegate :set_property, 'Property/Java'

        # @macro  node.delegate
        delegate :property_keys, 'Property/Java'

        # @macro  node.delegate
        delegate :remove_property, 'Property/Java'

        # Methods included from Core::Equal
        #==, #eql?, #equal?

        # @macro  node.delegate
        delegate :equal?, 'Equal'

        # @macro  node.delegate
        delegate :eql?, 'Equal'


        # @macro  node.delegate
        delegate :==

        # @macro  node.delegate
        delegate :getId
      end

    end
  end
end

