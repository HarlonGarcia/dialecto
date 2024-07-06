# frozen_string_literal = true

require 'deepl'
require 'dotenv'
Dotenv.load

module Translator
  extend self

  raise "DEEPL_API_KEY not found in environment variables" unless ENV['DEEPL_API_KEY']

  DeepL.configure do |config|
    config.auth_key = ENV['DEEPL_API_KEY']
    config.host = ENV['DEEPL_API_URL']
  end

  def translate(text, language)
    begin
      translation = DeepL.translate(text, nil, language)
      translation.text
    rescue StandardError => err
      "Error: #{err.message}"
    end
  end

  def get_available_languages(event)
    languages = ""

    begin
      DeepL.languages.each do |lang|
        languages += "`#{lang.code}` - #{lang.name}\n"
      end
    rescue StandardError => err
      languages = "Error fetching languages: #{err.message}"
    end

    embed = Discordrb::Webhooks::Embed.new(
      title: "List of available languages",
      description: languages,
      color: 0x1D6BE5,
      timestamp: Time.now,
      footer: Discordrb::Webhooks::EmbedFooter.new(text: event.user.name)
    )

    event.channel.send_embed('', embed)
  end
end