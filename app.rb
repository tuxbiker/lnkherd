%w(rubygems yajl/json_gem digest/md5 oa-oauth dm-core dm-sqlite-adapter dm-migrations dm-validations sinatra erb).each { |dependency| require dependency }

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://#{Dir.pwd}/database.db')

class User
  include DataMapper::Resource
  property :id,         Serial
  property :uid,        String
  property :name,       String
  property :email,      String, :format => :email_address
  property :url,        String, :default => '', :format => :url
  property :tag,        String, :default => ''
  property :show,       Boolean,:default => false
  property :nickname,   String
  property :created_at, DateTime

  validates_with_method :body, :method => :valid_tag

  def valid_tag
    tags = ['this','that','other','']
    if tags.include?(self.tag)
      return true
    else
      [ false, "Invalid tag!" ]
    end
  end

end

DataMapper.finalize
DataMapper.auto_upgrade!

# You'll need to customize the following line. Replace the CONSUMER_KEY 
#   and CONSUMER_SECRET with the values you got from Twitter 
#   (https://dev.twitter.com/apps/new).
use OmniAuth::Strategies::Twitter, 'Get5Yjr330GGhU7KV60A', 'oZPXyRXgQD1ftcfwsJYRsPKJV23AbUP6OEAv8sJI'

enable :sessions

helpers do
  def current_user
    @current_user ||= User.get(session[:user_id]) if session[:user_id]
  end
  def random_string(length=16)
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
    password = ''
    length.times { password << chars[rand(chars.size)] }
    password
  end
  def profile_pic(email, size)
    digest = Digest::MD5.hexdigest(email,size)
    # we want to allow parallel downloads,
    # but we don't want to bust caches
    if(%w(0 1 2 3 4 5 6 7).include? digest[0])
      host = "img0"
    else
      host = "img1"
    end
    return "http://" + host + ".lnkherd.com/avatar/" + digest + "?s=" + size + "&r=pg&d=retro"
  end
end

get '/edit' do
  if current_user
    # The following line just tests to see that it's working.
    #   If you've logged in your first user, '/' should load: "1 ... 1";
    #   You can then remove the following line, start using view templates, etc.
    puts current_user.id.to_s + " ... " + session[:user_id].to_s
    if(session['csrf'].nil?)
      session['csrf'] = random_string
    end
    @logged_in = true
    @errors = nil
    unless(session['errors'].nil?)
      @errors = JSON.parse(session['errors'])
      session['errors'] = nil
    end
    @pic   = profile_pic(current_user.email || "",'200')
    @email = current_user.email || ""
    @url   = current_user.url   || ""
    @tag   = current_user.tag   || ""
    @show  = current_user.show  || false
    @csrf  = session['csrf']
    erb :user_profile
  else
    redirect '/'
  end
end
get '/' do
  # '<a href="/sign_up">create an account</a> or <a href="/sign_in">sign in with Twitter</a>'
  # if you replace the above line with the following line, 
  #   the user gets signed in automatically. Could be useful. 
  #   Could also break user expectations.
  # redirect '/auth/twitter'
  @logged_in = current_user ? true : false
  @users = User.all(:limit => 25)
  erb :home
end

post '/edit' do
  # get the post vars
  email = params.delete('email')
  show = params['show']
  if(show == "true" || show == "false")
    sshow = true
  end
  if(show == "true")
    show = true
  elsif(show =="false")
    show = false
  end
  url = params.delete('url')
  tag = params.delete('tag')
  csrf = (params.delete('csrf') == session['csrf'])

  # make sure we got everything
  if(session[:user_id] && email && sshow && url && tag && csrf)
    # save
    puts "got everything"
    u = {}
    if(current_user.email != email)
      u[:email] = email
    end
    if(current_user.url != url)
      u[:url] = url
    end
    if(current_user.tag != tag)
      u[:tag] = tag
    end
    if(current_user.show != show)
      u[:show] = show
    end
    
    if(u.keys.length > 0)
      s = current_user.update(u)
      unless (s)
        puts 'before'
        session['errors'] = current_user.errors.to_h.to_json
        puts 'after'
      end
    end
  end
  redirect '/edit'
end

get '/auth/:name/callback' do
  auth = request.env["omniauth.auth"]
  user = User.first_or_create({ :uid => auth["uid"]}, { 
    :uid => auth["uid"], 
    :nickname => auth["user_info"]["nickname"], 
    :name => auth["user_info"]["name"], 
    :created_at => Time.now })
  puts user
  puts user.id
  session[:user_id] = user.id
  puts session[:user_id]
  redirect '/edit'
end

# any of the following routes should work to sign the user in: 
#   /sign_up, /signup, /sign_in, /signin, /log_in, /login
["/sign_in/?", "/signin/?", "/log_in/?", "/login/?", "/sign_up/?", "/signup/?"].each do |path|
  get path do
    redirect '/auth/twitter'
  end
end

# either /log_out, /logout, /sign_out, or /signout will end the session and log the user out
["/sign_out/?", "/signout/?", "/log_out/?", "/logout/?"].each do |path|
  get path do
    session[:user_id] = nil
    redirect '/'
  end
end
