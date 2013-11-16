class Entity::PagesController < ApplicationController
  layout "entity"
  before_filter :authenticate_user!

  def index
    @current_section = 'pages'
    @pre_title = "Pages"
    @user = current_user
    @stacks = current_user.stacks
  end

  def show
    @current_section = "pages"
    @pre_title = "Pages"
    @user = current_user
    @stack = @user.stacks.find_by_stack_token(params[:stack_token])

    if @stack.nil?
      render :error
    else
      @transactions = @stack.transactions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
      render :show
    end
  end

  def new
    @current_section = "pages"
    @pre_title = "Pages"
    @show = 'intro'

    entity_token = params[:entity_token] || current_user.entity.entity_token
    @entity = Entity.find_by_entity_token(entity_token)

    if @entity.nil? && current_user.user_token != @entity.user_token
      render :error
    else
      render :new
    end
  end

  def new_one_time
    @current_section = "pages"
    @pre_title = "Pages"
    @show = 'one-time'

    entity_token = params[:entity_token] || current_user.entity.entity_token
    @entity = Entity.find_by_entity_token(entity_token)

    if @entity.nil? && current_user.user_token != @entity.user_token
      render :error
    else
      @stack = Stack.new
      render :new
    end
  end

  def new_digital_download
    @current_section = "pages"
    @pre_title = "Pages"
    @show = 'digital-download'

    entity_token = params[:entity_token] || current_user.entity.entity_token
    @entity = Entity.find_by_entity_token(entity_token)

    if @entity.nil? && current_user.user_token != @entity.user_token
      render :error
    else
      @stack = Stack.new
      render :new
    end
  end

  def edit
    @current_section = "pages"
    @pre_title = "Pages"
    @user = current_user
    @stack = Stack.find_by_stack_token(params[:stack_token])

    if @stack.nil?
      render :error
    else
      @entity = @stack.entity
      if @user.user_token != @entity.user_token
        render :error
      end
    end
  end

  def create_one_time
    entity_token = params[:entity_token] || current_user.entity.entity_token
    @entity = Entity.find_by_entity_token(entity_token)

    if @entity.nil? && current_user.user_token != @entity.user_token
      render :error
    else
      @stack = Stack.new_one_time_by_user(params[:stack], @entity, current_user)

      if @stack.save
        redirect_to edit_page_path(@stack.stack_token)
      else
        render :new
      end
    end
  end

  def create_digital_download
    entity_token = params[:entity_token] || current_user.entity.entity_token
    @entity = Entity.find_by_entity_token(entity_token)

    if @entity.nil? && current_user.user_token != @entity.user_token
      render :error
    else
      @stack = Stack.new_digital_download_by_user(params[:stack], @entity, current_user)

      if @stack.save
        redirect_to edit_page_path(@stack.stack_token)
      else
        render :new
      end
    end
  end

  def update
    entity_token = params[:entity_token] || current_user.entity.entity_token
    @entity = Entity.find_by_entity_token(entity_token)

    if @entity.nil? && current_user.user_token != @entity.user_token
      render :error
    else
      params[:stack].delete(:primary_image) if  params[:stack][:primary_image].blank?
      params[:stack].delete(:digital_download_file) if params[:stack][:digital_download_file].blank?
      params[:stack][:digital_download_update_flag] = true unless params[:stack][:digital_download_file].blank?

      if params[:stack][:shipping_cost_value].nil? && params[:stack][:shipping_cost_term].nil?
        params[:stack][:shipping_cost_value] = []
        params[:stack][:shipping_cost_term] = []
      end

      if params[:stack][:custom_data_value].nil? && params[:stack][:custom_data_term].nil?
        params[:stack][:custom_data_value] = []
        params[:stack][:custom_data_term] = []
      elsif params[:stack][:custom_data_value].nil?
        params[:stack][:custom_data_value] = []
      end

      @stack = Stack.find_by_stack_token(params[:stack_token])

      if @stack.update_attributes(params[:stack])
        redirect_to edit_page_path(@stack.stack_token)
      else
        render :settings
      end
    end
  end

  def updated_download
    @user = current_user
    @stack = current_user.stacks.find_by_stack_token(params[:stack_token])

    if @stack.nil? && @stack.archived == true
      render :error
    else
      if @stack.can_delivery_file?
        @stack.transactions.each { |transaction|
          TransactionMailer.updated(transaction).deliver
        }
        @stack.update_attributes(:digital_download_update_flag => false)
        redirect_to edit_page_path(@stack.stack_token), :notice => "Emails have been sent."
      else
        redirect_to edit_page_path(@stack.stack_token), :notice => "Emails could not be sent out."
      end
    end
  end

  def destroy
    @stack = Stack.find_by_stack_token(params[:stack_token])
    @stack.decommission

    redirect_to user_root_path
  end
end

