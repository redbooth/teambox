module EmailSpec

    module Matchers

    class DeliverTo

      def initialize(expected_email_addresses_or_objects_that_respond_to_email)
        emails = expected_email_addresses_or_objects_that_respond_to_email.map do |email_or_object|
          email_or_object.kind_of?(String) ? email_or_object : email_or_object.email
        end

        @expected_email_addresses = emails.sort
      end

      def description
        "be delivered to #{@expected_email_addresses.inspect}"
      end

      def matches?(email)
        @email = email
        @actual_recipients = (email.to || []).sort
        @actual_recipients == @expected_email_addresses
      end

      def failure_message
        "expected #{@email.inspect} to deliver to #{@expected_email_addresses.inspect}, but it delivered to #{@actual_recipients.inspect}"
      end

      def negative_failure_message
        "expected #{@email.inspect} not to deliver to #{@expected_email_addresses.inspect}, but it did"
      end
    end

    def deliver_to(*expected_email_addresses_or_objects_that_respond_to_email)
      DeliverTo.new(expected_email_addresses_or_objects_that_respond_to_email.flatten)
    end

    alias :be_delivered_to :deliver_to

    class DeliverFrom

      def initialize(email)
        @expected_email_addresses = email
      end

      def description
        "be delivered from #{@expected_email_addresses.inspect}"
      end

      def matches?(email)
        @email = email
        @actual_sender = (email.from || []).first
        @actual_sender.eql? @expected_email_addresses
      end

      def failure_message
        "expected #{@email.inspect} to deliver from #{@expected_email_addresses.inspect}, but it delivered from #{@actual_sender.inspect}"
      end

      def negative_failure_message
        "expected #{@email.inspect} not to deliver from #{@expected_email_addresses.inspect}, but it did"
      end
    end

    def deliver_from(email)
      DeliverFrom.new(email)
    end

    alias :be_delivered_from :deliver_from

    class BccTo

      def initialize(expected_email_addresses_or_objects_that_respond_to_email)
        emails = expected_email_addresses_or_objects_that_respond_to_email.map do |email_or_object|
          email_or_object.kind_of?(String) ? email_or_object : email_or_object.email
        end

        @expected_email_addresses = emails.sort
      end

      def description
        "be bcc'd to #{@expected_email_addresses.inspect}"
      end

      def matches?(email)
        @email = email
        @actual_recipients = (email.bcc || []).sort
        @actual_recipients == @expected_email_addresses
      end

      def failure_message
        "expected #{@email.inspect} to bcc to #{@expected_email_addresses.inspect}, but it was bcc'd to #{@actual_recipients.inspect}"
      end

      def negative_failure_message
        "expected #{@email.inspect} not to bcc to #{@expected_email_addresses.inspect}, but it did"
      end
    end

    def bcc_to(*expected_email_addresses_or_objects_that_respond_to_email)
      BccTo.new(expected_email_addresses_or_objects_that_respond_to_email.flatten)
    end

    def have_subject(expected)
      simple_matcher do |given, matcher|
        given_subject = given.subject

        if expected.is_a?(String)
          matcher.description = "have subject of #{expected.inspect}"
          matcher.failure_message = "expected the subject to be #{expected.inspect} but was #{given_subject.inspect}"
          matcher.negative_failure_message = "expected the subject not to be #{expected.inspect} but was"

          given_subject == expected
        else
          matcher.description = "have subject matching #{expected.inspect}"
          matcher.failure_message = "expected the subject to match #{expected.inspect}, but did not.  Actual subject was: #{given_subject.inspect}"
          matcher.negative_failure_message = "expected the subject not to match #{expected.inspect} but #{given_subject.inspect} does match it."

          !!(given_subject =~ expected)
        end
      end
     end

     def include_email_with_subject(expected)
       simple_matcher do |given_emails, matcher|

         if expected.is_a?(String)
           matcher.description = "include email with subject of #{expected.inspect}"
           matcher.failure_message = "expected at least one email to have the subject #{expected.inspect} but none did. Subjects were #{given_emails.map(&:subject).inspect}"
           matcher.negative_failure_message = "expected no email with the subject #{expected.inspect} but found at least one. Subjects were #{given_emails.map(&:subject).inspect}"

           given_emails.map(&:subject).include?(expected)
         else
           matcher.description = "include email with subject matching #{expected.inspect}"
           matcher.failure_message = "expected at least one email to have a subject matching #{expected.inspect}, but none did. Subjects were #{given_emails.map(&:subject).inspect}"
           matcher.negative_failure_message = "expected no email to have a subject matching #{expected.inspect} but found at least one. Subjects were #{given_emails.map(&:subject).inspect}"

           !!(given_emails.any?{ |mail| mail.subject =~ expected })
         end
       end
     end

     def have_body_text(expected)
       simple_matcher do |given, matcher|

         if expected.is_a?(String)
           normalized_body = given.body.gsub(/\s+/, " ")
           normalized_expected = expected.gsub(/\s+/, " ")
           matcher.description = "have body including #{normalized_expected.inspect}"
           matcher.failure_message = "expected the body to contain #{normalized_expected.inspect} but was #{normalized_body.inspect}"
           matcher.negative_failure_message = "expected the body not to contain #{normalized_expected.inspect} but was #{normalized_body.inspect}"

           normalized_body.include?(normalized_expected)
         else
           given_body = given.body
           matcher.description = "have body matching #{expected.inspect}"
           matcher.failure_message = "expected the body to match #{expected.inspect}, but did not.  Actual body was: #{given_body.inspect}"
           matcher.negative_failure_message = "expected the body not to match #{expected.inspect} but #{given_body.inspect} does match it."

           !!(given_body =~ expected)
         end
       end
      end

      def have_header(expected_name, expected_value)
        simple_matcher do |given, matcher|
          given_header = given.header

          if expected_value.is_a?(String)
            matcher.description = "have header #{expected_name}: #{expected_value}"
            matcher.failure_message = "expected the headers to include '#{expected_name}: #{expected_value}' but they were #{given_header.inspect}"
            matcher.negative_failure_message = "expected the headers not to include '#{expected_name}: #{expected_value}' but they were #{given_header.inspect}"

            given_header[expected_name].to_s == expected_value
          else
            matcher.description = "have header #{expected_name} with value matching #{expected_value.inspect}"
            matcher.failure_message = "expected the headers to include '#{expected_name}' with a value matching #{expected_value.inspect} but they were #{given_header.inspect}"
            matcher.negative_failure_message = "expected the headers not to include '#{expected_name}' with a value matching #{expected_value.inspect} but they were #{given_header.inspect}"

            given_header[expected_name].to_s =~ expected_value
          end
        end
      end

  end
end
