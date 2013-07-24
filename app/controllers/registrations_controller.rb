class RegistrationsController < Devise::RegistrationsController

  def update
    params[:user].delete(:password) if params[:user][:password].blank?
    params[:user].delete(:password_confirmation) if params[:user][:password].blank?

    if current_user.update_attributes(params[:user])
      sign_in :user, current_user, :bypass => true
      redirect_to user_settings_path
    else
      clean_up_passwords(current_user)
      redirect_to user_settings_path
    end
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    '/signup/thank-you'
  end

end