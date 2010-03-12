require "net/pop"
 
namespace :mail do
  desc "Download inbox"
  task :inbox => :environment do
 
    Rails.logger.info 'Running Mail Importer...'
 
    config = APP_CONFIG['incoming']
 
    Net::POP3.start(config['server'], nil, config['username'], config['password']) do |pop|
      if pop.mails.empty?
        Rails.logger.info 'No mail.'
      else
        pop.mails.each do |email|
          begin
            Rails.logger.info 'Receiving mail...'
            Emailer.receive(email.pop)
          rescue Exception => e
            Rails.logger.info 'Error receiving email at ' + Time.current.to_s + '::: ' + e.message
          end
          email.delete
        end
      end
    end
    Rails.logger.info 'Finished Mail Importer.'
 
  end
end