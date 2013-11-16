class Entity::UserController < ApplicationController
  layout "entity"
  before_filter :authenticate_user!

  def profile
    @current_section = 'profile'

    entity_token = params[:entity_token] || current_user.entity.entity_token
    @entity = Entity.find_by_entity_token(entity_token)
  end

  def payment_provider
    @current_section = 'payment_provider'

    entity_token = params[:entity_token] || current_user.entity.entity_token
    @entity = Entity.find_by_entity_token(entity_token)
  end

  def update_profile
    entity = params[:entity]
    entity[:entity_name] = entity[:full_name]
    entity_token = params[:entity_token]
    @entity = Entity.find_by_entity_token(entity_token)

    if @entity.update_attributes(params[:entity])
      redirect_to user_profile_path
    else
      render :settings
    end
  end

  def update_payment_provider
    entity = params[:entity]
    entity_token = params[:entity_token]
    @entity = Entity.find_by_entity_token(entity_token)

    if @entity.update_attributes(entity)
      redirect_to user_payment_provider_path
    else
      render :settings
    end
  end

  def settings
    @current_section = 'settings'
    @user = User.find(current_user)
  end

  def dashboard
    @current_section = 'dashboard'
    @pre_title = "Dashboard"
    @user = current_user
  end
end
