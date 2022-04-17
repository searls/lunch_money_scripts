require "net/http"
require "cgi"
require "json"

module Api
  ENDPOINT = "https://dev.lunchmoney.app/v1/"

  def self.query_string(options)
    return "" if options.nil? || options.empty?
    "?" + options.map { |(k, v)| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
  end

  def self.get(api_key:, path:, options:, data_key: path, offset: 0)
    uri = URI(ENDPOINT + path + query_string(options.merge({offset: offset, limit: 500})))
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      req = Net::HTTP::Get.new(uri.request_uri)
      req["Authorization"] = "Bearer #{api_key}"
      response = http.request(req)
      json = JSON.parse(response.body)
      raise_api_error_maybe(json)
      results = json[data_key]
      if results.length > 0
        puts "Fetched #{results.length} (#{results.length + offset} total) #{data_key}"
        results += get(
          api_key: api_key,
          path: path,
          data_key: data_key,
          options: options,
          offset: offset + results.size
        )
      end
      return results
    end
  end

  def self.post(api_key:, path:, body:)
    uri = URI(ENDPOINT + path)
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      req = Net::HTTP::Post.new(uri.request_uri)
      req["Authorization"] = "Bearer #{api_key}"
      req["Content-Type"] = "application/json"
      req.set_form_data(body)
      response = http.request(req)
      json = JSON.parse(response.body)
      raise_api_error_maybe(json)
      json
    end
  end

  def self.raise_api_error_maybe(json)
    return unless json.is_a?(Hash) && json["error"]
    message = if json["error"].is_a?(String)
      json["error"]
    elsif json["error"].is_a?(Array)
      json["error"].join("\n")
    else
      json["error"].inspect
    end

    if message.include?("is in a transaction group already")
      warn message
    else
      raise message
    end
  end
end
