# frozen_string_literal: true

require 'yaml'
require 'discordrb'
require 'dotenv'

Dotenv.load

available_commands = YAML.load_file('docs/available-commands.yaml')

bot_prefix = ENV['BOT_PREFIX']
bot = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], client_id: ENV['CLIENT_ID'], prefix: bot_prefix

puts "The invite url: #{bot.invite_url}"
puts "Type #{bot_prefix} to trigger the commands"

bot.command :trit do |message, *args|
  message = args.join(' ')

  "#{message} pong..."
end

bot.command :help do |event|
  message = "\n"

  available_commands.each do |command, info|
    message += "**!#{command}**: #{info['description']}\n"
  end

  event.send_embed do |embed|
    embed.title = "Translate It - !help"
    embed.description = "This is a list of available commands"
  
    embed.color = 0x1D6BE5
    embed.add_field(name: "-----------------------", value: message)
    embed.add_field(name: "-----------------------", value: '')
  
    embed.timestamp = Time.now
  end
end

at_exit { bot.stop }
bot.run