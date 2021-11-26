require 'discordrb'
require 'json'

jsonfile = File.read('./config.json')
jsonhash = JSON.parse(jsonfile)

bot = Discordrb::Bot.new(token: jsonhash['token'], intents: [:servers, :server_messages, :server_bans, :server_emojis, :server_integrations, :server_webhooks, :server_invites, :server_voice_states, :server_presences, :server_message_reactions, :server_message_typing, :direct_messages, :direct_message_reactions, :direct_message_typing, :server_members])

bot.member_join do |event|
  puts event.user.username
end

bot.run