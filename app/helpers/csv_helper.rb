module CsvHelper
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
                "shipping_address_line1",
                "shipping_address_line2",
                "shipping_address_city",
                "shipping_address_postcode",
                "shipping_address_state",
                "shipping_address_country",
                'created_at'
              ]
    csv_columns = ["ID",
              "Charge ID",
              "Amount",
              "Name",
              "Email",
              "Shipping Type",
              "Shipping Address 1",
              "Shipping Address 2",
              "shipping Address City",
              "shipping Address Postcode",
              "shipping Address State",
              "shipping Address Country",
              "Created At"
            ]
    CSV.generate(:col_sep => ";", :row_sep => "\r\n", :headers => true, :write_headers => true, :return_headers => true) do |csv|
      csv << csv_columns
      transactions.each do |p|
        csv << columns.collect{ |name|
          p.send(name)
        }
      end
    end
  end
end
