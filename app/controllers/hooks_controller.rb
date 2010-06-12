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
  
  def index
    
  end
  
  def show
    
  end
  
  def new

  end
  
  def edit
    
  end
  
  def update
  
  end
  
  def create
    
  end
  
  def push    
    @hook = Hook.find(:first, :conditions => {:key => params[:key]})
    params.merge!({:payload => @example_github_payload}) unless params[:payload]

    post = parse_data
    template = params[:template] || @hook.message

    create_comment(template, post)

    render :text => "OK"
  end
  
  protected

    def parse_data
      post = {:hook_time => Time.now.to_s}
      params.each do |k,v|
        begin
          case params[:format]
          when 'xml'  then data = XML.parse(v)
          when 'json' then data = JSON.parse(v)
          else data = v
          end
          post.merge!({k => data})
        rescue
          # we might want to notify @hook.user with an email?
          # If its not xml/json, just take the raw param
          post.merge!({k => v})
        end unless ['controller','key','action','method','format', 'template'].include?(k)
      end
      
      post
    end

    def create_comment(template, post)
      text = RDiscount.new(Mustache.render(template, post)).to_html
      
      @hook.project.new_comment(@hook.user, @hook.project, {
        :body => "<div class='hook'>#{text}</div>",
        :user => @hook.user}).save!
    end
end