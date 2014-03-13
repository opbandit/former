require 'json'
require 'csspool'

module Former
  class Element
    attr_reader :node, :query

    def initialize(node, query, index, args=nil)
      @node = node
      @query = query
      @index = index
      @args = args || {}
    end

    def to_json
      h = { 
        :value => value,
        :nodename => @node.name
      }
      h[:attr] = @query unless (@query == :text or @query == :style_url)
      h.to_json
    end

    def value
      if @query == :text
        @node.text
      elsif @query == :style_url
        style_url(@node['style']) { |exp| return exp.value }
      else
        @node[@query]
      end
    end

    def value=(value)
      if @query == :text
        @node.content = value
      elsif @query == :style_url
        @node['style'] = style_url(@node['style']) { |exp| exp.value = value }
      else
        @node[@query] = value
      end
    end

    def to_html
      @node.to_html
    end

    private

    def style_url(rules)
      begin
        rset = CSSPool.CSS("e { #{rules} }").rule_sets.first
        decs = rset.declarations.select { |d| d.property == @args[:property] }
        decs.each do |dec|
          dec.expressions.select { |e| e.is_a? CSSPool::Terms::URI }.each { |d| yield d }
        end
        css = rset.to_minified_css
        css.slice(4, css.length - 6)
      rescue Racc::ParseError
        rules
      end
    end
  end
end
