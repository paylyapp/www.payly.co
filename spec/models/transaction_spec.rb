require 'spec_helper'

describe Transaction do
  describe "webhooks" do
    it "should call webhook url at the completion of a transaction"
    it "should be a HTTP POST request"

    describe "data-sent" do
      it "should send email"
      it "should send full_name"
      it "should send price"
      it "should send visibile to public"
      it "should send custom fields"
      it "should send shipping details"
    end

    describe "data received" do
      it "should return a 200"
      it "should be text/plain"
      it "should have a body that contains json"

      describe "json" do
        it "should contain a status"
        it "should contain a text"
      end

      describe "timeout" do
        it "should email the buyer saying that the seller will be in contact shortly"
        it "should email the seller with all the details sent and received"
      end
    end
  end
end
