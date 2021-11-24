require 'discordrb'

bot = Discordrb::Bot.new(token: 'token here', intents: [:server_messages, :server_members])

bot.event.ServerMemberAddEvent do |event|
  puts event.user.username
end