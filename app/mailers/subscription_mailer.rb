class SubscriptionMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.subscription_mailer.seller_failed_transaction.subject
  #
  def seller_failed_transaction(subscription)
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.subscription_mailer.buyer_failed_transaction.subject
  #
  def buyer_failed_transaction(subscription)
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.subscription_mailer.new_subscription.subject
  #
  def new_subscription(subscription)
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  def destroy_subscription(subscription)
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
