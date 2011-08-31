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

  end

end