class KamigoController < ApplicationController
  require 'net/http'
  # protect_from_forgery with: :null_session

  def send_request
    uri = URI('http://localhost:3001/kamigo/response_body')
    http = Net::HTTP.new(uri.host, uri.port)
    http_request = Net::HTTP::Get.new(uri)
    http_response = http.request(http_request)

    render plain: JSON.pretty_generate(
      request_class: request.class,
      response_class: response.class,
      http_request_class: http_request.class,
      http_response_class: http_response.class
    )
    # response = Net::HTTP.get(uri)
    # render plain: translate_to_japanese(response)
  end

  # @POST request: LINE verify
  def webhook
    render plain: params
    head :ok
  end

  def translate_to_japanese(message)
    "#{message}です。"
  end

  def eat
    render plain: '吃土拉'
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
