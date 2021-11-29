require 'discordrb'
require 'time'
require 'json'
require 'fileutils'

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
  jsonwrite = "{\"token\": \"#{token}\"}"
  File.open("./config.json", 'w') { |file| file.write(jsonwrite) }
end

unless File.exist?('./config.json')
  puts "No config found\nStarting the config creator...\n"
  writeconfig
  puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nStarting the bot..."
end

if File.directory?('temp/')
  FileUtils.remove_dir('temp/')
end
Dir.mkdir('temp/')
jsonfile = File.read('./config.json')
$jsonhash = JSON.parse(jsonfile)

def validatetoken
  begin
    Discordrb::API.validate_token("Bot #{$jsonhash['token']}")
  rescue
    puts "Oops...\nSomething went wrong"
    puts "In most cases this means that the token is invalid or that you did not enable all intents"
    puts "Do you want to\n(r)ewrite the config\n(q)uit\n"
    answer = gets.chomp
    if answer == "r"
      puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nStarting the config creator..."
      writeconfig
      puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nStarting the bot...\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
      validatetoken
      return
    elsif answer == "q"
      exit
    else
      puts "That option does not exist\n"
      validatetoken
      return
    end
  end
end

validatetoken
bot = Discordrb::Bot.new(token: $jsonhash['token'], intents: [:servers, :server_messages, :server_bans, :server_emojis, :server_integrations, :server_webhooks, :server_invites, :server_voice_states, :server_presences, :server_message_reactions, :server_message_typing, :direct_messages, :direct_message_reactions, :direct_message_typing, :server_members])

bot.ready do |_|
  puts "----------------------------------------"
  puts "Connected!"
  puts "Logged in as #{bot.profile.name}##{bot.profile.discriminator}"
  puts "----------------------------------------"
  bot.watching = "for raids"
end

bot.member_join do |event|
  if File.exist?("temp/#{event.server.id}.log")
    # file = File.open("temp/#{event.server.id}.log", "a")
    # file.write("\n#{Time.now.to_i}")
    # file.close
    file = File.open("temp/#{event.server.id}.json")
    output["data"].push("{\"#{event.user.id}\":\"#{time.now.to_i}\"}")
    file.write(output)
    file.close
  else
    # file = File.open("temp/#{event.server.id}.log", "w")
    # file.write(Time.now)
    # file.close
    file = File.open("temp/#{event.server.id}.json")
    output = "\"data\":{\"#{event.user.id}\":\"#{time.now.to_i}\"}}"
    file.write(output)
    file.close
  end
end

bot.run