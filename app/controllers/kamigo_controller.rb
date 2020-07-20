class KamigoController < ApplicationController
  require 'net/http'
  require 'line/bot'

  protect_from_forgery with: :null_session

  def webhook
    # 學說話指令要優先於關鍵字回覆指令
    reply_text = learn(received_text)
    reply_text = keyword_reply(received_text) if reply_text.nil?
    reply_text = echo2(channel_id, received_text) if reply_text.nil?

    save_received_text(channel_id, received_text)
    reply_to_line(reply_text)

    head :ok
  end

  def echo2(channel_id, received_text)
    recent_received_texts = Received.where(channel_id: channel_id, text: received_text).last(5)&.pluck(:text)
    last_replied_text = Reply.where(channel_id: channel_id).last&.text

    return unless received_text.in? recent_received_texts
    return if received_text == last_replied_text

    save_reply_text(channel_id, received_text)
    received_text
  end

  def channel_id
    source = params['events'][0]['source']

    source['groupId'] || source['userId']
  end

  def save_received_text(channel_id, received_text)
    return if received_text.nil?

    Received.create(channel_id: channel_id, text: received_text)
  end

  def save_reply_text(channel_id, received_text)
    return if received_text.nil?

    Reply.create(channel_id: channel_id, text: received_text)
  end

  def learn(received_text)
    return if received_text.nil?
    return unless received_text[0..6] == '卡米狗學說話;'

    received_text = received_text[7..-1]
    semicolon_index = received_text.index(';')

    return if semicolon_index.nil?

    keyword = received_text[0..semicolon_index - 1]
    message = received_text[semicolon_index + 1..-1]

    '好喔～好喔～' if KeywordMapping.create(keyword: keyword, message: message)
  end

  def received_text
    message = params['events'][0]['message']['text']

    message unless message.nil?
  end

  def keyword_reply(received_text)
    return if received_text.nil?

    KeywordMapping.where(keyword: received_text).last&.message
  end

  def reply_to_line(reply_text)
    return if reply_text.nil?

    reply_token = params['events'][0]['replyToken']
    message = {
      type: 'text',
      text: reply_text
    }

    response = client.reply_message(reply_token, message)
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
