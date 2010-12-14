require 'rspec/expectations'

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

    RSpec::Matchers.define :have_subject do |expected|
      match do |given|
        if expected.is_a?(String)
          given.subject == expected
        else
          !!(given.subject =~ expected)
        end
      end
      description do
        expected.is_a?(String) ? "have subject of #{expected.inspect}" : "have subject matching #{expected.inspect}"
      end
      failure_message do |given|
        expected.is_a?(String) ? "expected the subject to be #{expected.inspect} but was #{given.subject.inspect}" : "expected the subject to match #{expected.inspect}, but did not.  Actual subject was: #{given.subject.inspect}"
      end
      negative_failure_message do |given|
        expected.is_a?(String) ? "expected the subject not to be #{expected.inspect} but was" : "expected the subject not to match #{expected.inspect} but #{given.subject.inspect} does match it."
      end
    end

    RSpec::Matchers.define :include_email_with_subject do |expected|
      match do |given_emails|
        if expected.is_a?(String)
          given_emails.map(&:subject).include?(expected)
        else
          !!(given_emails.any?{ |mail| mail.subject =~ expected })
        end
      end
      description do
        expected.is_a?(String) ? "include email with subject of #{expected.inspect}" : "include email with subject matching #{expected.inspect}"
      end
      failure_message do |given_emails|
        expected.is_a?(String) ? "expected at least one email to have the subject #{expected.inspect} but none did. Subjects were #{given_emails.map(&:subject).inspect}" : "expected at least one email to have a subject matching #{expected.inspect}, but none did. Subjects were #{given_emails.map(&:subject).inspect}"
      end
      negative_failure_message do |given_emails|
        expected.is_a?(String) ? "expected no email with the subject #{expected.inspect} but found at least one. Subjects were #{given_emails.map(&:subject).inspect}" : "expected no email to have a subject matching #{expected.inspect} but found at least one. Subjects were #{given_emails.map(&:subject).inspect}"
      end
    end

    RSpec::Matchers.define :have_body_text do |expected|
      normalized_expected = expected.gsub(/\s+/, " ")
      match do |given|
        normalized_body = given.body.gsub(/\s+/, " ")
        if expected.is_a?(String)
          normalized_body.include?(normalized_expected)
        else
          !!(given.body =~ expected)
        end
      end
      description do
        expected.is_a?(String) ? "have body including #{normalized_expected.inspect}" : "have body matching #{expected.inspect}"
      end
      failure_message do |given|
        expected.is_a?(String) ? "expected the body to contain #{normalized_expected.inspect} but was #{given.body.gsub(/\s+/, " ").inspect}" : "expected the body to match #{expected.inspect}, but did not.  Actual body was: #{given.body.inspect}"
      end
      negative_failure_message do |given|
        expected.is_a?(String) ? "expected the body not to contain #{normalized_expected.inspect} but was #{given.body.gsub(/\s+/, " ").inspect}" : "expected the body not to match #{expected.inspect} but #{given.body.inspect} does match it."
      end
    end

    RSpec::Matchers.define :have_header do |expected_name, expected_value|
      match do |given_emails|
        if expected_value.is_a?(String)
          given.header[expected_name].to_s == expected_value
        else
          given.header[expected_name].to_s =~ expected_value
        end
      end
      description do
        expected.is_a?(String) ? "have header #{expected_name}: #{expected_value}" : "have header #{expected_name} with value matching #{expected_value.inspect}"
      end
      failure_message do
        expected.is_a?(String) ? "expected the headers to include '#{expected_name}: #{expected_value}' but they were #{given.header.inspect}" : "expected the headers to include '#{expected_name}' with a value matching #{expected_value.inspect} but they were #{given.header.inspect}"
      end
      negative_failure_message do
        expected.is_a?(String) ? "expected the headers not to include '#{expected_name}: #{expected_value}' but they were #{given.header.inspect}" : "expected the headers not to include '#{expected_name}' with a value matching #{expected_value.inspect} but they were #{given.header.inspect}"
      end
    end

  end
end
