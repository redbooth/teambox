                attributes :id,
                           :user_id,
                           :source_user_id,
                           :role

                code :type do |a|
                  a.class.to_s
                end

                code :user do |a|
                  partial('shared/_user', :object => a.user)
                end
