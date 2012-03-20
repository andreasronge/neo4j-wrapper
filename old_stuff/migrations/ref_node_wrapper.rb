module Neo4j

  module Migrations
    # This node stores the migrations for Neo4j.migrations
    # Uses the Neo4j.ref_node for keeping the current version of the db.
    # When the database starts it will check if it needs to run a migration.
    class RefNodeWrapper
      extend ClassMethods

      class << self
        def migrate!(version=nil)
          _migrate!(self, Neo4j.ref_node, version)
        end

        def db_version
          Neo4j.ref_node[:_db_version] || 0
        end

        # Remote all migration and set migrate_to = nil and set the current version to nil
        def reset_migrations!
          @migrations = nil
          @migrate_to = nil
          Neo4j::Transaction.run do
            Neo4j.ref_node[:_db_version] = nil
          end
        end
      end
    end

  end

end