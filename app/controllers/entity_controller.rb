class EntityController < ApplicationController
  layout "user"
  before_filter :authenticate_user!

  def show
    @entity = Entity.find_by_entity_token(params[:entity_token])
  end

  def new
    @entity = Entity.new()
  end

  def create
    @entity = Entity.new_by_user(params, current_user)

    if @entity.save!
      redirect_to show_entity_path(@entity.entity_token)
    else
      render :new
    end
  end
end