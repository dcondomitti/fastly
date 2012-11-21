require 'bundler/setup'
require 'typhoeus'
require 'yaml'
require 'json'
require_relative 'stats_request'

ENDPOINT = 'https://api.edgecast.com/v2'
CUSTOMER_NUMBER = ENV['CUSTOMER_NUMBER']
api_token = ENV['API_TOKEN']
environment = ENV['ENVIRONMENT']

headers = { 
  authorization: "TOK: #{api_token}"
}

stats_requests = []

# Cache Status (hit ratio, etc)
stats_requests << StatsRequest.new(key: 'CacheStatus', value: 'Connections', label: 'cache_status')

# HTTP Response Codes
stats_requests << StatsRequest.new(key: 'StatusCode', value: 'Connections', label: 'http_status')

# Total bandwidth
stats_requests << StatsRequest.new(content: 'bandwidth', key: 'Result', label: 'bandwidth')

requests = []
hydra = Typhoeus::Hydra.new

stats_requests.map do |stats_request|
  req = Typhoeus::Request.new stats_request.url, headers: headers
  req.on_complete do |response|
    if stats_request.value
      stats = JSON.parse(response.body).each_with_object({}) do |tuple, hash|
        hash[tuple[stats_request.key]] = tuple[stats_request.value]
      end
    else
      stats = { stats_request.key => JSON.parse(response.body)[stats_request.key] }
    end
    
    stats.each do |key,value|
      puts "services.cdn.edgecast.#{environment}.#{stats_request.label}.#{key} #{value} #{Time.now.to_i}".downcase
    end
  end
  hydra.queue(req)
end

hydra.run
