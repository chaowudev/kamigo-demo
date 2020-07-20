class KamigoController < ApplicationController
  require 'net/http'
  require 'line/bot'

  protect_from_forgery with: :null_session

  def webhook
    reply_text = keyword_reply(received_text)
    reponse = reply_to_line(reply_text)

    head :ok
  end

  def received_text
    message = params['events'][0]['message']['text']

    message unless message.nil?
  end

  def keyword_reply(received_text)
    keyword_mappings = {
      'QQ': '不哭～不哭～',
      '好難過': '別難過QQ'
    }

    keyword_mappings[received_text.to_sym]
  end

  def reply_to_line(reply_text)
    return if reply_text.nil?
    # byebug

    reply_token = params['events'][0]['replyToken']
    message = {
      type: 'text',
      text: reply_text
    }

    client.reply_message(reply_token, message)
  end

  # LINE Bot API initialize
  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_id = ENV['LINE_CHANNEL_ID']
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def send_request
    uri = URI('http://localhost:3000/kamigo/response_body')
    http = Net::HTTP.new(uri.host, uri.port)
    http_request = Net::HTTP::Get.new(uri)
    http_response = http.request(http_request)

    render plain: JSON.pretty_generate(
      request_class: request.class,
      response_class: response.class,
      http_request_class: http_request.class,
      http_response_class: http_response.class
    )
  end

  def request_headers
    render plain: request.headers.to_h.reject { |key, val|
      key.include?('.')
    }.map { |key, val|
      "- #{key} : #{val}"
    }.sort.join("\n")
  end

  def request_body
    render plain: request.body
  end

  def response_headers
    # add sth into response headers
    response.headers['5566'] = 'QQ'

    render plain: response.headers.map { |key, val|
      "#{key} : #{val}"
    }.sort.join("\n")
  end

  # The action 'response_body' is used in Rails
  # Here use another name as 'show_response_body'
  def show_response_body
    puts "===這是設定前的 response.body: #{response.body}==="
    render plain: 'here is response body <3'
    puts "===這是設定後的 response.body: #{response.body}==="
  end
end
