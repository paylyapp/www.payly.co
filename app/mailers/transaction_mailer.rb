class TransactionMailer < ActionMailer::Base
  default :from => "Tim @ Payly <notice@payly.co>"

  def invoice(transaction)
    @transaction = transaction
    bcc_email = transaction.stack.bcc_receipt == true ? transaction.stack.user.email : ''
    mail(:to => transaction.buyer_email, :bcc => bcc_email, :subject => "Invoice for #{transaction.stack.product_name}. ID: #{transaction.transaction_token}")
  end

  def recipet(transaction)
    @transaction = transaction
    bcc_email = transaction.stack.bcc_receipt == true ? transaction.stack.user.email : ''
    mail(:to => transaction.buyer_email, :bcc => bcc_email, :subject => "Payment recipet for #{transaction.stack.product_name}. ID: #{transaction.transaction_token}")
  end
end
