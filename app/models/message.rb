# frozen_string_literal = true

class Message
  attr_accessor :title, :content

  def initialize(title:, content:)
    @title = title
    @content = content
  end
end