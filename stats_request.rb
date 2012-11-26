class StatsRequest
  attr_accessor :granularity, :service
  
  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def url
    "#{ENDPOINT}/service/#{service}/stats/#{granularity}"
  end

  def content
    @content || @key.downcase
  end

  def platform
    @platform || DEFAULT_PLATFORM
  end
end