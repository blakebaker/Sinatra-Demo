#!/usr/bin/env ruby

require 'sinatra'

#------------------------------------------------------------------------
# Sinatra Project
# Team 1 - ¡°Artefactual Mechanist¡±
# Members: Blake Baker, Shaofen Chen, Briana Fulfer, Moohanad Hassan, 
#          Peter Lew, Fred Rodriguez
# Due Date: February 22
# Class: CPSC473
# Wednesday @ 7-9:45
#------------------------------------------------------------------------

configure do
  require 'redis'
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  enable :sessions
end
  
before '/' do
end

get '/' do
	redirect '/index'
end



get '/index' do
	#--------------What it does-------------------
	#Name: Get index
	# This is the homepage
	#   It will display the welcome page with a login page and 
	# link to the create page


	#--------------Start Code-------------------

	#If a user is already logged in, redirect to their menu page
	if(session[:user] != nil)
		redirect '/menu'
	end

	# load the index view
	erb :index
end



post '/index' do
	#--------------What it does-------------------
	#Name: Postback index
	#if valid user 
		#redirect to menu page
		#use the username to set the session value to store the username to show owner rights
	#else 
		#redisplay prompt with resubmit option
		#Display Error say invalid user.


	#--------------Start Code-------------------


	#Getting the passwords from the POSTback
	@username = params[:username]
	@password = params[:password]

	# Take username and password and compare to DB to validat user
	@DBpass = REDIS.hget 'users:'+ @username, 'password'
	if (REDIS.exists('users:'+ @username) and @password == @DBpass)
		@validUser = "yes"
		session[:user] = @username
	else
		@validUser = "no"
	end
	puts @validUser
	#this will return yes or no to @validUser to determine how it is routed.


	if @validUser == "yes"
		#redirect to menu page
		redirect '/menu'
	else
		erb :index
	end
end



get '/create' do
	#--------------What it does-------------------
	#Name: Get Create
	#
	# Displays the form for creating a profile on the site

	#--------------Start Code-------------------
	erb :create
end



post '/create' do
	#--------------What it does-------------------
	#Name: Postback Create
	#Verify multiple things
	#	Passwords match DONE; Username, email not in DB
	#	print error messages for both of these and re display information
	#	*************Do this in the ERB view see example on password match
	#If valid information create attributes in DB
	#Redirect to users menu page


	#--------------Start Code-------------------
	@error = "NONE"
	@username = params[:username]

	#Check REDIS for exsisting username. If yes, set @error = "user"
	if REDIS.exists('users:'+ @username)
		@error = "user"
	end

	@fname = params[:fname]
	@lname = params[:lname]	
	@email = params[:email]	

	#Check REDIS for exsisting email, if yes set @error = "email" 
	if REDIS.exists('email:'+ @email)
		@error = "email"
	end

	@password1 = params[:password1]
	@password2 = params[:password2]

	#If that checks to see that the new passwords match
	if @password1 != @password2 
		@error = "pass"
	end

	# If no errors, enter data into REDIS
	if @error == "NONE"
		REDIS.hset 'users:'+ @username, 'fname', @fname 
		REDIS.hset 'users:'+ @username, 'lname', @lname 
		REDIS.hset 'users:'+ @username, 'email', @email 
		REDIS.hset 'users:'+ @username, 'password', @password1

		#Enters hash for email, so we can have an email key as well.
		#	This is so we can search by the email value
		REDIS.hset 'email:'+ @email, 'user','users:'+ @username

		#redirect to index page
		redirect '/menu'
	end			
	erb :create
end



get '/profile/:username' do
	#--------------What it does-------------------
	#Name: Get Profile
	#Display Profile information


	#--------------Start Code-------------------

	#trying to set a profile name from the url
	@profile = params[:username]
	
	if @profile == session[:user]
		@logged = 1
	end

	if REDIS.exists('users:'+ @profile)
		@username = @profile
		@fname = REDIS.hget 'users:'+ @username, 'fname'
		@lname = REDIS.hget 'users:'+ @username, 'lname'
		@email = REDIS.hget 'users:'+ @username, 'email'
		@biography = REDIS.hget 'users:'+ @username, 'biography'
		@twitter = REDIS.hget 'users:'+ @username, 'twitter'
		@facebook = REDIS.hget 'users:'+ @username, 'facebook'
		@website = REDIS.hget 'users:'+ @username, 'website'
		@tags = REDIS.hget 'users:'+ @username, 'tags'

	elsif 
         redirect '/index'
	end

	erb :profile
