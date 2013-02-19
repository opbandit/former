module Nokogiri
  module XML
    class Node
      def traverse_prefix(&block)
        block.call(self)
        children.each{ |j| j.traverse_prefix(&block) }
      end
    end
  end
end
