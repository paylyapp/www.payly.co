module CsvHelper
  include ActionView::Helpers::NumberHelper

  def user_purchases_to_csv(user)
    user = User.find(user.id)
    transactions = user.transactions()
    purchases_to_csv(transactions)
  end

  def stack_purchases_to_csv(stack)
    stack = Stack.find(stack.id)
    transactions = stack.transactions
    purchases_to_csv(transactions)
  end

  def purchases_to_csv(transactions)
    columns = [ 'transaction_token',
                'charge_token',
                'transaction_amount',
                'buyer_name',
                'buyer_email',
                'shipping_cost_term',
                'shipping_cost',
                "shipping_address_line1",
                "shipping_address_line2",
                "shipping_address_city",
                "shipping_address_postcode",
                "shipping_address_state",
                "shipping_address_country",
                "custom_field",
                'created_at'
              ]
    csv_columns = ["ID",
              "Charge ID",
              "Amount",
              "Name",
              "Email",
              "Shipping Type",
              "Shipping Cost",
              "Shipping Address 1",
              "Shipping Address 2",
              "Shipping Address City",
              "Shipping Address Postcode",
              "Shipping Address State",
              "Shipping Address Country",
              "Custom Fields",
              "Created At"
            ]
    CSV.generate(:col_sep => ";", :row_sep => "\r\n", :headers => true, :write_headers => true, :return_headers => true) do |csv|
      csv << csv_columns
      transactions.each do |transaction|
        csv << columns.collect{ |name|
          if name == 'custom_field'
            custom_fields = []
            unless transaction.custom_data_term.blank?
              transaction.custom_data_term.each_index do |index|
                custom_field = {}
                custom_field[:"#{transaction.custom_data_term[index]}"] = transaction.custom_data_value[index]
                custom_fields << custom_field
              end
            end
            custom_fields.to_json
          else
            transaction.send(name)
          end
        }
      end
    end
  end
end
