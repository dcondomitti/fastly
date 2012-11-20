class StatsRequest
  attr_accessor :content, :key, :value, :label, :platform

  # HTTP small object
  DEFAULT_PLATFORM = 8

  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def url
    "#{ENDPOINT}/realtimestats/customers/#{CUSTOMER_NUMBER}/media/#{platform}/#{content}"
  end

  def content
    @content || @key.downcase
  end

  def platform
    @platform || DEFAULT_PLATFORM
  end
end