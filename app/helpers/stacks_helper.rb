module StacksHelper
  def options_for_stack_charge_type(default_state)
    options_for_select( [
                          ["Fixed price", "fixed"],
                          ["Any price", "any"]
                        ],
                        default_state )
  end
  def options_for_stack_visibility(default_state)
    options_for_select( [
                          ["Anyone can view", "true"],
                          ["Hidden", "false"]
                        ],
                        default_state )
  end
  def options_for_stack_surcharge_type(default_state)
    options_for_select( [
                          ["%", "percentage"],
                          ["$", "dollar"]
                        ],
                        default_state )
  end
  def options_for_stack_charge_currency(default_state)
    options = []

    options << ["A$", "AUD", {:"data-currency-symbol"=>"$"}]
    if current_user.entity.payment_provider_is_pin_payments?
      options << ["US$", "USD", {:"data-currency-symbol"=>"$"}]
    elsif current_user.entity.payment_provider_is_pin_payments?
      options << ["US$", "USD", {:"data-currency-symbol"=>"$"}]
    end

    options_for_select( options, default_state )
  end

  def stats(transactions)
    count = transactions.count
    cost = 0
    transactions.each do |transaction|
      cost += transaction.transaction_amount
    end

    stats = {:count => count, :cost => cost}

    stats
  end
end
