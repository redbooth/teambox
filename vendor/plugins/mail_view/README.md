MailView -- Visual email testing
================================

Preview plain text and html mail templates in your browser without redelivering it every time you make a change.

Usage
-----

Since most emails do something interesting with database data, you'll need to write some scenarios to load messages with fake data. Its similar to writing mailer unit tests but you see a visual representation of the output instead.

    class Notifier < ActionMailer::Base
      def invitation(inviter, invitee)
        # ...
      end

      def welcome(user)
        # ...
      end

      class Preview < MailView
        # Pull data from existing fixtures
        def invitation
          account = Account.first
          inviter, invitee = account.users[0, 2]
          Notifier.invitation(inviter, invitee)
        end

        # Factory-like pattern
        def welcome
          user = User.create!
          mail = Notifier.welcome(user)
          user.destory
          mail
        end
      end
    end

Methods must return a [Mail][1] or [TMail][2] object. Using ActionMailer, call `Notifier.create_action_name(args)` to return a compatible TMail object. Now on ActionMailer 3.x, `Notifier.action_name(args)` will return a Mail object.

Routing
-------

A mini router middleware is bundled for Rails 2.x support.

    # config/environments/development.rb
    config.middleware.use MailView::Mapper, Notifier::Preview

For Rails³ you can map the app inline in your routes config.

    # config/routes.rb
    if Rails.env.development?
      mount Notifier::Preview => 'mail_view'
    end

Now just load up `http://localhost:3000/mail_view`.

Interface
---------

![Plain text view](http://img18.imageshack.us/img18/1066/plaintext.png)
![HTML view](http://img269.imageshack.us/img269/2944/htmlz.png)


[1]: http://github.com/mikel/mail
[2]: http://github.com/mikel/tmail
