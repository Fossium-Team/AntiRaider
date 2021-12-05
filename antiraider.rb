require 'discordrb'
require 'time'
require 'fileutils'
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
  confighash = {:token => ""}
  if File.exists?('./config.json')
    configfile = File.read('./config.json')
    confighash = JSON.parse(configfile)
  end
  confighash['token'] = token
  File.open('./config.json', 'w') { |file| file.write(JSON.dump(confighash)) }
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

class String
  public
  def is_number?
    begin
      Float(self)
      return true
    rescue
      return false
    end
  end
end

def captchagen
  question = ""
  answer = ""
  loop do
    randomoperation = rand 1..4
    if randomoperation == 1
      operation = "+"
    elsif randomoperation == 2
      operation = "-"
    elsif randomoperation == 3
      operation = "x"
    elsif randomoperation == 4
      operation = ":"
    end
    number1 = rand 3..10
    number2 = rand 3..10
    question = "#{number1} #{operation} #{number2}"
    if operation == "x"
      answer = number1.send(:*, number2)
    elsif operation == ":"
      answer = number1.send(:/, number2)
    elsif operation == "+"
      answer = number1.send(:+, number2)
    elsif operation == "-"
      answer = number1.send(:-, number2)
    end
  break if !(answer % 1 != 0) && Integer(answer) >= 0
  end
  return question, answer
end

validatetoken
bot = Discordrb::Commands::CommandBot.new(token: $jsonhash['token'], prefix: "ar!", help_command: false, command_doesnt_exist_message: "Oops...\n`%command%` is not a valid command", spaces_allowed: true, compress_mode: :large, intents: [:servers, :server_messages, :server_bans, :server_emojis, :server_integrations, :server_webhooks, :server_invites, :server_voice_states, :server_presences, :server_message_reactions, :server_message_typing, :direct_messages, :direct_message_reactions, :direct_message_typing, :server_members])

bot.ready do |_|
  puts "----------------------------------------"
  puts "Connected!"
  puts "Logged in as #{bot.profile.name}##{bot.profile.discriminator}"
  puts "----------------------------------------"
  bot.watching = "for raids | ar!help"
end

bot.mention do |event|
  event.channel.send_message("My prefix is `ar!`", false, nil, nil, nil, event.message)
end

bot.command :help do |event|
  event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
    embed.colour = 0x0080FF
    embed.title = 'Help'
    embed.fields = [
      Discordrb::Webhooks::EmbedField.new(
        name: 'Config',
        value: '`ar!config`'
      )
    ]
  end
end

bot.command :config, description: 'Configure the bot' do |event, setting, option|
  unless event.user.permission?(:administrator)
    event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
      embed.colour = 0xFF0000
      embed.title = 'Oops..'
      embed.description = "You need to have the `Administrator` permission to use this command"
    end
    next
  end
  unless setting
    configfile = File.read('./config.json')
    confighash = JSON.parse(configfile)
    if confighash['timespan'] == nil
      timespan = "300"
    else
      timespan = Integer(confighash['timespan']) * 60
    end
    if confighash['maxjoins'] == nil
      maxjoins = "10"
    else
      maxjoins = Integer(confighash['maxjoins'])
    end
    if confighash['captchaenabled'] == nil
      captchaenabled = "false"
    else
      captchaenabled = confighash['captchaenabled']
    end
    if confighash['captcharole'] == nil
      captcharole = "none"
    else
      captcharole = confighash['captcharole']
    end
    if confighash['joinrole'] == nil
      joinrole = "none"
    else
      joinrole = confighash['joinrole']
    end

    event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
      embed.colour = 0x0080FF
      embed.title = 'Settings'
      embed.fields = [
        Discordrb::Webhooks::EmbedField.new(
          name: 'maxjoins: number',
          value: "Currently set to: #{maxjoins}"
        ),
        Discordrb::Webhooks::EmbedField.new(
          name: 'timespan: time in minutes',
          value: "Currently set to: #{timespan}"
        ),
        Discordrb::Webhooks::EmbedField.new(
          name: 'captchaenabled: true or false',
          value: "Currently set to: #{captchaenabled}"
        ),
        Discordrb::Webhooks::EmbedField.new(
          name: 'captcharole: role id (of the role that the user gets after doing the captcha)',
          value: "Currently set to: #{captcharole}"
        ),
        Discordrb::Webhooks::EmbedField.new(
          name: 'joinrole: role id (of the role that the user gets after joining )',
          value: "**only used if captcha is disabled**\nCurrently set to: #{joinrole}"
        )
      ]
    end
  end
  if setting == 'timespan'
    unless option
      event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Oops...'
        embed.description = 'No option given'
      end
      next
    end
    unless option.is_number?
      event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Oops...'
        embed.description = 'That is not a number'
      end
      next
    end
    configfile = File.read('./config.json')
    confighash = JSON.parse(configfile)
    confighash['timespan'] = option
    File.open("./config.json", 'w') { |file| file.write(JSON.dump(confighash)) }
    event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
      embed.colour = 0x2ECC70
      embed.title = "Set `timespan` to `#{option}`"
    end
    next
  elsif setting == 'maxjoins'
    unless option
      event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Oops...'
        embed.description = 'No option given'
      end
      next
    end
    unless option.is_number?
      event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Oops...'
        embed.description = 'That is not a number'
      end
      next
    end
    configfile = File.read('./config.json')
    confighash = JSON.parse(configfile)
    confighash['maxjoins'] = option
    File.open("./config.json", 'w') { |file| file.write(JSON.dump(confighash)) }
    event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
      embed.colour = 0x2ECC70
      embed.title = "Set `maxjoins` to `#{option}`"
    end
    next
  elsif setting == 'captchaenabled'
    unless option
      event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Oops...'
        embed.description = 'No option given'
      end
      next
    end
    if option != "true" && option != "false"
      event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Oops...'
        embed.description = "Incorrect option\nCorrect options: true and false"
      end
      next
    end
    configfile = File.read('./config.json')
    confighash = JSON.parse(configfile)
    if confighash['captcharole'] == nil && option != "false"
      event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Oops...'
        embed.description = "Please set `captcharole` first"
      end
      next
    end
    confighash['captchaenabled'] = option
    File.open("./config.json", 'w') { |file| file.write(JSON.dump(confighash)) }
    event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
      embed.colour = 0x2ECC70
      embed.title = "Set `captchaenabled` to `#{option}`"
    end
    next
  elsif setting == 'captcharole'
    unless option
      event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Oops...'
        embed.description = 'No role given'
      end
      next
    end
    if event.server.role(option) == nil
      event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Oops...'
        embed.description = "That role doesn't exist"
      end
      next
    end
    unless option.is_number?
      event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Oops...'
        embed.description = 'That is not a number'
      end
      next
    end
    configfile = File.read('./config.json')
    confighash = JSON.parse(configfile)
    confighash['captcharole'] = option
    File.open("./config.json", 'w') { |file| file.write(JSON.dump(confighash)) }
    event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
      embed.colour = 0x2ECC70
      embed.title = "Set `captcharole` to `#{option}`"
    end
    next
  elsif setting == 'joinrole'
    unless option
      event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Oops...'
        embed.description = 'No role given'
      end
      next
    end
    if event.server.role(option) == nil
      event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Oops...'
        embed.description = "That role doesn't exist"
      end
      next
    end
    unless option.is_number?
      event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Oops...'
        embed.description = 'That is not a number'
      end
      next
    end
    configfile = File.read('./config.json')
    confighash = JSON.parse(configfile)
    confighash['joinrole'] = option
    File.open("./config.json", 'w') { |file| file.write(JSON.dump(confighash)) }
    event.channel.send_embed('', nil, nil, false, nil, event.message) do |embed|
      embed.colour = 0x2ECC70
      embed.title = "Set `joinrole` to `#{option}`"
    end
    next
  end
