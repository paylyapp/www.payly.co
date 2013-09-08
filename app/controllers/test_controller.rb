class TestController < ApplicationController

  def testing
    render :bad_request, :json => {'status' => 'error'}
  end

end
