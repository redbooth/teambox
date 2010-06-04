class HooksController < ApplicationController

  no_login_required
  skip_before_filter :verify_authenticity_token

  def initialize
    @example_github_payload = <<-EOS
      {
        "before": "5aef35982fb2d34e9d9d4502f6ede1072793222d",
        "repository": {
          "url": "http://github.com/defunkt/github",
          "name": "github",
          "description": "You're lookin' at it.",
          "watchers": 5,
          "forks": 2,
          "private": 1,
          "owner": {
            "email": "chris@ozmm.org",
            "name": "defunkt"
          }
        },
        "commits": [
          {
            "id": "41a212ee83ca127e3c8cf465891ab7216a705f59",
            "url": "http://github.com/defunkt/github/commit/41a212ee83ca127e3c8cf465891ab7216a705f59",
            "author": {
              "email": "chris@ozmm.org",
              "name": "Chris Wanstrath"
            },
            "message": "okay i give in",
            "timestamp": "2008-02-15T14:57:17-08:00",
            "added": ["filepath.rb"]
          },
          {
            "id": "de8251ff97ee194a289832576287d6f8ad74e3d0",
            "url": "http://github.com/defunkt/github/commit/de8251ff97ee194a289832576287d6f8ad74e3d0",
            "author": {
              "email": "chris@ozmm.org",
              "name": "Chris Wanstrath"
            },
            "message": "update pricing a tad",
            "timestamp": "2008-02-15T14:36:34-08:00"
          }
        ],
        "after": "de8251ff97ee194a289832576287d6f8ad74e3d0",
        "ref": "refs/heads/master"
      }
    EOS
  end

  def create
    @source = params[:hook_name]
    @payload = params[:payload] || @example_github_payload

    output = case @source
              when "github" then post_from_github
              else 'Invalid hook'
              end

    render :text => output
  end
  
  protected

    def post_from_github
      return "Invalid project" unless @current_project

      push = JSON.parse(@payload)
      commits = push["commits"]

      text = "<h3>New code on <a href='#{push['repository']['url']}'>#{push['repository']['name']}</a></h3>\n\n"
      text << commits[0,10].collect do |commit|
        message = commit['message'].strip.split("\n").first
        "#{commit['author']['name']} - <a href='#{commit['url']}'>#{message}</a>"
      end.join("<br/>")

      user = @current_project.user
      target = nil

      @current_project.new_comment(user, target, {
        :body => "<div class='hook_#{@source}'>#{text}</div>",
        :user => @current_project.user
      }).save!

      RDiscount.new(text).to_html
    end
  
end