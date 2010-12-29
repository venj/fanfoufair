require 'rubygems'
require 'sinatra'
require 'fanfou'

get '/' do
  erb :index
end

post '/check' do
  if @params[:username].nil? or @params[:username].strip == ''
    @flash = "用户名是必须输入的。"
    erb :index
  else
    unless @params[:password].nil? or @params[:password].strip == ''
      @no_password = true
    end
    puts @params[:username], @params[:password]
    fanfou = Fanfou.new(@params[:username], @params[:password])
    unless fanfou.authenticate
      @flash = "用户名或密码错误。"
      erb :index
    else
      @user = fanfou.show(@params[:username])
      begin
        @delta = fanfou.check_unfair
      rescue Exception => e
        @flash = "用户不存在或设置隐私，请输入密码。"
        erb :index
      else
        if @params[:detail] == '1'
          @show_detail = true
          @delta.each do |e|
            e.map! do |uid|
              fanfou.show(uid)
            end
          end
        end
        erb :check
      end
    end
  end
end
