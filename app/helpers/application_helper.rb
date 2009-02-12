# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def anonymize_appropriately(&block)
    out = capture(&block)
    concat(out, block.binding) unless session[:anonymize]
  end
end
