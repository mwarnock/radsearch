module SearchHelper
  def highlight_words(search_terms, &block)
    search_terms = search_terms.split(" ") if search_terms.class == String
    search_terms = sanatize_terms(search_terms)
    text = capture(&block)
    search_terms.each do |term|
      text.gsub!(/ *#{Regexp.escape(term)}(?=\s|\W)/i, " " + highlight(term))
    end
    concat(text, block.binding)
  end

  def highlight(term)
    content_tag(:span, term, :class => "highlight")
  end

  def format_report(report)
    report.gsub(/\n|\r/, "<br />")
  end

  def reason_checkbox(reason)
    "<td>" + content_tag(:span, reason.titleize, :class => "form-element-heading", :style => "margin-left: 20px;") + "</td><td>" + check_box(:reason_for, reason) + "</td>"
  end

  def sanatize_terms(terms)
    terms.collect do |term|
      term.gsub!(/^[-+]/, "")
      term.gsub!("\"","")
      term
    end
  end
end
