rspec-on-rails-matchers
=======================

Setup
------

Dependencies:
-------------

  * rspec
  * rspec_on_rails

Overview
--------

Adds the following RSpec matchers:

  * Associations:
    Verify that the association has been defined. (doesn't verify that the association works!)

    object.should have_many(:association)
    example: @post.should have_many(:comments)
    TM snippet: [mshm + tab] (Model Should Have Many)

    object.should belong_to(:association)
    example: @comment.should belong_to(:post)
    TM snippet: [msbt + tab]

    object.should have_one(:association)
    user.should have_one(:social_security_number)
    TM snippet: [msho + tab]

    object.should have_and_belong_to_many(:association)
    project.should have_and_belong_to_many(:categories)
    TM snippet: [mshabtm + tab]


  * Validations:
    Verify that a validation has been defined. (doesn't test the validation itself)

    object.should validate_presence_of(:attribute)
    TM snippet: [msvp + tab]

    object.should validate_confirmation_of(:attribute)
    TM snippet: [msvc + tab]

    object.should validate_uniqueness_of(:attribute)
    TM snippet: [msvu + tab]

    object.should validate_length_of(:attribute, :within => 5..10)
    object.should validate_length_of(:attribute, :is => 5)
    TM snippet: [msvl + tab]

  * Observers:
    Verify that the observer is observing a class. (doesn't verify that the observation works)
    
    object.should observe(:model)
    example: GroupObserver.should observe(Group)

  * Views:
    Verifies that the views contains some tags.

    response.should have_form_posting_to(url_or_path)
    TM snippet: [hfpt + tab]

    response.should have_form_putting_to(url_or_path)
    
    response.should have_text_field_for(:attribute)
    TM snippet: [htff + tab]

    response.should have_label_for(:attribute)
    TM snippet: [hlf + tab]

    response.should have_password_field_for(:attribute)
    TM snippet: [hpff + tab]

    response.should have_checkbox_for(:attribute)
    TM snippet: [hcf + tab]

    response.should have_submit_button
    TM snippet: [hsb + tab]

    response.should have_link_to(url_or_path, "optional_text")
    TM snippet: [hlt + tab]

    * nested view tests:
      for instance:

      response.should have_form_posting_to(url_or_path) do
        with_text_field_for(:attribute)
      end

      with_text_field_for(:attribute)
      TM snippet: [wtff + tab]

      with_label_for(:attribute)
      TM snippet: [wlf + tab]

      with_password_field_for(:attribute)
      TM snippet: [wpff + tab]

      with_checkbox_for(:attribute)
      TM snippet: [wcf + tab]

      with_submit_button
      TM snippet: [wsb + tab]

      with_link_to(url_or_path, "optional_text")
      TM snippet: [wlt + tab]

Usage:
------

In your view spec:

    it "should render new form" do
        render "/users/new.html.erb"

        response.should have_form_posting_to(users_path) do
          with_text_field_for(:user_name)
          with_text_area_for(:user_address)
          with_text_field_for(:user_login)
          with_text_field_for(:user_email)
          with_submit_button
        end
    end

In your model spec:

    describe User do
      before(:each) do
        @user = User.new
      end

      it "should have many posts" do
        @user.should have_many(:posts)
      end

      it "should belong to a group" do
        @user.should belong_to(:group)
      end

      it do
        @user.should validate_presence_of(:email)
      end

      it do
        @user.should validate_uniqueness_of(:email)
      end

      it do
        @user.should validate_uniqueness_of(:login)
      end

      it do
        @user.should validate_presence_of(:login)
      end

      it do
        @user.should validate_presence_of(:name)
      end

      it do
        @user.should validate_length_of(:password, :between => 4..40)
      end

      it do
        @user.should validate_confirmation_of(:password)
      end

    end

Core Contributors
-----------------

  * Josh Knowles <joshknowles@gmail.com>
  * Bryan Helmkamp <bryan@brynary.com>
  * Matt Aimonetti <mattaimonetti@gmail.com>

Contributors
-------------

  * ckknight
  * Matt Pelletier
  * Luke Melia

Copyright (c) 2008 The Plugin Development Team, released under the MIT license