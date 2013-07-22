require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should not save post without data" do
    transaction = Transaction.new
    assert !transaction.save, "Transaction will not save without data"
  end
end
