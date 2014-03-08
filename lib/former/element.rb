require 'json'

module Former
  class Element
    attr_reader :node, :query

    def initialize(node, query, index)
      @node = node
      @query = query
      @index = index
    end

    def to_json
      h = { 
        :value => (@query == :text) ? @node.text : @node[@query],
        :nodename => @node.name
      }
      h[:attr] = @query unless @query == :text
      h.to_json
    end

    def value
      @query == :text ? @node.content : @node[@query]
    end

    def value=(value)
      if @query == :text
        @node.content = value
      else
        @node[@query] = value
      end
    end

    def to_html
      @node.to_html
    end
  end
end
