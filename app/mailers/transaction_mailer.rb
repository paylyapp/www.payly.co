class TransactionMailer < ActionMailer::Base
  default :from => "Tim from Payly <info@payly.co>"

  def invoice(transaction)
    @transaction = transaction
    bcc_email = transaction.stack_bcc_receipt == true ? transaction.stack_seller_email : ''
    mail(:to => transaction.buyer_email, :bcc => bcc_email, :reply_to => transaction.stack_seller_email, :subject => "Invoice for #{transaction.stack_product_name}. ID: #{transaction.transaction_token}")
  end

  def recipet(transaction)
    @transaction = transaction
    bcc_email = transaction.stack_bcc_receipt == true ? transaction.stack_seller_email : ''
    mail(:to => transaction.buyer_email, :bcc => bcc_email, :reply_to => transaction.stack_seller_email, :subject => "Payment receipt for #{transaction.stack_product_name}. ID: #{transaction.transaction_token}")
  end

  def updated(transaction)
    @transaction = transaction
    mail(:to => transaction.buyer_email, :reply_to => transaction.stack_seller_email, :subject => "#{transaction.stack_product_name}: A new file is ready to be downloaded")
  end
end
