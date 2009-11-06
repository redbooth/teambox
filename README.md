Teambox Project Manager
================================

*THIS PROJECT IS IN AN EARLY PHASE AND ISN'T NOT READY FOR DEPLOYMENT*.
*THIS PROJECT IS IN AN EARLY PHASE AND ISN'T NOT READY FOR DEPLOYMENT*.
*THIS PROJECT IS IN AN EARLY PHASE AND ISN'T NOT READY FOR DEPLOYMENT*.

For any questions, contact us at pablo@teambox.com

Teambox is a project management software built on Ruby on Rails,
based in our previous project, Saiku.

Visit [Teambox website](http://www.teambox.com/ "Project Management")
for documentation, community and support: <http://www.teambox.com/>

Teambox: Project Management and Collaboration software
-------

- Website: <http://www.teambox.com/>
- GitHub: <http://github.com/michokest/Teambox-2>
- Lighthouse tickets: <http://teambox.lighthouseapp.com>
- Original developer: Pablo Villalba (pablo@teambox.com, michokest@gmail.com)
- Copyright: (cc) 2009 Teambox Desarrollos S.L.




GET ROLLING!
-------

Install missing gems:

rake gems:install

Create Your Database 

rake db:create

Run Migrations

rake db:auto:migrate

Configure models/emailer.rb and replace _app.teambox.com_ for your own domain name.
Configure config/environment.rb and replace _app.teambox.com_ for your own domain name.
Configure config/environment.rb and enter your email settings for smtp_settings.


Plugins were using you need to know about
-------

Auto Migrations

You won't see a-lot of migration files in this rails project because we're
using an awesome plugin called auto_migrations. Instead of creating migration
files you modify the schema file and the run a rake that figures out what it 
has to do. Its saves alot of time in development. Then when you're ready to
share you app for deployment there is a rake to convert your current schema
to a migration file. So you'll only have migration files for major revisions.

TODO (Version 2)

* when adding a user to a project it should list them but as pending, with the option to send an invitation again
* fixture data, so when were in development we can load up a project quickly

TODO (Version 2.1)
-------

* project drop down
* time tracking
* column filters
* file revision uploads
