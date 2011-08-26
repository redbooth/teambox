require 'spec_helper'

describe ApiV2::ConversationsController do

  before do
    make_a_typical_project

    @other_project = Factory.create(:project, :user => @observer)
    @other_project.add_user(@user)
  end

  describe "#index" do
    it "shows all conversations"
  end

  describe "#show" do
    it "shows conversation"
  end

end
