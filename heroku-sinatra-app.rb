#!/usr/bin/env ruby

require 'sinatra'
require 'redis'

#------------------------------------------------------------------------
# Sinatra Project
# Team 1 - “Artefactual Mechanist”
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
	puts @profile
	
	if @profile == session[:user]
		#THEY ARE THE USER
	end
	
	
	@username = session[:user]
	@fname = REDIS.hget 'users:'+ @username, 'fname'
	@lname = REDIS.hget 'users:'+ @username, 'lname'
	@email = REDIS.hget 'users:'+ @username, 'email'
	@biography = REDIS.hget 'users:'+ @username, 'biography'
	@twitter = REDIS.hget 'users:'+ @username, 'twitter'
	@facebook = REDIS.hget 'users:'+ @username, 'facebook'
	@website = REDIS.hget 'users:'+ @username, 'website'
	@tags = REDIS.hget 'users:'+ @username, 'tags'

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
	redirect 'localhost:/4567/index'
end







#-----------------This starts the ERB views-------------------
#Index for the index page
#Create for the create page
#Profile for displaying a profile

__END__
@@index
<!DOCTYPE html>
<html>
  <head>
    <title>Group One's Awesome Page</title>
  </head>
 
  <body>
  <h1>Team One's Sinatra Project</h1>
		<% if @validUser == "no" %>
			<p>That is not a valid username and password combination. Please reenter the information</p>
		<% else  %>
			<p> </p>
		<% end %>
	<p>This where you will either login or create a new account.</p>
	<form method=POST>
		Username: <input type=text size=50 name="username" /></br>
		Password: <input type=password size=50 name="password" /></br>
		<input type="submit"/>
	<form>
	<h2><a href="/create">Create New Account</a></h2>
  </body>
</html>


@@create
<!DOCTYPE html>
<html>
  <head>
    <title>Registration Page</title>
  </head>
  <body>
		<h1>Create Account</h1>
		<% if @error == "pass" %>
			<p>The passwords didn't match. Please reenter the information</p>
		<% elsif @error == "user" %>
			<p>That user already exsists. Please choose a new one</p>
		<% elsif @error == "email" %>
			<p>That email is already in use. Please select a different one or login using exsisting</p>
		<% end %>		
		<p>Here is where you will register for an account.</p>
		<form method=POST>
		Username: <input type=text size=50 name=username value="<% @username %>" /></br>
		First Name: <input type=text size=50 name=fname value="<% @fname %>" /></br>
		Last Name: <input type=text size=50 name=lname value="<% @lname %>" /></br>
		Email: <input type=text size=50 name=email value="<% @email %>" /></br>
		Password: <input type=password size=50 name=password1 /></br>
		Verify Password: <input type=password size=50 name=password2 /></br>
		<input type="submit"/>
	<form>
  </body>
</html>


@@profile
<!DOCTYPE html>
<html>
  <head>
    <title>This is <%= @profile %>'s profile page</title>
  </head>
  <body>
  <%if @owner == "yes"%>
  <!-- Display editing tools here-->
  <% end %>
	<p>This is where the users page information will be displayed.</p>
	<table>
	<tr><td>UserName</td>	<td><%= @username %></td></tr>
	<%if @lname != nil and @fname != nil%>
	<tr><td>Name</td>		<td><%= @fname %> <%= @lname %></td></tr>
	<% end %>
	<%if @email != nil%>
	<tr><td>Email</td>		<td><%= @email %></td></tr>
	<% end %>
	<%if @biography != nil%>
	<tr><td>Biography</td>	<td><%= @biography %></td></tr>
	<% end %>
	<%if @twitter != nil%>
	<tr><td>Twitter</td>	<td><%= @twitter %></td></tr>
	<% end %>
	<%if @facebook != nil%>
	<tr><td>Facebook</td>	<td><%= @facebook %></td></tr>
	<% end %>
	<%if @website != nil%>
	<tr><td>Website</td>		<td><%= @website %></td></tr>
	<% end %>
	<%if @tags != nil%>
	<tr><td>Tags</td>		<td><%= @tags %></td></tr>
	<% end %>
	
	
	</table>
	
  </body>
</html>


@@menu
<!DOCTYPE html>
<html>
  <head>
    <title><%= @username %>'s Menu Page</title>
  </head>
  <body>
		<h1>Choices</h1>
		<a href="/profile/<%= @username %>">View Profile</a><br>
		<a href="/edit/<%= @username %>">Edit Profile</a><br>
		<a href="/changepass">Change Password</a><br>
		<a href="/logout">Logout</a>
		
  </body>
</html>


@@edit
<!DOCTYPE html>
<html>
  <head><title>Edit Profile</title></head>
  <body>
  <h1>Edit your Information</h1> 
  <font color=red><%= @message %></font><br>
  <form method=POST>
  First Name: <input type=text size=50 name=fname value="<%= @fname %>" /></br>
  Last Name: <input type=text size=50 name=lname value="<%= @lname %>" /></br>
  Email: <input type=text size=50 name=email value="<%= @email %>" /></br>
  Biography: <textarea name="biography" cols="40" rows="7"><%= @biography %></textarea><br>
  Twitter Link: http://twitter.com/<input type=text size=50 name=twitter value="<%= @twitter %>" /></br>
  Facebook Link: http://facebook.com/<input type=text size=50 name=facebook value="<%= @facebook %>" /></br>
  Website: <input type=text size=50 name=website value="<%= @website %>" /></br>
  Tags:	<input type=text size=50 name=tags value="<%= @tags %>" /></br></br>
  <input type="submit"/>
  </form>
  
  </body>
  </html>
  
  
  
  
@@changepass
<!DOCTYPE html>
<html>
  <head><title>Change Password</title></head>
  <body>
  <font color=red><%= @message %></font><br>
  <form method=POST>
  Current Password: <input type=password size=50 name=pass value="<%= @pass %>" /></br>
  New Password: <input type=password size=50 name=newpass value="<%= @newpass %>" /></br>
  Verify New Password: <input type=password size=50 name=verify_new_pass value="<%= @verify_new_pass %>" /></br>
  <input type="submit"/>
  </form>
  
  </body>
  </html>