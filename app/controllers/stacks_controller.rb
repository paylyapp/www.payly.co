class StacksController < ApplicationController
  layout "transactions"

  def download
    transaction = Transaction.find_by_transaction_token(params[:token])

    if transaction.nil?
      render "page/error"
    else
      if transaction.stack.has_digital_download
        # request.headers['Content-Transfer-Encoding'] = 'binary'
        # request.headers['Content-Type'] = transaction.stack.digital_download_file_content_type
        # request.headers['Content-Description'] = 'File Transfer'
        # request.headers['Content-Disposition'] = 'attachment; filename= ' + transaction.stack.digital_download_file_file_name
        redirect_to transaction.stack.digital_download_file.expiring_url(600)
      else
        render "page/error"
      end
    end
  end
end

