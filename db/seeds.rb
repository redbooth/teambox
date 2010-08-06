puts <<-EOS
This will create some example users and a pre-populated project for development.
Log in as "frank_pm" with the password "papap"

Things that should be added to seed data:
  - Bio and cards
  - Add dates to some tasks and task lists for Gantt charts and Calendar testing
  - Fix status changes for comments
      Assigning tasks doesn't work status_update(tomas, "message", :status), status_update(tomas, "asdas", users)
      Apparently, the comment is saving but it's not affecting the target.
  - Upload files inside and outside comments
  - Build another project to test overview for all tasks
  - The last comment by Corrina doesn't have a reply field
EOS

class Object # I'd love to make this class SeedProject < Project, but that doesn't work
  def make_task_list(user, name)
    task_lists.new.tap do |task_list|
      task_list.user = user
      task_list.name = name
      task_list.save!
    end
    activities.reload.first.update_attribute(:created_at, fake_time)
  end

  def make_task(user, name)
    task_lists.first.tasks.new(:name => name) do |task|
      task.project = self
      task.user = user
      task.created_at = fake_time
      task.save!
    end
  end

  def make_comment(user, body, target=nil, status=nil, assigned=nil)
    comments.new(:user_id => user.id, :body => body).tap do |comment|
      comment.target = target
      if assigned && status
        comment.status = status
        comment.assigned_id = assigned
      end
      comment.created_at = fake_time
      comment.save!
    end
  end

  def make_conversation(user, name, body, target=nil)
    conversations.new(:name => name).tap do |conversation|
      conversation.user = user
      conversation.body = body
      conversation.created_at = fake_time
      conversation.save!
      conversation.comments.first.update_attribute(:created_at, fake_time)
    end
  end

  def reply(user, body, target=nil)
    make_comment(user, body, target || Conversation.last)
  end

  def status_update(user, body, assigned=nil, target=nil)
    case assigned
    when User
      status = Task::STATUSES[:open]
      person = Person.find(:first, :conditions => { :user_id => assigned.id, :project_id => self.id })
      make_comment(user, body, target || Task.last, status, person)
    when Symbol
      status = Task::STATUSES[assigned]
      make_comment(user, body, target || Task.last, status)
    else
      make_comment(user, body, target || Task.last)
    end
  end

  def make_page(user, name, description)
    pages.new(:name => name, :description => description).tap do |p|
      p.user = user
      p.created_at = fake_time
      p.save!
    end
  end

  def make_note(user, name, body)
    pages.first.notes.new(:name => name, :body => body) do |note|
      note.user = user
      note.updated_by = user # if this is left undefined, note fails. note should validate updated_by
      note.project_id = self.id # this should not be needed, since notes should know who they belong to
      note.created_at = fake_time
      note.save!
    end
  end

  def add_users(users)
    users.each { |u| add_user(u) }
    activities[0,users.size].reverse.each { |a| a.update_attribute(:created_at, fake_time) }
  end
  
  def fake_time
    @fake_time ||= 120.minutes.ago
    @fake_time += 2.minute
  end
end

@users = [%w(Frank Kramer frank_pm),
          %w(Corrina Kottke corrina),
          %w(Tomas Santiago webdevtom),
          %w(Maya Bhaskaran maya_pa),
          %w(Marco Fizzulo donmarco)].collect do |a,b,u|
  @user = User.create!(:login => u,
                      :password => "papapa",
                      :password_confirmation => "papapa",
                      :first_name => a, :last_name => b,
                      :email => "example_#{a}@teambox.com")
  @user.activate!
  @user
end

frank, corrina, tomas, maya, marco = @users

earthworks = frank.projects.new(:name => "Earthworks Yoga", :permalink => "earthworks", :public => true).tap { |p| p.save! }

earthworks.make_comment(frank, "Getting started. Sending invites for project.")
earthworks.add_users [corrina, tomas, maya, marco]

earthworks.make_comment(marco, "Thanks for inviting me to the process, guys. This is pretty cool.")
earthworks.reply(corrina, "Hey guys. Glad to be helping out on this site. I LOVE Earthworks! Working on color palettes and font ideas now.")

earthworks.make_conversation(frank, "Project Welcome", "Hey guys. I’m looking forward to working with you all again. I’m also please to be working with my friend and yoga instructor Marco Fizzulo. This should be straightforward project and I can’t wait to see what we put together.")
earthworks.reply(marco, "Glad we have the ball rolling, @frank_pm! Looking forward to seeing the site.")

earthworks.make_conversation(corrina, "Design websites you like", "I know you guys specialize in your own things, but also know that you all have great design eyes! So I thought i’d ask—are there any sites that you’d recommend for design inspiration? Thanks.")
earthworks.reply(marco,   "Is the client allowed to answer?")
earthworks.reply(corrina, "Of course, Marco! You’re part of the team!!")
earthworks.reply(marco,   "I like [Design Observer](http://www.designobserver.com/) and [Dexigner](http://www.dexigner.com/).")
earthworks.reply(frank,   "Those are good ones, @donmarco. I look at [Smashing Magazine’s blog](http://www.smashingmagazine.com/) a lot and for fonts, I like one called [I Love Typography](http://ilovetypography.com/)")

