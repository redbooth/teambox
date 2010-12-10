puts <<-EOS
This will create some example users and a pre-populated project for development.

Things that should be added to seed data:
  - Bio and cards
  - Add dates to some tasks and task lists for Gantt charts and Calendar testing
  - Fix status changes for comments
      Assigning tasks doesn't work status_update(tomas, "message", :status), status_update(tomas, "asdas", users)
      Apparently, the comment is saving but it's not affecting the target.
  - Upload files inside and outside comments
  - Build another project to test overview for all tasks
  - The last comment by Corrina doesn't have a reply field

You can now log in as "frank" or others with the password "papapa"

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
    comments.new_by_user (user, :body => body).tap do |comment|
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
      conversation.simple = name.nil?
      conversation.save!
      conversation.comments.first.update_attribute(:created_at, fake_time)
    end
  end

  def reply(user, body, target=nil)
    make_comment(user, body, target || Conversation.last)
  end

  def status_update(user, body, params={})
    task = Task.last(:order => :id)

    comment = task.comments.new
    comment.user = user
    comment.body = body
    comment.created_at = fake_time

    if assigned = params[:assigned]
      task.status = Task::STATUSES[:open]
      comment.previous_assigned_id = task.assigned_id
      task.assign_to(user)
      comment.assigned_id = task.assigned_id
    end

    if status = params[:status]
      task.status = Task::STATUSES[status]
      comment.previous_status = task.status
      task.status = Task::STATUSES[status]
      comment.status = Task::STATUSES[status]
    end

    if due_on = params[:due_on]
      comment.previous_due_on = task.due_on
      task.due_on = due_on
      comment.due_on = due_on
    end

    task.save
    comment.save
  end

  def make_page(user, name, description)
    time = fake_time
    pages.new(:name => name, :description => description).tap do |p|
      p.user = user
      p.created_at = time
      p.save!
    end
    Activity.last.update_attribute :created_at, time
  end

  def make_note(user, name, body)
    time = fake_time
    pages.first.notes.new(:name => name, :body => body) do |note|
      note.user = user
      note.updated_by = user # if this is left undefined, note fails. note should validate updated_by
      note.project_id = self.id # this should not be needed, since notes should know who they belong to
      note.created_at = time
      note.save!
    end
    Activity.last.update_attribute :created_at, time
  end

  def add_users(users)
    users.each { |u| add_user(u) }
    activities[0,users.size].reverse.each { |a| a.update_attribute(:created_at, fake_time) }
  end
  
  def fake_time
    @fake_time ||= 150.minutes.ago
    @fake_time += 2.minutes
  end
end

users = [%w(Frank Kramer frank),
          %w(Corrina Kottke corrina),
          %w(Tomas Santiago webdevtom),
          %w(Maya Bhaskaran maya),
          %w(Marco Fizzulo marco)].collect do |a,b,u|
  user = User.find_by_login(u) || User.create!(:login => u,
                      :password => "papapa",
                      :password_confirmation => "papapa",
                      :first_name => a, :last_name => b,
                      :betatester => true,
                      :notify_conversations => false,
                      :notify_tasks => false,
                      :email => "example_#{a}@teambox.com")
  user.activate!
  user
end

frank, corrina, tomas, maya, marco = users

home_page = %(<h1>Our design firm</h1>
              <p>This is an example site. You can log in as <b>frank</b>, <b>corrina</b>, <b>webdevtom</b>, <b>maya</b> or <b>marco</b>. The password is always <b>papapa</b>.</p>
              <p>Once you configure this site this screen will be deleted.</p>
              <h2>Quicklinks for testing:</h2>)

User.all.each do |user|
  home_page += %(
    <form style="display:inline" method="post" action="/session?login=#{user.login}&amp;password=papapa" class="button-to">
      <input type="submit" value="Login as #{user.first_name}">
    </form>
      )
end

organization = Organization.first
organization ||= Organization.create!(:name => "Design projects", :description => home_page)

organization.add_member(frank,   :admin)
organization.add_member(corrina, :admin)
organization.add_member(tomas,   :participant)
organization.add_member(maya,    :participant)
# marco is not part of the organization

earthworks = frank.projects.new(:name => "Earthworks Yoga",
                                :permalink => "earthworks",
                                :public => true).tap do |p| 
  p.organization = organization
  p.save!
end

earthworks.add_users [corrina, tomas, maya, marco]


earthworks.make_conversation(frank, "Project Welcome", "Hey guys. I’m looking forward to working with you all again. I’m also pleased to be working with my friend and yoga instructor Marco Fizzulo. This should be straightforward project and I can’t wait to see what we put together.")
earthworks.reply(corrina, "Hey guys. Glad to be helping out on this site. I LOVE Earthworks! Working on color palettes and font ideas now.")
earthworks.reply(marco, "Glad we have the ball rolling, @frank! Looking forward to seeing the site.")

