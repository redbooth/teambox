module EmailSpec
  module BackgroundProcesses
    module DelayedJob
      def all_emails
        Delayed::Job.work_off
        super
      end

      def last_email_sent
        Delayed::Job.work_off
        super
      end

      def reset_mailer
        Delayed::Job.work_off
        super
      end

      def mailbox_for(address)
        Delayed::Job.work_off
        super
      end
    end

    module Compatibility
      if defined?(Delayed)
        include EmailSpec::BackgroundProcesses::DelayedJob
      end
    end
  end
end
