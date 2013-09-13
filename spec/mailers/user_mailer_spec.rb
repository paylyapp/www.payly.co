require "spec_helper"

describe UserMailer do
  describe "webhook_error" do
    let(:mail) { UserMailer.webhook_error }

    it "renders the headers" do
      mail.subject.should eq("Webhook error")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
