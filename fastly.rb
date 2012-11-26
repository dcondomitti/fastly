require 'bundler/setup'
require 'typhoeus'
require 'yaml'
require 'json'
require_relative 'stats_request'

ENDPOINT = 'https://api.fastly.com'
api_token = ENV['API_TOKEN']
environment = ENV['ENVIRONMENT']

headers = { 
  x_fastly_key: api_token
}

stats_requests = []

# Cache Status (hit ratio, etc)
stats_requests << StatsRequest.new(key: 'CacheStatus', value: 'Connections', label: 'cache_status')

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