earthworks.make_conversation(corrina, "Design websites you like", "I know you guys specialize in your own things, but also know that you all have great design eyes! So I thought I’d ask—are there any sites that you’d recommend for design inspiration? Thanks.")
earthworks.reply(marco,   "Is the client allowed to answer?")
earthworks.reply(corrina, "Of course, Marco! You’re part of the team!!")
earthworks.reply(marco,   "I like [Design Observer](http://www.designobserver.com/) and [Dexigner](http://www.dexigner.com/).")
earthworks.reply(frank,   "Those are good ones, @marco. I look at [Smashing Magazine’s blog](http://www.smashingmagazine.com/) a lot and for fonts, I like one called [I Love Typography](http://ilovetypography.com/)")

earthworks.make_conversation(tomas, "Links to other nice yoga websites", "I was checking out some other yoga websites and found some nice ones. Here’s a couple:\nOaklandish Yoga: http://bit.ly/8ITnDi\nBikram SF: http://bit.ly/7WAhJj")
earthworks.reply(corrina, "I found a yoga website that I really love. It’s a dumb name for a studio, but the website design is flawless: Let’s Get Bent: http://bit.ly/8p0gmf")

earthworks.make_conversation(frank, "How about a team lunch?", "I think it would be fun AND productive if we could all meet for lunch one day a week. Can we all throw out a couple days/times that might work best? I know you’re all really busy and chances are we won’t all make if every week, but it would be great to at least have a slot on the calendar. Sure, we’re all busy, but we GOTTA EAT, right? Hope we can figure something out. As far as my schedule goes, I’m really flexible. Any day/time works for me.")
earthworks.reply(maya,    "I can do Tuesday, Thursday, and Friday. Any time works. Thanks.")
earthworks.reply(corrina, "Thursdays are good for me!")
earthworks.reply(maya,    "If Thursday works for Tomas, I think that will work. Tomas?")

earthworks.make_conversation(tomas, "Seth Godin's 'What matters now'", "Have you guys read this:\nhttp://sethgodin.typepad.com/seths_blog/2009/12/what-matters-now-get-the-free-ebook.html\nI highly recommend. Please let me know what you think.")
earthworks.reply(corrina, "Thanks for sending, Frank. That’s an impressive roster Godin put together! I especially liked the graphical stuff like cartoonist Hugh MacLeod’s *Ignore Everybody*. If you guys don’t know MacLeod’s blog, it’s worth checking out:\nGaping Void: http://gapingvoid.com")
earthworks.reply(tomas,   "I loved What Matters Now. Thanks for the link. I appreciate how the “chapters” were bite-size morsels. Perfect for my A.D.D. ass! LOL. I’m a big proponent of the “less-is-more” maxim, which is why I particularly enjoyed Merlin Mann’s essay about over-doing it.")
earthworks.reply(maya,    "I was happy to see that Karen Armstrong was invited to contribute to Godin’s collection. After I saw Armstrong on a http://ted.com video recently talking about her work, I read A History of God, her 1993 book. Broad subject, but a great read that I’d recommend:\nhttp://en.wikipedia.org/wiki/A_History_of_God")
earthworks.reply(frank,   "Glad you all enjoyed What Matters Now! Godin is awesome. Please consider reading “The Big Red Fez: How To Make Any Web Site Better”. I’d be happy to buy you all a copy; just send me your receipt and I’ll reimburse you. Here’s the Amazon link: http://bit.ly/7tVT1x")
earthworks.reply(tomas,   "Thanks, Frank. I’ve read a couple of Godin’s other books, but I guess I missed The Big Red Fez. Looking forward to checking it out asap. And thanks for the MacLeod link, Corrina. Funny guy!")

earthworks.make_task_list(tomas, "Site Setup")
earthworks.make_task(tomas, "Register all EarthworksYoga TLDs")
earthworks.status_update(tomas, "@maya Please register all top level domains surrounding EarthworksYoga. (.com, .net, .info, .us) and create redirect links to the .com URL.", {:due_on => (fake_time + 1.day), :assigned => maya})
earthworks.status_update(maya, "I registered EarthworksYoga.com, EarthworksYoga.net, EarthworksYoga.info and EarthworksYoga.us. You can re-open the task if you’d like me to register the .org.", {:status => :resolved})

earthworks.make_task(frank, "Set up AdWords campaign")
earthworks.status_update(frank, "Go to http://adwords.google.com and set up AdWords for Earthworks. Contact @marco for any financial info you may need.")
earthworks.status_update(frank, "Let me know if you need anything from me, Maya.")

earthworks.make_task_list(frank, "Design")
earthworks.make_task(corrina, "Create Flash banners")
earthworks.status_update(corrina, "Based on the Earthworks Yoga logo assets I uploaded to files, create 3 Flash banners in the Skyscraper sizes as determined by the IAB guidelines (http://bit.ly/6cWKxh).", {:assigned => maya})
earthworks.status_update(maya, "My Flash isn’t the greatest. I’ve done a rough job of something decent and uploaded it to Files. What do you think?")
earthworks.status_update(corrina, "Hmm. Those are pretty rough, but I can make ‘em pretty. Come over around 3pm if you wanna look over my shoulder. I’ll put this task on Hold for now.", { :status => :hold})

