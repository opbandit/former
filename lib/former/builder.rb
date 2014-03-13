require 'nokogiri'

module Former
  class Builder
    class << self; attr_accessor :queries end
    attr_reader :editable

    def initialize(html)
      @html = Nokogiri::HTML.parse(html)

      matches = {}
      self.class.queries.each do |path, qs|
        @html.search(path).each do |node| 
          # if all we need is the text, only include text kids
          if qs.length == 1 and qs.first[:query] == :text
            node.traverse { |e| matches[e] = qs if e.text? and not matches.keys.include? e }
          else
            # otherwise, ignore just text requests
            matches[node] = qs.select { |q| q[:query] != :text }
          end
        end
      end

      @editable = []
      @html.traverse_prefix do |e|
        (matches[e] || []).each do |query|
          if query[:block].nil? or query[:block].call(e)
            @editable << Element.new(e, query[:query], @editable.length, query[:args])
          end
        end
      end
      
      # if we were given text only (no html), nokogiri will helpfully
      # wrap it in a <p> - but our output should just be text.  So remember.
      @nothtml = (@editable.length == 1 and @html.text == html)
    end

    def length
      @editable.length
    end

    def each(&block)
      @editable.each { |e| block.call(e) }
    end

    def to_json
      "[" + @editable.map(&:to_json).join(",") + "]"
    end

    def to_html
      return @html.text if @nothtml
      # nokogiri pads w/ html/body elements
      @html.xpath("/html/body").children.map { |c|
        c.serialize(:save_with => Nokogiri::XML::Node::SaveOptions::AS_HTML).strip
      }.join
    end

    def []=(index, value)
      @editable[index].value = value
    end

    # vals should be { :former_0 => 'value', :former_1 => 'value two', ... }
    def set_values(vals)
      vals.each { |key, value|
        self[key.to_s.split('_').last.to_i] = value
      }
    end

    def self.attr(elem, attr, args=nil, &block)
      @queries ||= {}
      @queries[elem] ||= []
      @queries[elem] << { :query => attr, :block => block, :args => args }
    end
    
    def self.text(*elems, &block)
      attr("text()", :text, &block) if elems.length == 0
      elems.each { |elem| attr(elem, :text, &block) }
    end

    def self.style_url(property, &block)
      attr("[@style]", :style_url, { :property => property }) { |elem|
        elem['style'].include? property and (block_given? ? block.call(elem) : true)
      }
    end
  end
end
