class UserMailer < ActionMailer::Base
  layout "email"

  default :from => "Tim from Payly <info@payly.co>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.webhook_error.subject
  #
  def webhook_error(code, body, payload, transaction, stack)
    @code = code
    @body = body
    @payload = payload
    @transaction = transaction
    @stack = stack
    mail(:to => stack.seller_email, :subject => "Payly: Webhook error on #{stack.product_name}")
  end
end
