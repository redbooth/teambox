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

