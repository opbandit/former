require 'nokogiri'

module Former
  class Builder
    attr_reader :editable

    def initialize(html)
      @html = Nokogiri::HTML.parse(html)

      matches = {}
      @@queries.each { |path, qs|
        @html.search(path).each { |node| 
          # if all we need is the text, only include text kids
          if qs.length == 1 and qs.first[:query] == :text
            node.traverse { |e| matches[e] = qs if e.text? and not matches.keys.include? e }
          else
            # otherwise, ignore just text requests
            matches[node] = qs.select { |q| q[:query] != :text }
          end
        }
      }

      @editable = []
      @html.traverse_prefix { |e|
        (matches[e] || []).each { |query| 
          @editable << Element.new(e, query[:query], @editable.length, query[:block]) 
        }
      }
    end

    def each(&block)
      @editable.each { |e| block.call(e) }
    end

    def to_form_html
      @editable.map { |e| e.to_form_html }.join("\n")
    end

    def to_html
      # nokogiri pads w/ xhtml/body elements
      @html.search("//body").first.children.first.to_html
    end

    def []=(index, value)
      @editable[index].set_value value
    end

    # vals should be { :former_0 => 'value', :former_1 => 'value two', ... }
    def set_values(vals)
      vals.each { |key, value|
        self[key.to_s.split('_').last.to_i] = value
      }
    end

    def self.attr(elem, attr, &block)
      @@queries ||= {}
      @@queries[elem] ||= []
      @@queries[elem] << { :query => attr, :block => block }
    end
    
    def self.text(*elems, &block)
      elems.each { |elem| attr(elem, :text, &block) }
    end
  end
end
