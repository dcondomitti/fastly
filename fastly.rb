require 'bundler/setup'
require 'typhoeus'
require 'yaml'
require 'json'
require_relative 'stats_request'

ENDPOINT = 'https://api.fastly.com'
api_token = ENV['API_TOKEN']
service = ENV['SERVICE']
granularity = ENV['GRANULARITY']
environment = ENV['ENVIRONMENT']

headers = { 
  x_fastly_key: api_token
}

stats_requests = []

# Cache Status (hit ratio, etc)
stats_requests << StatsRequest.new(service: service, granularity: granularity)

requests = []
hydra = Typhoeus::Hydra.new

stats_requests.map do |stats_request|
  req = Typhoeus::Request.new stats_request.url, headers: headers
  req.on_complete do |response|
    if response.code == 200
      JSON.parse(response.body).each do |pop, metrics|
        metrics.each do |metric_name,value|
          puts "services.cdn.fastly.#{environment}.#{service}.#{pop}.#{metric_name} #{value} #{Time.now.to_i}".downcase
        end
      end
    end
  end
  hydra.queue(req)
end

hydra.run


