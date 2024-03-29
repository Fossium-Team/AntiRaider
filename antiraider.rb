# Copyright (c) 2021 Fossium-Team
# See LICENSE in the project root for license information.

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
  event.channel.send_embed do |embed|
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

bot.command :config, description: 'Configure the bot' do |event, category, setting, option|
  unless event.user.permission?(:administrator)
    event.channel.send_embed do |embed|
      embed.colour = 0xFF0000
      embed.title = 'Oops..'
      embed.description = "You need to have the `Administrator` permission to use this command"
    end
    next
  end
  unless category
    configfile = File.read('./config.json')
    confighash = JSON.parse(configfile)
    if confighash['timespan'] == nil
      timespan = "60"
    else
      timespan = Integer(confighash['timespan']) * 60
    end
    if confighash['maxjoins'] == nil
      maxjoins = "3"
    else
      maxjoins = Integer(confighash['maxjoins'])
    end
    if confighash['antiraidenabled'] == nil
      antiraidenabled = "false"
    else
      antiraidenabled = confighash['antiraidenabled']
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

    event.channel.send_embed do |embed|
      embed.colour = 0x0080FF
      embed.title = 'Settings'
      embed.fields = [
        Discordrb::Webhooks::EmbedField.new(
          name: 'AntiRaid:',
          value: "**Enabled**\nCurrently: #{antiraidenabled}\n**Rate limit**\nCurrently: #{maxjoins} new member(s) every #{timespan} seconds"
        ),
        Discordrb::Webhooks::EmbedField.new(
          name: 'Captcha:',
          value: "**Enabled**\nCurrently: #{captchaenabled}\n**Captcha role** (The role given after a user passes the captcha)\nCurrently: `#{captcharole}`"
        ),
        Discordrb::Webhooks::EmbedField.new(
          name: 'Misc:',
          value: "**joinrole** (The role given when a user joins the server)\nCurrently: #{joinrole}"
        ),
        Discordrb::Webhooks::EmbedField.new(
          name: 'Categories and options',
          value: "AntiRaid:\n- **enabled** - `true` or `false`\n- **ratelimit** - number/number\nCaptcha:\n- **enabled** - `true` or `false`\n- **role** - role ID\nMisc:\n- **joinrole** - role ID or none\n\nFor example: `ar!config antiraid ratelimit 3/60`\nor `ar!config captcha enabled true`"
        )
      ]
    end
    next
  end
  unless setting
    event.channel.send_embed do |embed|
      embed.colour = 0xFF0000
      embed.title = 'Oops...'
      embed.description = 'No setting given'
    end
    next
  end
  unless option
    event.channel.send_embed do |embed|
      embed.colour = 0xFF0000
      embed.title = 'Oops...'
      embed.description = 'No option given'
    end
    next
  end
  if category.downcase == 'antiraid'
    if setting.downcase == 'enabled'
      if option.downcase != "true" && option.downcase != "false"
        event.channel.send_embed do |embed|
          embed.colour = 0xFF0000
          embed.title = 'Oops...'
          embed.description = "Incorrect option\nCorrect options: true and false"
        end
        next
      end
      configfile = File.read('./config.json')
      confighash = JSON.parse(configfile)
      confighash['antiraidenabled'] = option.downcase
      File.open("./config.json", 'w') { |file| file.write(JSON.dump(confighash)) }
      event.channel.send_embed do |embed|
        embed.colour = 0x2ECC70
        embed.title = "Set `antiraidenabled` to `#{option.downcase}`"
      end
      next
    elsif setting.downcase == 'ratelimit'
      option = option.downcase.split('/')
      unless option[2] == nil
        event.channel.send_embed do |embed|
          embed.colour = 0xFF0000
          embed.title = 'Oops...'
          embed.description = 'Invalid syntax'
        end
        next
      end
      unless option[0].is_number? && option[1].is_number?
        event.channel.send_embed do |embed|
          embed.colour = 0xFF0000
          embed.title = 'Oops...'
          embed.description = 'That is not a number'
        end
        next
      end
      configfile = File.read('./config.json')
      confighash = JSON.parse(configfile)
      confighash['maxjoins'] = option[0]
      confighash['timespan'] = option[1]
      File.open("./config.json", 'w') { |file| file.write(JSON.dump(confighash)) }
      event.channel.send_embed do |embed|
        embed.colour = 0x2ECC70
        embed.title = "Set `ratelimit` to `#{option.downcase}`"
      end
      next
    end
  elsif category.downcase == 'captcha'
    if option.downcase == 'enabled'
      if option.downcase != "true" && option.downcase != "false"
        event.channel.send_embed do |embed|
          embed.colour = 0xFF0000
          embed.title = 'Oops...'
          embed.description = "Incorrect option\nCorrect options: true and false"
        end
        next
      end
      configfile = File.read('./config.json')
      confighash = JSON.parse(configfile)
      if confighash['captcharole'] == nil && option.downcase != "false"
        event.channel.send_embed do |embed|
          embed.colour = 0xFF0000
          embed.title = 'Oops...'
          embed.description = "Please set `captcharole` first"
        end
        next
      end
      confighash['captchaenabled'] = option.downcase
      File.open("./config.json", 'w') { |file| file.write(JSON.dump(confighash)) }
      event.channel.send_embed do |embed|
        embed.colour = 0x2ECC70
        embed.title = "Set `captchaenabled` to `#{option.downcase}`"
      end
      next
    elsif option.downcase == 'role'
      unless option.is_number?
        event.channel.send_embed do |embed|
          embed.colour = 0xFF0000
          embed.title = 'Oops...'
          embed.description = 'That is not a number'
        end
        next
      end
      if event.server.role(option) == nil
        event.channel.send_embed do |embed|
          embed.colour = 0xFF0000
          embed.title = 'Oops...'
          embed.description = "That role doesn't exist"
        end
        next
      end
      configfile = File.read('./config.json')
      confighash = JSON.parse(configfile)
      confighash['captcharole'] = option
      File.open("./config.json", 'w') { |file| file.write(JSON.dump(confighash)) }
      event.channel.send_embed do |embed|
        embed.colour = 0x2ECC70
        embed.title = "Set `captcharole` to `#{option}`"
      end
      next
    end
  elsif category.downcase == 'misc'
    if setting.downcase == 'joinrole'
      unless option.is_number?
        event.channel.send_embed do |embed|
          embed.colour = 0xFF0000
          embed.title = 'Oops...'
          embed.description = 'That is not a number'
        end
        next
      end
      if event.server.role(option) == nil
        event.channel.send_embed do |embed|
          embed.colour = 0xFF0000
          embed.title = 'Oops...'
          embed.description = "That role doesn't exist"
        end
        next
      end
      configfile = File.read('./config.json')
      confighash = JSON.parse(configfile)
      confighash['joinrole'] = option
      File.open("./config.json", 'w') { |file| file.write(JSON.dump(confighash)) }
      event.channel.send_embed do |embed|
        embed.colour = 0x2ECC70
        embed.title = "Set `joinrole` to `#{option}`"
      end
      next
    end
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
          embed.description = "I do not have the kick members permission\nI need the kick members permission to kick users that are raiding your server"
        end
      end
    end
  end
  configfile = File.read('./config.json')
  confighash = JSON.parse(configfile)
  if confighash['timespan'] == nil
    timespan = 60
  else
    timespan = Integer(confighash['timespan'])
  end
  if confighash['maxjoins'] == nil
    maxjoins = 3
  else
    maxjoins = Integer(confighash['maxjoins'])
  end

  if File.exist?("temp/#{event.server.id}.json")
    logfile = File.read("temp/#{event.server.id}.json")
    loghash = JSON.parse(logfile)
    filetime = Time.parse(loghash['time'])
    difference = Time.now - filetime
    if difference >= timespan
      loghash = {:time => Time.now}
      loghash['joins'] = "1"
      File.open("temp/#{event.server.id}.json", 'w') { |file| file.write(JSON.dump(loghash)) }
      next
    end
    loghash['joins'] = "#{Integer(loghash['joins']) + 1}"
    File.open("temp/#{event.server.id}.json", 'w') { |file| file.write(JSON.dump(loghash)) }
    joincount = Integer(loghash['joins'])
    if joincount >= maxjoins
      event.user.pm.send_embed do |embed|
        embed.colour = 0xFF0000
        embed.title = 'Kicked by AntiRaider'
        embed.description = "You have been kicked by AntiRaider because you might be tring to raid that server"
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'If you are not trying to raid please wait a few minutes and try to join again')
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
    loghash = {:time => Time.now}
    loghash['joins'] = "1"
    File.open("temp/#{event.server.id}.json", 'w') { |file| file.write(JSON.dump(loghash)) }
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
