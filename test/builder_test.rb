require 'test/unit'
require 'former'

class Parser < Former::Builder
  attr "a.important", :href
  attr("img", :src)
  text "p", "a.important"
end

class AllTextParser < Former::Builder
  attr "a.important", :href
  attr("img", :src)
  text
end

class AllTextParserNotBlank < Former::Builder
  attr "a.important", :href
  attr("img", :src)
  text { |e| not e.text.strip.empty? }
end

class BuilderTest < Test::Unit::TestCase
  def setup
    @html_txt = '<p>some text<a class="important" href="http://alink.com">some link text<img src="/an/image/path"></a>last text</p>'
    @parser = Parser.new @html_txt
  end

  def test_ignore_blank_fields
    p = AllTextParserNotBlank.new "<p>\n</p><h1>  </h1><p> some text </p>"
    assert_equal p.length, 1
    p[0] = "other text"
    assert_equal "<p>\n</p><h1>  </h1><p>other text</p>", p.to_html

    p = AllTextParserNotBlank.new "<p>\n</p><h1>  </h1> some text <p></p>"
    assert_equal p.length, 1
    p[0] = "other text"
    assert_equal "<p>\n</p><h1>  </h1>other text<p></p>", p.to_html
  end

  def test_nohtml
    p = Parser.new "some text that is long, and contains stuff!"
    p.set_values :former_0 => "some other text"
    assert_equal p.to_html, "some other text"
  end

  def test_parsing
    assert_equal @parser.editable.length, 5

    html = '<img src="http://blah.com/example.jpg" /><p>This is some text</p>This is some more text'
    json = [
            { "value" => "http://blah.com/example.jpg", "nodename" => "img", "attr" => "src"},
            { "value" => "This is some text", "nodename" => "text"}
           ]
    assert_equal JSON.parse(Parser.new(html).to_json), json

    # now, test with parsing all text (which will include the last bit now)
    json << { "value" => "This is some more text", "nodename" => "text" }
    assert_equal JSON.parse(AllTextParser.new(html).to_json), json
  end

  def test_building
    assert_equal @parser.to_html, @html_txt
    new_html_txt = '<p>some new text<a class="important" href="http://alink.com">some link text<img src="/an/image/path"></a>last text</p>'
    @parser[0] = "some new text"
    assert_equal @parser.to_html, new_html_txt

    # now set it back
    @parser.set_values :former_0 => "some text"
    assert_equal @parser.to_html, @html_txt
  end
end
