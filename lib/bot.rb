# frozen_string_literal = true

require 'yaml'
require 'discordrb'
require 'dotenv'

require_relative 'translator'

Dotenv.load

module DialectoBot
  extend self

  @default_prefix = ENV['BOT_PREFIX']

  bot = Discordrb::Commands::CommandBot.new(
    token: ENV['DISCORD_TOKEN'],
    client_id: ENV['DISCORD_CLIENT_ID'],
    prefix: @default_prefix,
  )

  bot.command :trans do |event, from, *args|
    commands = load_commands
    command_help = "Usage: #{commands["trans"]["usage"]}"
    
    if args.empty?
      event.respond command_help
      next
    end

    if args[0].match(/^[a-zA-Z]{2}$/)
      to = args.shift.upcase
    else
      to = 'EN'
    end

    text = args.join(' ')

    translation = Translator.translate(text, from, to)
    event.respond translation
  end
  
  bot.command :langs do |event|
    Translator.get_available_languages(event)
  end

  bot.command :help do |event|
    commands_info = get_commands_info(@default_prefix)

    embed = Discordrb::Webhooks::Embed.new(
      title: "List of available commands",
      description: commands_info,
      color: 0x1D6BE5,
      timestamp: Time.now,
      footer: Discordrb::Webhooks::EmbedFooter.new(text: event.user.name)
    )

    event.channel.send_embed('', embed)
  end

  def get_commands_info(default_prefix)
    message = ""
    commands = load_commands

    if commands.nil?
      return "Error loading available commands."
    end

    raise "Loaded YAML is not a Hash" unless commands.is_a?(Hash)

    commands.each do |command, info|
      message += "`#{default_prefix}#{command}` - #{info['description']}\n"
    end
    
    message
  end

  def load_commands
    file_path = File.expand_path('../../docs/available-commands.yaml', __FILE__)
    YAML.load_file(file_path)
  rescue => err
    puts "Error loading available commands: #{err.message}"
    nil
  end

  at_exit do
    bot.stop
  end

  puts "The invite url: #{bot.invite_url}"
  puts "Type #{@default_prefix} to trigger the commands"

  bot.run
end