earthworks.make_conversation(tomas, "Links to other nice yoga websites", "I was checking out some other yoga websites and found some nice ones. Here’s a couple:\nOaklandish Yoga: http://bit.ly/8ITnDi\nBikram SF: http://bit.ly/7WAhJj")
earthworks.reply(corrina, "I found a yoga website that I really love. It’s a dumb name for a studio, but the website design is flawless: Let’s Get Bent: http://bit.ly/8p0gmf")

earthworks.make_conversation(frank, "How about a team lunch?", "I think it would be fun AND productive if we could all meet for lunch one day a week. Can we all throw out a couple days/times that might work best? I know you’re all really busy and chances are we won’t all make if every week, but it would be great to at least have a slot on the calendar. Sure, we’re all busy, but we GOTTA EAT, right? Hope we can figure something out. As far as my schedule goes, i’m really flexible. Any day/time works for me.")
earthworks.reply(maya,    "I can do Tuesday, Thursday, and Friday. Any time works. Thanks.")
earthworks.reply(corrina, "Thursdays are good for me!")
earthworks.reply(maya,    "If Thursday works for Tomas, I think that will work. Tomas?")

earthworks.make_conversation(tomas, "Seth Godin's 'What matters now'", "Have you guys read this:\nhttp://sethgodin.typepad.com/seths_blog/2009/12/what-matters-now-get-the-free-ebook.html\nI highly recommend. Please let me know what you think.")
earthworks.reply(corrina, "Thanks for sending, Frank. That’s an impressive roster Godin put together! I especially liked the graphical stuff like cartoonist Hugh MacLeod’s *Ignore Everybody*. If you guys don’t know MacLeod’s blog, it’s worth checking out:\nGaping Void: http://gapingvoid.com")
earthworks.reply(tomas,   "I loved What Matters Now. Thanks for the link. I appreciate how the “chapters” were bite-size morsels. Perfect for my A.D.D. ass! lol. I’m a big proponent of the “less-is-more” maxim, which is why I particularly enjoyed Merlin Mann’s essay about over-doing it.")
earthworks.reply(maya,    "I was happy to see that Karen Armstrong was invited to contribute to Godin’s collection. After I saw Armstrong on a http://ted.com video recently talking about her work, I read A History of God, her 1993 book. Broad subject, but a great read that I’d recommend:\nhttp://en.wikipedia.org/wiki/A_History_of_God")
earthworks.reply(frank,   "Glad you all enjoyed What Matters Now! Godin is awesome. Please consider reading “The Big Red Fez: How To Make Any Web Site Better”. I’d be happy to buy you all a copy; just send me your receipt and I’ll reimburse you. Here’s the Amazon link: http://bit.ly/7tVT1x")
earthworks.reply(tomas,   "Thanks, Frank. I’ve read a couple of Godin’s other books, but I guess I missed The Big Red Fez. Looking forward to checking it out asap. And thanks for the MacLeod link, Corrina. Funny guy!")

earthworks.make_task_list(tomas, "Site Setup")
earthworks.make_task(tomas, "Register all EarthworksYoga TLDs")
earthworks.status_update(tomas, "@maya_pa Please register all top level domains surrounding EarthworksYoga. (.com, .net, .info, .us) and create redirect links to the .com URL.", maya)
earthworks.status_update(maya, "I registered EarthworksYoga.com, EarthworksYoga.net, EarthworksYoga.info and EarthworksYoga.us. You can re-open the task if you’d like me to register the .org.", :resolved)

earthworks.make_task(frank, "Set up AdWords campaign")
earthworks.status_update(frank, "Go to http://adwords.google.com to set up AdWords for Earthworks. Contact @donmarco for any financial info you may need.", maya)
earthworks.status_update(frank, "Let me know if you need anything from me, Maya.")

earthworks.make_task_list(frank, "Design")
earthworks.make_task(frank, "Collect collateral for online marketing design")
earthworks.status_update(frank, "The online marketing collateral should include ads in all the common online sizes as determined by the IAB guidelines (http://bit.ly/6cWKxh). Let me know if you have any questions.", corrina)
earthworks.status_update(corrina, "It's done!", frank)
earthworks.status_update(frank, "Please install and configure the WordPress plugin called “All in One SEO Pack”.", tomas)

