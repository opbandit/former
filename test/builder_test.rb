require 'test/unit'
require 'former'

class Parser < Former::Builder
  attr "a.important", :href
  attr("img", :src)
  text "p", "a.important"
end

class BuilderTest < Test::Unit::TestCase
  def setup
    @html_txt = '<p>some text<a class="important" href="http://alink.com">some link text<img src="/an/image/path"></a>last text</p>'
    @parser = Parser.new @html_txt
  end

  def test_parsing
    assert_equal @parser.editable.length, 5
  end

  def test_building
    assert_equal @parser.to_html, @html_txt
    new_html_txt = '<p>some new text<a class="important" href="http://alink.com">some link text<img src="/an/image/path"></a>last text</p>'
    @parser[0] = "some new text"
    assert_equal @parser.to_html, new_html_txt

    # now set it back
    @parser.set_values :former_0 => "some text"
    @parser = Parser.new @html_txt
  end
end
