Teambox Project Manager
================================

*A project management software built on Ruby on Rails with a focus on collaboration.*

Teambox is project-oriented. Each project is private and can only be accessed by its owner and collaborators.
Projects have a status wall, conversations, tasks, shared pages and file uploads.

You can [use Teambox online](http://www.teambox.com/ "Teambox") to understand how it works before installing.

Visit the product's site for documentation, community and support: <http://www.teambox.com/>

<a href="http://www.teambox.com"><img src="http://teambox.com/images/screenshots/overview.png" /></a>


Teambox: Project Management and Collaboration software
-------

- Website: <http://www.teambox.com/>
- GitHub: <http://github.com/micho/teambox>
- Mailing List for developers: <http://groups.google.com/group/teambox>
- Original developer: Pablo Villalba (pablo@teambox.com, michokest@gmail.com)
- Copyright: (cc) 2010 Teambox Technologies S.L.

<img src="http://blog.teambox.com/rails_features.jpg"/>

INSTALLATION GUIDES
-------

Take a looks at [our wiki](http://wiki.github.com/micho/teambox/ "Install Teambox") to learn how to install
Teambox on different platforms.


GET ROLLING!
-------

You can also [use Teambox online](http://www.teambox.com/ "Teambox"). If you've chosen to run your own copy,
then follow these simple steps!

Install missing gems:

- rake gems:install

Create Your Database 

- rake db:create

Run Migrations

- rake db:auto:migrate

Edit config files

- config/teambox.yml: replace the needed values for your own domain name.
- config/environment.rb: enter your email settings for smtp_settings.

Run the server with ./script/server and go to http://localhost to start using Teambox!


Plugins we use that you need to know about
-------

Auto Migrations

You won't see a-lot of migration files in this rails project because we're
using an awesome plugin called auto_migrations. Instead of creating migration
files you modify the schema file and the run a rake that figures out what it 
has to do. Its saves alot of time in development. Then when you're ready to
share you app for deployment there is a rake to convert your current schema
to a migration file. So you'll only have migration files for major revisions.
