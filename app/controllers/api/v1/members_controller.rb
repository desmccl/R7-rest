class Api::V1::MembersController < ApplicationController
    include AuthenticationCheck
  
    before_action :is_user_logged_in
    before_action :set_member, only: [:show, :update, :destroy]
    before_action :check_access, only: [:update, :destroy] # Check access for update and destroy actions
  
    # GET /members
    def index
      @members = Member.where(user_id: current_user.id)
      render json: { members: @members }
    end
  
    # GET /members/:id
    def show
      render json: @member
    end
  
    # POST /members
    def create
      @member = Member.new(member_params)
      @member.user_id = current_user.id
      if @member.save
        render json: @member, status: :created
      else
        render json: { error: "Unable to create member: #{@member.errors.full_messages.to_sentence}" }, status: :unprocessable_entity
      end
    end
  
    # PUT /members/:id
    def update
      if @member.update(member_params)
        render json: @member
      else
        render json: { error: "Unable to update member: #{@member.errors.full_messages.to_sentence}" }, status: :unprocessable_entity
      end
    end
  
    # DELETE /members/:id
    def destroy
      @member.destroy
      render json: { message: 'Member record successfully deleted.' }, status: :ok
    end
  
    private
  
    def member_params
      params.require(:member).permit(:first_name, :last_name)
    end
  
    def set_member
      @member = Member.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Member not found' }, status: :not_found
    end
  
    def check_access
      if @member.user_id != current_user.id
        render json: { message: 'The current user is not authorized for that data.' }, status: :unauthorized
      end
    end
  end
  