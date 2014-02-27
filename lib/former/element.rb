require 'action_view'
require 'json'

module Former
  class Element
    include ActionView::Helpers::TagHelper
    attr_reader :node, :query, :block

    def initialize(node, query, index, block)
      @node = node
      @query = query
      @block = block
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

    def to_form_html
      name = "former_#{@index}"
      return @block.call(@node, name) unless @block.nil?
      value = (@query == :text) ? @node.text : @node[@query]
      tag(:input, :type => 'text', :name => name, :value => value)
    end

    def set_value(value)
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
