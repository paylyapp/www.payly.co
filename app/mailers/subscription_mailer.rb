class SubscriptionMailer < ActionMailer::Base
  default from: "from@example.com"

  def seller_failed_transaction(subscription)
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  def buyer_failed_transaction(subscription)
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  def new_subscription(subscription)
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  def destroy_subscription(subscription)
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
