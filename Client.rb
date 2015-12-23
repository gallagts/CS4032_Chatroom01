# Troy Gallagher, 11352566
# => CS4032, Chatroom Assignment 04, Client
# => This is a client to connect to a chatroom

require "socket"
require "json"

# => Global variables for user
$username = ""
$room = ""
$id = 0
$room_id = 0
$ip = 3000

class Client
  def initialize( server )
    @server = server
    @request = nil
    @response = nil
    listen
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        actionslistener(@server.gets.chomp)
      }
    end
  end

  def send
    @request = Thread.new do
    	msg = ""
    	connect()
      	loop{
      		msg = $stdin.gets.chomp
      		actions(msg)
        	break if msg == "exit"
      	}
    end
  end

  def connect
	  	puts "Enter a username"
  		msg = $stdin.gets.chomp
  		puts "Connecting..."
  		# => Get username
  		$username = msg
    	@server.puts( msg )
  end

  def actions(msg)
  	if msg == "join"
  		joinroom()
  	elsif msg == "leave"
  		leaveroom()
  	elsif msg == "exit"
  		exit()
  	else# => Only option, if not the above, is just a general message
  		message(msg)
  	end 
  end

  def message(msg)
  	input = "CHAT:[#{$room}]\nJOIN$id:[$id]\nCLIENT_NAME:[$username]\nMESSAGE:[msg]"
  	@server.puts( input )
  end

  def join
  	puts "Enter room name:"
  	msg = $stdin.gets.chomp
  	# => Get room
  	$room = msg
  	# => Send Join message
  	msg = "JOIN_CHATROOM:[{#msg}]\nCLIENT_IP:[0]\nPORT:[0]\nCLIENT_NAME:[#{$username}]"
  	@server.puts( msg )
  end

  def leave
  	msg = "leave"
  	# => Remove self from room
  	msg = "LEAVE_CHATROOM:[#{$room}]\nJOIN$id:[#{$id}]\nCLIENT_NAME:[#{$username}]"
  	# => Message = leave
  	@server.puts( msg )
  end

  def exit
  	puts "Disconnecting..."
  	# => Create disconnection message
  	msg = "DISCONNECT:[0]\nPORT:[0]\nCLIENT_NAME:[#{$username}]"
  	@server.puts( msg )
  end

  def actionslistener(msg)
  	if msg.include? "JOINED_CHATROOM:"
  		joinlistener(msg)
  	elsif msg.include? "LEFT_CHATROOM"
  		leavelistener(msg)
  	elsif msg.include? "DISCONNECT"
  		exitlistener(msg)
  	elsif msg.include? "CHAT:["
  		messagelistener(msg)
  	else
  		puts"ERROR:0\nERROR_MESSAGE: Unable to confirm message type from server"
  	end 
  end

  def joinlistener(msg)
  	message = msg.split('\n')
  	message[0] = message[0][17...-2]
  	message[1] = message[1][11...-2]
  	message[2] = message[2][6...-2]
  	message[3] = message[3][10...-2]
  	message[4] = message[4][9...-1]

  	$room = message[0]
  	#$ip = $message[1]
  	# => Port not used
  	$id = message[3]
  	$room_id = message[4]

  	puts "Server: You have joined #{$room}"

  end

  def leavelistener(msg)
  	message = msg.split('\n')
  	message[0] = message[0][...-2]
  	message[1] = message[1][...-1]

  	$room = ""
  	$room_id = 0
  	puts "Server: You ahve left the room."
  end

  def messagelistener(msg)
  	message = msg.split('\n')
  	message[0] = message[0][6...-2]
  	message[1] = message[1][11...-2]
  	message[2] = message[2][8...-1]

  	puts "#{message[1]}:#{message[2]}"
  end 

  def exitlistener(msg)
  	puts "Chat ended."
  end

end

server = TCPSocket.open( "localhost", $ip)
Client.new( server )