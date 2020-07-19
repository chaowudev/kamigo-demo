class KamigoController < ApplicationController
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
