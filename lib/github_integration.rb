module GithubIntegration

  module Parser

    TASK_ID_IN_MESSAGE_REGEXP = /\s?\[(?:close-)?(\d+)\]/

    def self.commits_with_task_ids(p)
      payload = p.clone
      commits = {}
      payload["commits"].select {|c| c["message"].match(TASK_ID_IN_MESSAGE_REGEXP) }.each do |commit|
        matches = commit["message"].scan(TASK_ID_IN_MESSAGE_REGEXP)

        matches.each do |item|
          task_id = item[0].to_i
          commits[task_id] = [] unless commits[task_id]
          commit["close"] = true if commit["message"].include? "[close-"
          commits[task_id] << commit
        end
      end
      payload["commits"] = commits
      payload
    end

    def self.commits_without_task_ids(p)
       payload = p.clone
       payload["commits"].delete_if {|c| c["message"].match(TASK_ID_IN_MESSAGE_REGEXP) }
       payload
    end

    def self.get_branch_name_from_ref(ref)
      unless ref.empty?
        if matches = ref.split('/')
          matches.last
        end
      end
    end

    def self.task_close_in_any_commit?(commits)
      commits.find {|c| c['close'] == true}
    end

    def self.get_author_from_commits(commits)
      {:name => commits.last['author']['name'], :email => commits.last['author']['email']} unless commits.empty?
    end

  end

  module Builder

    def self.comment_body_from_payload_commits(commits, payload)
      anchor = payload['repository']['name']
      url = payload['repository']['url']

      if payload.has_key? 'ref'
        ref = payload['ref']
        anchor+= "/#{ref}"
        branch_name = GithubIntegration::Parser.get_branch_name_from_ref(ref)
        url+="/tree/#{branch_name}"
      end

      compare = payload.has_key?('compare') ? (" <a href=\"%s\">(compare)</a>" % payload['compare']) : ''
      text = ("Posted on Github: <a href=\"%s\">%s</a>%s\n\n" % [url, anchor, compare])

      commits.each do |commit|
        author_name = commit['author']['name']
        #author_email = commit['author']['email']
        message = commit['message'].gsub(GithubIntegration::Parser::TASK_ID_IN_MESSAGE_REGEXP, '')
        text << ("%s - <a href=\"%s\">%s</a>\n\n" % [author_name, commit['url'], message])
      end
      text
    end

  end

end