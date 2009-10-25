module Spec
  module Rails
    module Matchers
      def have_form_posting_to(url_or_path)
        return simple_matcher("have a form submitting via POST to '#{url_or_path}'") do |response|
          have_tag("form[method=post][action=#{url_or_path}]").matches?(response)
        end
      end

      def have_form_puting_to(url_or_path, id)
        return simple_matcher("have a form submitting via PUT to '#{url_or_path}/#{id}'") do |response|
          have_tag("form[method=post][action=#{url_or_path}/#{id}]").matches?(response)
          have_tag("input[name=_method][type=hidden][value=put]").matches?(response)
        end
      end
      
      def have_label_for(attribute, text)
        return simple_matcher("have a label for '#{attribute}' with value of '#{text}'") do |response|
          have_tag("label[for=#{attribute}]").matches?(response)
        end
      end
      
      def with_label_for(attribute, text)
        return simple_matcher("have a label for '#{attribute}' with value of '#{text}'") do |response|
          with_tag("label[for=#{attribute}]").matches?(response)
        end
      end

      def have_text_field_for(attribute)
        return simple_matcher("have a text field for '#{attribute}'") do |response|
          have_tag("input##{attribute}[type=text]").matches?(response)
        end
      end
      
      def with_text_field_for(attribute)
        return simple_matcher("with a text field for '#{attribute}'") do |response|
          with_tag("input##{attribute}[type=text]").matches?(response)
        end
      end

      def have_text_area_for(attribute)
        return simple_matcher("have a text field for '#{attribute}'") do |response|
          have_tag("textarea##{attribute}[type=text]").matches?(response)
        end
      end
      
      def with_text_area_for(attribute)
        return simple_matcher("have a text field for '#{attribute}'") do |response|
          with_tag("textarea##{attribute}[type=text]").matches?(response)
        end
      end
      
      def have_password_field_for(attribute)
        return simple_matcher("have a password field for '#{attribute}'") do |response|
          have_tag("input##{attribute}[type=password]").matches?(response)
        end
      end

      def with_password_field_for(attribute)
        return simple_matcher("have a password field for '#{attribute}'") do |response|
          with_tag("input##{attribute}[type=password]").matches?(response)
        end
      end
      
      def have_checkbox_for(attribute)
        return simple_matcher("have a checkbox for '#{attribute}'") do |response|
          have_tag("input##{attribute}[type=checkbox]").matches?(response)
        end
      end
      
      def with_checkbox_for(attribute)
        return simple_matcher("have a checkbox for '#{attribute}'") do |response|
          with_tag("input##{attribute}[type=checkbox]").matches?(response)
        end
      end

      def have_submit_button
        return simple_matcher("have a submit button") do |response|
          have_tag("input[type=submit]").matches?(response)
        end
      end
      
      def with_submit_button
        return simple_matcher("have a submit button") do |response|
          with_tag("input[type=submit]").matches?(response)
        end
      end

      def have_link_to(url_or_path, text = nil)
        return simple_matcher("have a link to '#{url_or_path}'") do |response|
          have_tag("a[href=#{url_or_path}]", text).matches?(response)
        end
      end
      
      def with_link_to(url_or_path, text = nil)
        return simple_matcher("have a link to '#{url_or_path}'") do |response|
          with_tag("a[href=#{url_or_path}]", text).matches?(response)
        end
      end
    end
  end
end