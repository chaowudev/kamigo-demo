class PushMessagesController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    text = params[:text]

    User.all.each do |user|
      push_messages_to_line(user.channel_id, text)
    end

    redirect_to '/push_messages/new'
  end

  private

  def push_messages_to_line(channel_id, text)
    return if channel_id.nil? || text.nil?

    message = {
      type: 'text',
      text: text
    }

    client.push_message(channel_id, message)
  end
end
