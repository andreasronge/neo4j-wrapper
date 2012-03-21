class MockNode

  attr_reader :props

  def initialize
    @@id_counter ||= 0
    @@id_counter += 1
    @id = @@id_counter
    @props = {}
  end

  def getId
    @id
  end

  def set_property(k,v)
    @props[k] = v
  end

  def get_property(k)
    @props[k]
  end

  def has_property?(k)
    @props.include?(k)
  end

  def kind_of?(other)
    other == Java::OrgNeo4jGraphdb::Node || super
  end
end

Neo4j::Node.extend_java_class(MockNode)