earthworks.make_task(corrina, "Create Flash banners")
earthworks.status_update(corrina, "Based on the Earthworks Yoga logo assets I uploaded to files, create 3 Flash banners in the Skyscraper sizes as determined by the IAB guidelines (http://bit.ly/6cWKxh).", maya)
earthworks.status_update(maya, "My Flash isn’t the greatest. I’ve done a rough job of something decent and uploaded it to Files. What do you think?")
earthworks.status_update(corrina, "Hmm. Those are pretty rough, but I can make ‘em pretty. Come over around 3pm if you wanna look over my shoulder. I’ll put this task on Hold for now.", :hold)

earthworks.make_task(corrina, "Earthworks images for site")
earthworks.status_update(corrina, "Please upload images to the Files tab here. Images should include those of the Earthworks Yoga studio and any other images you want incorporated into site design. Thanks!", marco)
earthworks.status_update(marco, "My photographer’s coming next Monday. I should have you these by Thursday.")
earthworks.status_update(marco, "I uploaded the images to the Teambox Files tab on Thursday. Let me know if/when you’ve reviewed them and how they look.", corrina)

earthworks.make_task(frank, "Contact area businesses for banner exchange")
earthworks.status_update(frank, "Please contact Green Earth Cafe, Nellie’s Tacos, Fenton’s, ROOZ, and Cato’s about a banner exchange with EarthworksYoga.com. Verbiage for your email can be found here in Teambox on the Pages tab.", maya)

earthworks.make_page(frank, "Site content", "This new Page was created for @DonMarco to contribute his site content. He'll be supplying us with Home, About Us, Classes, Join Now, and Contact Us.")
earthworks.make_note(marco, "Home", "Earthworks Yoga is a magical place where time stops and renewal begins. Marco promotes a comprehensive approach to wellness with hands-on bodywork, Yoga and Meditation, Yoga Heal-a-Thons, and high-tech energy medicine tools that detoxify and strengthen the body.\n\nEarthworks Yoga provides sacred space and support for transformation on all levels, fostering connection with the Highest Self and the Soul’s true purpose in this life. Living in harmony calls for clearing the physical and subtle bodies of all trauma which cuts off the flow of life force. The True Self emerges as lifelong patterns of fear, pain, and self-limitation dissolve.")
earthworks.make_note(marco, "About Us", "Marco opened Earthworks Yoga 20 years ago, with a passion and commitment to support healing within the yoga community. Calming the brain and nervous system directly influences the yogic energy channels, and creates an environment where wellness and wholeness can thrive. Marco’s methods are firmly rooted in both physical and esoteric anatomy. Nationally Certified in bodywork, she trained extensively in structural massage for chronic pain before discovering CranioSacral, SomatoEmotional, and Heart Centered Therapies. Earthworks Yoga’s healing evolution parallels the yogic journey … from the outer body to the inner fibers, cells, and soul. The root causes of suffering reveal themselves through chronic holding patterns in the physical and subtle bodies, and it is on all these levels that Marco works.")
earthworks.make_note(marco, "Classes", "9:15-10:35 AM Hatha Duane 12\n12:30-1:30 PM Level 1-2  Laura M 12\n4:30-5:50 PM  Gentle Flow Mary  6\n6:05-7:25 PM  Flow 2  Tyler  12\n6:05-7:25 PM  Yoga BasicsLaura M 12")
earthworks.make_note(marco, "Join Now", "- Unlimited access for just 33 cents a day\n- Less than one DVD or studio class\n- Experience our growing library of videos\n- On demand anytime, anywhere\n- Billing recurs monthly, cancel anytime\n- No contract, no obligation")
earthworks.make_note(marco, "Contact Us", "The answers to most questions will be found in the FAQ page. A lot of the information will be found in the different pages of this site.\n\nFor comments and suggestions regarding this web site, please e-mail Webmaster@earthworksyoga.com\n\nFor schedule and other local information, please contact Marco [link to email].")

earthworks.make_page(frank, "Staff bios", " I know it's cheesy to do these 3rd-person things, but it's the norm and it would be goof for our clients to know JUST HOW COOL WE ARE!")
earthworks.make_note(tomas, "Tom's bio", "Tomas has been building websites since 1991, when he and Al Gore invented the internet together. Since then, he’s been involved with the development of websites and microsites for such conglomerates as Nike, the North Face, Cabela’s, Visa, and Toys’R’Us. In his free time, Tomas enjoys the music of the Kinks and the beers of Brooklyn Brewery.")
earthworks.make_note(corrina, "Corrina's bio", "Corrina is a self-proclaimed design dork. After finishing cum laude from RISD in 2000, she went on to get a MFA at the Tisch School in New york City. Aside from her graphic design work , Corrina teaches two classes at the California College of Arts and Crafts in Oakland, California. Corrina loves Oakland and lives with her two cats. When she’s not at her desk in Photoshop, she’s running around Lake Merritt and enjoying yoga classes at Earthworks Yoga.")

earthworks.make_comment(corrina, "I found a yoga website that I really love. It’s a dumb name for a studio, but the website design is flawless: Let’s Get Bent: http://bit.ly/8p0gmf")
