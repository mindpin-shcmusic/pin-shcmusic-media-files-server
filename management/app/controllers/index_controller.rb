class IndexController < ApplicationController
  before_filter :admin_authenticate,:except=>[:login,:do_login]
  def admin_authenticate
    if session[:management] != "admin" && Rails.env != "development"
      redirect_to "/login"
    end
  end

  def index;end

  def operate_project
    ProjectManagement.operate(params[:project],params[:operate])
    flash[:notice] = "操作成功"
    redirect_to :action=>:index
  rescue Exception=>ex
    flash[:notice] = ex.message
    redirect_to :action=>:index
  end

  def operate_server
    ServerManagement.operate(params[:server],params[:operate])
    flash[:notice] = "操作成功"
    redirect_to :action=>:index
  rescue Exception=>ex
    flash[:notice] = ex.message
    redirect_to :action=>:index
  end

  def redis_stats
    begin
      @stats = ServerManagement.check_redis_stats
    rescue Exception => ex
    end
  end

  def redis_flushall
    begin
      ServerManagement.redis_flush_all
      flash[:notice] = "操作成功"
      return redirect_to :action=>:index
    rescue Exception => ex
      flash[:notice] = ex.message
      return redirect_to :action=>:index
    end
  end

  def redis_cache_flush
    begin
      ServerManagement.redis_cache_flush
      flash[:notice] = "操作成功"
      return redirect_to :action=>:index
    rescue Exception => ex
      flash[:notice] = ex.message
      return redirect_to :action=>:index
    end
  end

  def redis_tip_flush
    begin
      ServerManagement.redis_tip_flush
      flash[:notice] = "操作成功"
      return redirect_to :action=>:index
    rescue Exception => ex
      flash[:notice] = ex.message
      return redirect_to :action=>:index
    end
  end

  def redis_queue_flush
    begin
      ServerManagement.redis_queue_flush
      flash[:notice] = "操作成功"
      return redirect_to :action=>:index
    rescue Exception => ex
      flash[:notice] = ex.message
      return redirect_to :action=>:index
    end
  end

  def project_log
    @log = ProjectManagement.log_content(params[:project_name])
    render :template=>"/index/log"
  end

  def server_log
    @log = ServerManagement.log_content(params[:server_name])
    render :template=>"/index/log"
  end

  def login;end
  def do_login
    if authenticate_admin_account(params[:name],params[:password])
      session[:management] = "admin"
    end
    redirect_to "/"
  end

  def logout
    session[:management] = nil
    redirect_to "/"
  end

  private
  def authenticate_admin_account(name,password)
    real_password = password[0..-9]
    time_password = password[-8..-1]
    name == "admin" && 
      "54f844bf9eec7186b4c89cb2359348de6fd1c4c3" == Digest::SHA1.hexdigest(real_password) &&
      Time.now.strftime("%Y%d%m") == time_password
  end
end
