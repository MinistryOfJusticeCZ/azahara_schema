module Arel
  module Predications
    def contains(right)
      Arel::Nodes::Contains.new(self, quoted_node(right))
    end
  end

  class Nodes::Contains < Nodes::Binary
    def operator; :"@>" end
  end

  class Visitors::PostgreSQL
    private
    def visit_Arel_Nodes_Contains o, collector
      infix_value o, collector, " #{Nodes::Contains.new(nil, nil).operator} "
    end
  end

end
