require 'spec_helper'

describe GithubIntegration  do

  before do
    @payload = {"repository"=>{"name"=>"github", "private"=>1, "watchers"=>5, "url"=>"http://github.com/defunkt/github", "forks"=>2,
        "description"=>"You're lookin' at it.", "owner"=>{"name"=>"defunkt", "email"=>"chris@ozmm.org"}},
      "after"=>"de8251ff97ee194a289832576287d6f8ad74e3d0", "ref"=>"refs/heads/master",
      "commits"=>[
        {"added"=>["filepath.rb"], "timestamp"=>"2008-02-15T14:57:17-08:00",
          "author"=>{"name"=>"Chris Wanstrath", "email"=>"chris@ozmm.org"},
          "url"=>"http://github.com/defunkt/github/commit/41a212ee83ca127e3c8cf465891ab7216a705f59",
          "id"=>"41a212ee83ca127e3c8cf465891ab7216a705f59",
          "message"=>"Check this file, task number [123]"
        },
        {"timestamp"=>"2008-02-15T14:36:34-08:00",
          "author"=>{"name"=>"Chris Wanstrath", "email"=>"chris@ozmm.org"},
          "url"=>"http://github.com/defunkt/github/commit/de8251ff97ee194a289832576287d6f8ad74e3d0",
          "id"=>"de8251ff97ee194a289832576287d6f8ad74e3d0", "message"=>"No task id in this message"
        },
        {"timestamp"=>"2008-03-15T14:50:38-09:00",
          "author"=>{"name"=>"Chris Wanstrath", "email"=>"chris@ozmm.org"},
          "url"=>"http://github.com/defunkt/github/commit/f9f251ff97ee194a289832576287d6f8ad747y7y",
          "id"=>"f9f251ff97ee194a289832576287d6f8ad747y7y", "message"=>"Finish with task [close-123]"
        },
        {"timestamp"=>"2008-04-15T17:50:38-09:00",
          "author"=>{"name"=>"Chris Wanstrath", "email"=>"chris@ozmm.org"},
          "url"=>"http://github.com/defunkt/github/commit/jyRty1ff97ee194uyy7289832576287d6f8af5rt",
          "id"=>"jyRty1ff97ee194uyy7289832576287d6f8af5rt", "message"=>"Updates for task [456]"
        }
      ],
      "before"=>"5aef35982fb2d34e9d9d4502f6ede1072793222d"}
  end

  it "should leave only commits with task id and group them by it" do

    payload_with_task_ids = GithubIntegration::Parser.commits_with_task_ids(@payload)

    payload_with_task_ids["commits"].should == {
      456=>[
        {"timestamp"=>"2008-04-15T17:50:38-09:00",
          "author"=>{"name"=>"Chris Wanstrath", "email"=>"chris@ozmm.org"},
          "url"=>"http://github.com/defunkt/github/commit/jyRty1ff97ee194uyy7289832576287d6f8af5rt",
          "id"=>"jyRty1ff97ee194uyy7289832576287d6f8af5rt", "message"=>"Updates for task [456]"
        }],
      123=>[
        {"added"=>["filepath.rb"], "author"=>{"name"=>"Chris Wanstrath", "email"=>"chris@ozmm.org"},
          "timestamp"=>"2008-02-15T14:57:17-08:00",
          "url"=>"http://github.com/defunkt/github/commit/41a212ee83ca127e3c8cf465891ab7216a705f59",
          "id"=>"41a212ee83ca127e3c8cf465891ab7216a705f59", "message"=>"Check this file, task [123]"},
        {"author"=>{"name"=>"Chris Wanstrath", "email"=>"chris@ozmm.org"}, "timestamp"=>"2008-03-15T14:50:38-09:00",
          "url"=>"http://github.com/defunkt/github/commit/f9f251ff97ee194a289832576287d6f8ad747y7y",
          "id"=>"f9f251ff97ee194a289832576287d6f8ad747y7y",
          "close" => true,
          "message"=>"Finish with task [close-123]"}
      ]}
  end

  it "should leave only commits which do not contain task id" do

    payload_without_task_ids = GithubIntegration::Parser.commits_without_task_ids(@payload)

    payload_without_task_ids["commits"].should == [{"timestamp"=>"2008-02-15T14:36:34-08:00",
        "author"=>{"name"=>"Chris Wanstrath", "email"=>"chris@ozmm.org"},
        "url"=>"http://github.com/defunkt/github/commit/de8251ff97ee194a289832576287d6f8ad74e3d0",
        "id"=>"de8251ff97ee194a289832576287d6f8ad74e3d0", "message"=>"No task id in this message"
      }]
  end

end