end

bot.member_join do |event|
  unless event.server.bot.permission?(:kick_members)
    event.server.members.each do |member|
      if member.bot_account
        next
      end
      if member.permission?(:administrator)
        member.pm.send_embed do |embed|
          embed.colour = 0xFF0000
          embed.title = 'Oops...'
          embed.description = "I do not have the kick members permission\nI need the kick members permission to kick raiders"
        end
      end
    end
  end
  configfile = File.read('./config.json')
  confighash = JSON.parse(configfile)
  if confighash['timespan'] == nil
    timespan = 300
  else
    timespan = Integer(confighash['timespan']) * 60
  end
  if confighash['maxjoins'] == nil
    maxjoins = 10
  else
    maxjoins = Integer(confighash['maxjoins'])
  end

  if File.exist?("temp/#{event.server.id}.log")
    filetime = Time.parse(File.foreach("temp/#{event.server.id}.log").first)
    difference = Time.now - filetime
    if difference >= timespan
      file = File.open("temp/#{event.server.id}.log", "w")
      file.write(Time.now)
      file.write("\n#{event.user.id}")
      file.close
      next
    end
    file = File.open("temp/#{event.server.id}.log", "a")
    file.write("\n#{event.user.id}")
    file.close
    linecount = File.open("temp/#{event.server.id}.log", "r").each_line.count - 1
    if linecount >= maxjoins
      event.user.pm.send_embed do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Kicked by AntiRaider'
        embed.description = 'Hello, you have been kicked by AntiRaider because you might be a raider'
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'If you are not a raider please wait a few minutes and try to join again')
      end
      begin
        event.server.kick(event.user, 'Might be a raider - AntiRaider')
      rescue
        event.server.members.each do |member|
          if member.bot_account
            next
          end
          if member.permission?(:administrator)
            member.pm.send_embed do |embed|
              embed.colour = 0xFF0000
              embed.title = 'Oops...'
              embed.description = "I could not kick #{member.username}##{member.discriminator}"
            end
          end
        end
      ensure
        next
      end
    end
  else
    file = File.open("temp/#{event.server.id}.log", "w")
    file.write(Time.now)
    file.write("\n#{event.user.id}")
    file.close
  end
  if confighash['captchaenabled'] == nil || confighash['captchaenabled'] == 'false' && confighash['joinrole'] != nil
    joinrole = event.server.role(confighash['joinrole'])
    event.user.add_role(joinrole)
    next
  end
  if confighash['captchaenabled'] == 'true'
    captcharole = event.server.role(confighash['captcharole'])
    question, answer = captchagen
    event.user.pm.send_embed do |embed|
      embed.colour = 0x0080FF
      embed.title = 'Captcha'
      embed.description = "What is `#{question}`"
    end
    triesleft = 5
    event.user.await! do |captcha|
      unless captcha.message.content.is_number?
        false
        next
      end
      if Integer(captcha.message.content) == answer
        event.user.pm("Correct!")
        event.user.add_role(captcharole, 'Passed captcha - AntiRaider')
        true
      else
        triesleft -= 1
        if triesleft == 0
          event.user.pm('You are out of tries')
          event.server.kick(event.user, 'Failed captcha - AntiRaider')
          true
        end
        if triesleft == 1
          begin
            event.user.pm("Incorrect, you have #{triesleft} try left")
          rescue
          end
        elsif triesleft <= -1
          next
        else
          begin
            event.user.pm("Incorrect, you have #{triesleft} tries left")
          rescue
          end
        end
        false
      end
    end
  end
end

bot.run