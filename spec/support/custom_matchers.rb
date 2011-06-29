RSpec::Matchers.define :be_ascendant do
  match do |actual|
    return true if actual.empty?
    actual[1..-1].inject(actual[0]) { |r,e| r && e >= r && e }
  end
end

RSpec::Matchers.define :be_descendant do
  match do |actual|
    return true if actual.empty?
    actual[1..-1].inject(actual[0]) { |r,e| r && e <= r && e }
  end
end

RSpec::Matchers.define :be_equivelent_json_as do |expected|
  match do |actual|
    MultiJson.decode(actual) == MultiJson.decode(expected)
  end
  
  failure_message_for_should do |actual|
    "json should be equivelent:\nactual:   #{actual.inspect}\nexpected: #{expected.inspect}"
  end

  failure_message_for_should_not do |actual|
    "json should not be equivelent:\nactual:   #{actual.inspect}\nexpected: #{expected.inspect}"
  end

  description do
    "be equivelent json to #{expected}"
  end
end

