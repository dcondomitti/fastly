class StatsRequest
  attr_accessor :key
  
  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def url
    "#{ENDPOINT}/service/#{SERVICE}/stats/#{granularity}"
  end

  def content
    @content || @key.downcase
  end

  def platform
    @platform || DEFAULT_PLATFORM
  end
end