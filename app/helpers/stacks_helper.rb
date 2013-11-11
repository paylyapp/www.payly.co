module StacksHelper
  def options_for_stack_charge_type(default_state)
    options_for_select( [['Fixed price', 'fixed'], ['Any price', 'any']],
                        default_state )
  end
  def options_for_stack_visibility(default_state)
    options_for_select( [['Anyone can view', 'true'], ['Hidden', 'false']],
                        default_state )
  end
  def options_for_stack_surcharge_type(default_state)
    options_for_select( [['%', 'percentage'], ['$', 'dollar']],
                        default_state )
  end
end
