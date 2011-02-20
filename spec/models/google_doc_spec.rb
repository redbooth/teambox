require 'spec_helper'

describe GoogleDoc do
  it { should belong_to(:user) }
  it { should belong_to(:project) }
  it { should belong_to(:comment) }
end