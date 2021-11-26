require 'discordrb'
require 'json'

def writeconfig
  print "Enter your bot token: "
  token = gets.chomp
  print "Is this correct? \"#{token}\"\n(y)es\n(n)o\n"
  confirmation = gets.chomp
  if confirmation.downcase != "y" && confirmation.downcase != "yes"
    puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nWrong token given"
    puts "Re-running config creator\n\n"
    writeconfig
    return
  end
  puts "Writing config..."
  jsonwrite = "{'token': '#{token}'}".gsub("'", '"')
  File.open("./config.json", 'w') { |file| file.write(jsonwrite) }
end

unless File.exist?('./config.json')
  puts "No config found\nStarting the config creator...\n"
  writeconfig
  puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nStarting the bot..."
end

jsonfile = File.read('./config.json')
$jsonhash = JSON.parse(jsonfile)

def startbot
  # RubyMine is being stupid with error_handler, it works fine, will try to fix this tomorrow
  $bot = Discordrb::Bot.new(token: $jsonhash['token'], error_handler: errorbot, intents: [:servers, :server_messages, :server_bans, :server_emojis, :server_integrations, :server_webhooks, :server_invites, :server_voice_states, :server_presences, :server_message_reactions, :server_message_typing, :direct_messages, :direct_message_reactions, :direct_message_typing, :server_members])
end

def errorbot(error)
  puts "Oops...\nSomething went wrong"
  puts "In most cases this means that the token is invalid"
  puts "Do you want to\n(r)ewrite the config\n(q)uit\n"
  answer = gets.chomp
  if answer == "r"
    puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nStarting the config creator..."
    writeconfig
    puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nStarting the bot..."
    startbot
    return
  elsif answer == "q"
    exit
  else
    puts "That option does not exist\n"
    errorbot(error)
    return
  end
end

begin
  startbot
rescue => error
  errorbot(error)
end

$bot.member_join do |event|
  puts event.user.username
end

$bot.run