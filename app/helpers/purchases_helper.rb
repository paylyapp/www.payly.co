module PurchasesHelper
  def cost(amount, currency)
    content_tag :span, :class => "cost" do
      concat(number_to_currency(amount))
      concat(content_tag(:span,currency, :class=>"currency"))
    end
  end
end