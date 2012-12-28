module Neo4j

  # = Neo4j Identity Map
  #
  # Ensures that each object gets loaded only once by keeping every loaded
  # object in a map. Looks up objects using the map when referring to them.
  #
  # More information on Identity Map pattern:
  #   http://www.martinfowler.com/eaaCatalog/identityMap.html
  #
  # The identity map cache is cleared after each transaction. When used from rails the Rack Middle ware
  # will also make sure that the cache is emptied after each request.
  #
  # When used from batch import scripts (e.g. Rake) you should probably disable the identity map,
  # because the identity map cache will not be used (the same object is not loaded more than once).
  # If not used from rails and transactions does not occur then the cache will never be cleared and
  # you will have a memory leak.
  #
  # == Configuration
  #
  # In order to enable IdentityMap, set <tt>config.neo4j.identity_map = true</tt>
  # in your <tt>config/application.rb</tt> file. If used outside rails, set Neo4j::Config[:identity_map] = true.
  #
  module IdentityMap

    class << self
      def enabled=(flag)
        Thread.current[:neo4j_identity_map] = flag
      end

      def enabled
         Thread.current[:neo4j_identity_map] == true
      end

      alias enabled? enabled

      def node_repository
        Thread.current[:node_identity_map] ||= java.util.HashMap.new
      end

      def rel_repository
        Thread.current[:rel_identity_map] ||= java.util.HashMap.new
      end

      def repository_for(neo_entity)
        return nil unless enabled?
        if neo_entity.class == Neo4j::Node
          node_repository
        elsif neo_entity.class == Neo4j::Relationship
          rel_repository
        else
          nil
        end
      end

      def use
        old, self.enabled = enabled, true
        yield if block_given?
      ensure
        self.enabled = old
        clear
      end

      def without
        old, self.enabled = enabled, false
        yield if block_given?
      ensure
        self.enabled = old
      end

      def get(neo_entity)
        r = repository_for(neo_entity)
        r && r.get(neo_entity.neo_id)
      end

      def add(neo_entity, wrapped_entity)
        r = repository_for(neo_entity)
        r && r.put(neo_entity.neo_id, wrapped_entity)
      end

      def remove(neo_entity)
        r = repository_for(neo_entity)
        r && r.remove(neo_entity.neo_id)
      end

      def remove_node_by_id(node_id)
        node_repository.remove(node_id)
      end

      def remove_rel_by_id(rel_id)
        rel_repository.remove(rel_id)
      end

      def clear
        node_repository.clear
        rel_repository.clear
      end

      def on_after_commit(*)
        clear
      end

      def on_neo4j_started(db)
        if !Neo4j::Config[:identity_map] && !enabled
          db.event_handler.remove(self)
        end
      end

    end

  end
end

Neo4j.unstarted_db.event_handler.add(Neo4j::IdentityMap)

