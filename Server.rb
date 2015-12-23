# Troy Gallagher, 11352566
# => CS4032, Chatroom Assignment 04, Server
# => A server that manages several chatrooms.


require "socket"
require "json"
class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @rooms = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        nick_name = client.gets.chomp.to_sym
        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts "#{nick_name}: This username has already been taken. Disconnected"
            Thread.kill self
          end
        end
        puts "#{nick_name} #{client}: Connected"
        @connections[:clients][nick_name] = client
        client.puts "#{nick_name}: Connected to server"
        listen_user_messages( nick_name, client )
      end
    }.join
  end

  def listen_user_messages( username, client )
    loop {
    	msg = client.gets.chomp
    	actions(username, client, msg)
     	break if msg.include? "DISCONNECT:["
    }
  end

  def actions (username, client, msg)
  	if msg.include? "JOIN_CHATROOM:["
  		joinroom(username, client, msg)
  	elsif msg.include? "LEAVE_CHATROOM:["
  		leaveroom(msg)
  	elsif msg.include? "DISCONNECT:["
  		exit(username, client)
  	elsif msg.include? "CHAT:["
  		message(username, msg)
  	else
  		puts "ERROR:1\nERROR_MESSAGE:Inbound message not recognised."
  	end 
  end

  def joinroom(username, client, room)
  	# => Does room exist?
  	i = 0
  	@connections[:rooms].each do |room|
  		# => If the room exists, add user to room.
  		i++
  	end

  	# => If the room does not exist, create new room
  	client.puts "JOINED_CHATROOM:[]\nSERVER_IP:[]\nPORT:[]\nROOM_Ref:[]\nJOINE_ID:[]"
  end

  def leaveroom(username, room)
  	# => Remove user from room
  	# => If users in room is 0, delete room
  	client.puts "LEFT_CHATROOM:[]\nJOIN_ID:[]"
  end

  def message (username, msg)
      @connections[:clients].each do |other_name, other_client|
        unless other_name == username
          other_client.puts "CHAT:[]\nCLIENT_NAME:[#{username.to_s}]\nMESSAGE:[#{msg}]"
        end
      end
  end

  def exit(user, client)
  	# => Remove user connection
  	puts "#{user} #{client}: Disconnected"
  end

end

Server.new( 3000, "localhost" )