require 'bundler/setup'
require 'typhoeus'
require 'yaml'
require 'json'

endpoint = 'https://api.edgecast.com/v2'
customer_number = ENV['CUSTOMER_NUMBER']
api_token = ENV['API_TOKEN']
environment = ENV['ENVIRONMENT']

headers = { 
  authorization: "TOK: #{api_token}"
}

stats_requests = []

# Cache Status (hit ratio, etc)
stats_requests << {
  url: "#{endpoint}/realtimestats/customers/#{customer_number}/media/8/cachestatus",
  key: 'CacheStatus',
  value: 'Connections',
  label: 'cache_status'
}

# HTTP Response Codes
stats_requests << {
  url: "#{endpoint}/realtimestats/customers/#{customer_number}/media/8/statuscode",
  key: 'StatusCode',
  value: 'Connections',
  label: 'http_status'
}

# Total bandwidth
stats_requests << {
  url: "#{endpoint}/realtimestats/customers/#{customer_number}/media/8/bandwidth",
  key: 'Result',
  label: 'bandwidth'
}

requests = []
hydra = Typhoeus::Hydra.new

stats_requests.map do |request|
  req = Typhoeus::Request.new request[:url], headers: headers
  req.on_complete do |response|

    if request[:value]
      stats = JSON.parse(response.body).each_with_object({}) do |tuple, hash|
        hash[tuple[request[:key]]] = tuple[request[:value]]
      end
    else
      stats = { request[:key] => JSON.parse(response.body)[request[:key]] }
    end
    
    stats.each do |key,value|
      puts "stats.cdn.edgecast.#{environment}.#{request[:label]}.#{key}: #{value}".downcase
    end
  end
  hydra.queue(req)
end

hydra.run