end



get '/menu' do 
	#--------------What it does-------------------
	#Name: Get Menu
	#Show menu links if a user is logged in.

	#--------------Start Code---------------------

	#If no user is logged in, then redirect to /index
	if session[:user] == nil
		redirect '/index'
	end

	@username = session[:user]
	# load the menu view
	erb :menu
end



get '/edit/:username' do
	#--------------What it does-------------------
	#Name: Get Edit for specific username
	#If the session username is the same as the parameter username,
	#	they are allowed to make changes.

	#--------------Start Code---------------------

	#If no user is logged in, then redirect to /index
	if session[:user] == nil
		redirect '/index'
	end


	@username = session[:user]

	#If the session username is the same as the parameter username,
		#they are allowed to make changes.
	if @username == params[:username]

	@fname = REDIS.hget 'users:'+ @username, 'fname'
	@lname = REDIS.hget 'users:'+ @username, 'lname'
	@email = REDIS.hget 'users:'+ @username, 'email'
	@biography = REDIS.hget 'users:'+ @username, 'biography'
	@twitter = REDIS.hget 'users:'+ @username, 'twitter'
	@facebook = REDIS.hget 'users:'+ @username, 'facebook'
	@website = REDIS.hget 'users:'+ @username, 'website'
	@tags = REDIS.hget 'users:'+ @username, 'tags'

	erb :edit


	else #logged in user does not match, redirect to /index
		redirect '/index'
	end

end 



post '/edit/:username' do
	#--------------What it does-------------------
	#Name: POST Edit for specific username
	#If session user is the same as profile user
	#	set new information in hash
	#Else, redirect to /index	

	#--------------Start Code---------------------
		@username = params[:username]

		#Parameters
		@fname = params[:fname]
		@lname = params[:lname]
		@email = params[:email]
		@biography = params[:biography]
		@twitter = params[:twitter]
		@facebook = params[:facebook]
		@website = params[:website]
		@tags = params[:tags]

		#if session user is the same as profile user
		if session[:user] == @username
			#Set new information in Hash
			REDIS.hset 'users:'+ @username, 'fname', @fname 
			REDIS.hset 'users:'+ @username, 'lname', @lname 
			REDIS.hset 'users:'+ @username, 'email', @email
			REDIS.hset 'users:'+ @username, 'biography', @biography
			REDIS.hset 'users:'+ @username, 'twitter', @twitter
			REDIS.hset 'users:'+ @username, 'facebook', @facebook
			REDIS.hset 'users:'+ @username, 'website', @website
			REDIS.hset 'users:'+ @username, 'tags', @tags

			@message = "Your information has been updated."
			erb :edit
		else
			redirect '/index'
		end
end





get '/changepass' do
	#--------------What it does-------------------
	#Name: Get Change Pass
	#
	# Displays the form for changing your password

	#--------------Start Code-------------------
	if session[:user] == nil
		redirect '/index'
	end

	erb :changepass
end




post '/changepass' do
	#--------------What it does-------------------
	#Name: POST Change Password
	#Checks that the original password entered is correct.
	#	Checks if the new passwords match
	#		Update database
	#		Then redirect to /menu
	#	Else error
	#Else error

	#--------------Start Code-------------------	
	@username = session[:user] 

	@originalpass = REDIS.hget 'users:'+ @username, 'password'
	if params[:pass] == @originalpass
		if params[:newpass] == params[:verify_new_pass]
			REDIS.hset 'users:'+ @username, 'password', params[:newpass]
			redirect '/menu'
		else
		@message = "Your passwords do not match."
		erb :changepass
		end
	else
		@message = "Your original password is not correct."
		erb :changepass
	end

end

get '/logout' do
	#--------------What it does-------------------
	#Name: Logout
	#
	# Sets the session[:user] to nil

	#--------------Start Code-------------------
	session[:user] = nil
	redirect '/index'
end



not_found do
    #--------------What it does-------------------
	#Name: Page Not Found
	# Redirects user to the homepage when the user tries to access a page that
	#does not exsist

	#--------------Start Code-------------------
	"Page doesn't exsist redirecting to homepage."
	redirect '/index'
end

