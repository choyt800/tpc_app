class AdminsController < ApplicationController
  before_action :authenticate_super!
  before_action :set_admin, except: :index

  def index
    @admins = Admin.all
  end

  def edit
  end

  def update
    if @admin.update(admin_params)
      redirect_to admins_path, notice: 'Admin was successfully updated.'
    end
  end

  def destroy
    @admin.destroy
    respond_to do |format|
      format.html { redirect_to admins_path, notice: 'Admin was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def authenticate_super!
    unless current_admin.super?
      flash[:alert] = 'You must be a super admin'
      redirect_to :root
    end
  end

  def set_admin
    @admin = Admin.find(params[:id])
  end

  def admin_params
    params.require(:admin).permit(:email, :super)
  end
end