earthworks.make_page(frank, "Site content", "This new Page was created for @marco to contribute his site content. He'll be supplying us with Home, About Us, Classes, Join Now, and Contact Us.")
earthworks.make_note(marco, "Home", "Earthworks Yoga is a magical place where time stops and renewal begins. Marco promotes a comprehensive approach to wellness with hands-on bodywork, Yoga and Meditation, Yoga Heal-a-Thons, and high-tech energy medicine tools that detoxify and strengthen the body.\n\nEarthworks Yoga provides sacred space and support for transformation on all levels, fostering connection with the Highest Self and the Soul’s true purpose in this life. Living in harmony calls for clearing the physical and subtle bodies of all trauma which cuts off the flow of life force. The True Self emerges as lifelong patterns of fear, pain, and self-limitation dissolve.")
earthworks.make_note(marco, "About Us", "Marco opened Earthworks Yoga 20 years ago, with a passion and commitment to support healing within the yoga community. Calming the brain and nervous system directly influences the yogic energy channels, and creates an environment where wellness and wholeness can thrive. Marco’s methods are firmly rooted in both physical and esoteric anatomy. Nationally Certified in bodywork, she trained extensively in structural massage for chronic pain before discovering CranioSacral, SomatoEmotional, and Heart Centered Therapies. Earthworks Yoga’s healing evolution parallels the yogic journey … from the outer body to the inner fibers, cells, and soul. The root causes of suffering reveal themselves through chronic holding patterns in the physical and subtle bodies, and it is on all these levels that Marco works.")
earthworks.make_note(marco, "Classes", "9:15-10:35 AM Hatha Duane 12\n12:30-1:30 PM Level 1-2  Laura M 12\n4:30-5:50 PM  Gentle Flow Mary  6\n6:05-7:25 PM  Flow 2  Tyler  12\n6:05-7:25 PM  Yoga BasicsLaura M 12")
earthworks.make_note(marco, "Join Now", "- Unlimited access for just 33 cents a day\n- Less than one DVD or studio class\n- Experience our growing library of videos\n- On demand anytime, anywhere\n- Billing recurs monthly, cancel anytime\n- No contract, no obligation")
earthworks.make_note(marco, "Contact Us", "The answers to most questions will be found in the FAQ page. A lot of the information will be found in the different pages of this site.\n\nFor comments and suggestions regarding this web site, please e-mail Webmaster@earthworksyoga.com\n\nFor schedule and other local information, please contact Marco [link to email].")

earthworks.make_task(frank, "Collect collateral for online marketing design")
earthworks.status_update(frank, "The online marketing collateral should include ads in all the common online sizes as determined by the IAB guidelines (http://bit.ly/6cWKxh). Let me know if you have any questions.", {:assigned => corrina})
earthworks.status_update(corrina, "It's done!", {:assigned => frank})
earthworks.status_update(frank, "Please install and configure the WordPress plugin called “All in One SEO Pack”.", {:assigned => tomas})

earthworks.make_page(frank, "Staff bios", " I know it's cheesy to do these 3rd-person things, but it's the norm and it would be goof for our clients to know JUST HOW COOL WE ARE!")
earthworks.make_note(tomas, "Tom's bio", "Tomas has been building websites since 1991, when he and Al Gore invented the internet together. Since then, he’s been involved with the development of websites and microsites for such conglomerates as Nike, the North Face, Cabela’s, Visa, and Toys’R’Us. In his free time, Tomas enjoys the music of the Kinks and the beers of Brooklyn Brewery.")

earthworks.make_task(corrina, "Earthworks images for site")
earthworks.status_update(corrina, "Please upload images to the Files tab here. Images should include those of the Earthworks Yoga studio and any other images you want incorporated into site design. Thanks!", {:due_on => (fake_time + 1.day), :assigned => marco})
earthworks.status_update(marco, "My photographer’s coming next Monday. I should have you these by Thursday.")
earthworks.status_update(marco, "I uploaded the images to the Teambox Files tab on Thursday. Let me know if/when you’ve reviewed them and how they look.", { :due_on => (fake_time + 3.day), :assigned => corrina})

earthworks.make_task(frank, "Contact area businesses for banner exchange")
earthworks.status_update(frank, "Please contact Green Earth Cafe, Nellie’s Tacos, Fenton’s, ROOZ, and Cato’s about a banner exchange with EarthworksYoga.com. Verbiage for your email can be found here in Teambox on the Pages tab.", {:due_on => (fake_time + 1.day), :assigned => maya})

earthworks.make_note(corrina, "Corrina's bio", "Corrina is a self-proclaimed design dork. After finishing cum laude from RISD in 2000, she went on to get a MFA at the Tisch School in New york City. Aside from her graphic design work , Corrina teaches two classes at the California College of Arts and Crafts in Oakland, California. Corrina loves Oakland and lives with her two cats. When she’s not at her desk in Photoshop, she’s running around Lake Merritt and enjoying yoga classes at Earthworks Yoga.")

earthworks.make_conversation(corrina, nil, "I found a yoga website that I really love. It’s a dumb name for a studio, but the website design is flawless: Let’s Get Bent: http://bit.ly/8p0gmf")
