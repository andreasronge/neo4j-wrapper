module Neo4j
  module Wrapper
    module HasN
      # The {Neo4j::Wrapper::HasN::ClassMethods} generates has_n relationship accessor methods.
      module InstanceMethods
        def _decl_rels_for(rel_type)
          self.class._decl_rels[rel_type]
        end
      end
    end
  end
end
