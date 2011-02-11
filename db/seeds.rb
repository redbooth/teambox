puts <<-EOS
This will create some example users and a pre-populated project for development.
EOS

SEED_OPTS = {
  :organizations => 50,
  :projects => 5,
  :users => 20,
  :external_users => 10,
  :activities => 80,
  :time_step => 2.minutes
}

class Project
  attr_accessor :last_task
  attr_accessor :made_task_comment
  
  def make_task_list(user, name, opts={})
    task_lists.build_by_user(user, opts) do |task_list|
      task_list.project = self
      task_list.created_at = fake_time
      task_list.name = name
      task_list.save!
    end
  end

  def make_task(user, name)
    tasks.build_by_user(user, :name => name) do |task|
      task.project = self
      task.task_list = task_lists.first
      task.created_at = fake_time
      task.save!
      @last_task = task
      @made_task_comment = false
    end
  end

  def make_comment(user, body, target=nil, status=nil, assigned=nil)
    comments.build_by_user(user, :body => body) do |comment|
    comment.project = self
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
    conversation = conversations.build_by_user(user, :name => name) do |c|
      c.project = self
      c.body = body
      c.created_at = fake_time
      c.simple = name.nil?
      c.project = self
      c.save!
    end
    
    # Need to fix first comment time
    conversation.comments.first.update_attribute :created_at, conversation.created_at
    Activity.last.update_attribute :created_at, conversation.created_at
  end

  def reply(user, body, target=nil)
    make_comment(user, body, target || conversations.first)
  end

  def status_update(user, body, params={}, comment_params={})
    task = last_task 
    
    # Grab 
    if params.has_key? :assigned_user
      params[:assigned_id] = people.find_by_user_id(params.delete(:assigned_user).id).id
    end
    params[:status] = Task::STATUSES[params[:status]] if params[:status].is_a? Symbol
    params[:status] ||= 1
    comment_params[:body] = body
    
    task.updating_user = user
    task.updating_date = fake_time
    task.update_attributes(params.merge(:comments_attributes => {"0" => comment_params}))
    @made_task_comment = true
    @last_task = Task.find_by_id(task.id) # i.e. reset *_changed?
    task
  end

  def make_page(user, name, description)
    time = fake_time
    pages.build_by_user(user, :name => name, :description => description) do |p|
      p.project = self
      p.created_at = time
      p.save!
    end
  end

  def make_note(user, name, body)
    time = fake_time
    notes.build_by_user(user, :name => name, :body => body) do |note|
      note.updated_by = user # if this is left undefined, note fails. note should validate updated_by
      note.project = self
      note.created_at = time
      note.page = pages.first(:order => 'id DESC')
      note.save!
    end
  end
  
  def make_divider(user, name)
    time = fake_time
    dividers.build_by_user(user, :name => name) do |divider|
      divider.updated_by = user
      divider.project = self
      divider.created_at = time
      divider.page = pages.first(:order => 'id DESC')
      divider.save!
    end
  end

  def add_users(users)
    users.each { |u| add_user(u) }
    activities[0,users.size].reverse.each { |a| a.update_attribute(:created_at, fake_time) }
  end
end

class Object
  def fake_time
    @fake_time ||= 150.minutes.ago
    @fake_time += SEED_OPTS[:time_step]
  end
end

def seed_data
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
  frank.update_attribute :admin, true

  home_page = %(<h1>Our design firm</h1>
                <p>This is an example site. You can log in as <b>frank</b>, <b>corrina</b>, <b>webdevtom</b>, <b>maya</b> or <b>marco</b>. The password is always <b>papapa</b>.</p>
                <p>Once you configure this site this screen will be deleted.</p>
                <h2>Quicklinks for testing:</h2>)

  users.each do |user|
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
  earthworks.status_update(tomas, "@maya Please register all top level domains surrounding EarthworksYoga. (.com, .net, .info, .us) and create redirect links to the .com URL.", {:due_on => (fake_time + 1.day), :assigned_user => maya})
  earthworks.status_update(maya, "I registered EarthworksYoga.com, EarthworksYoga.net, EarthworksYoga.info and EarthworksYoga.us. You can re-open the task if you’d like me to register the .org.", {:status => :resolved})

  earthworks.make_task(frank, "Set up AdWords campaign")
  earthworks.status_update(frank, "Go to http://adwords.google.com and set up AdWords for Earthworks. Contact @marco for any financial info you may need.")
  earthworks.status_update(frank, "Let me know if you need anything from me, Maya.")

  earthworks.make_task_list(frank, "Design")
  earthworks.make_task(corrina, "Create Flash banners")
  earthworks.status_update(corrina, "Based on the Earthworks Yoga logo assets I uploaded to files, create 3 Flash banners in the Skyscraper sizes as determined by the IAB guidelines (http://bit.ly/6cWKxh).", {:assigned_user => maya})
  earthworks.status_update(maya, "My Flash isn’t the greatest. I’ve done a rough job of something decent and uploaded it to Files. What do you think?")
  earthworks.status_update(corrina, "Hmm. Those are pretty rough, but I can make ‘em pretty. Come over around 3pm if you wanna look over my shoulder. I’ll put this task on Hold for now.", { :status => :hold})

  earthworks.make_page(frank, "Site content", "This new Page was created for @marco to contribute his site content. He'll be supplying us with Home, About Us, Classes, Join Now, and Contact Us.")
  earthworks.make_note(marco, "Home", "Earthworks Yoga is a magical place where time stops and renewal begins. Marco promotes a comprehensive approach to wellness with hands-on bodywork, Yoga and Meditation, Yoga Heal-a-Thons, and high-tech energy medicine tools that detoxify and strengthen the body.\n\nEarthworks Yoga provides sacred space and support for transformation on all levels, fostering connection with the Highest Self and the Soul’s true purpose in this life. Living in harmony calls for clearing the physical and subtle bodies of all trauma which cuts off the flow of life force. The True Self emerges as lifelong patterns of fear, pain, and self-limitation dissolve.")
  earthworks.make_note(marco, "About Us", "Marco opened Earthworks Yoga 20 years ago, with a passion and commitment to support healing within the yoga community. Calming the brain and nervous system directly influences the yogic energy channels, and creates an environment where wellness and wholeness can thrive. Marco’s methods are firmly rooted in both physical and esoteric anatomy. Nationally Certified in bodywork, she trained extensively in structural massage for chronic pain before discovering CranioSacral, SomatoEmotional, and Heart Centered Therapies. Earthworks Yoga’s healing evolution parallels the yogic journey … from the outer body to the inner fibers, cells, and soul. The root causes of suffering reveal themselves through chronic holding patterns in the physical and subtle bodies, and it is on all these levels that Marco works.")
  earthworks.make_note(marco, "Classes", "9:15-10:35 AM Hatha Duane 12\n12:30-1:30 PM Level 1-2  Laura M 12\n4:30-5:50 PM  Gentle Flow Mary  6\n6:05-7:25 PM  Flow 2  Tyler  12\n6:05-7:25 PM  Yoga BasicsLaura M 12")
  earthworks.make_note(marco, "Join Now", "- Unlimited access for just 33 cents a day\n- Less than one DVD or studio class\n- Experience our growing library of videos\n- On demand anytime, anywhere\n- Billing recurs monthly, cancel anytime\n- No contract, no obligation")
  earthworks.make_note(marco, "Contact Us", "The answers to most questions will be found in the FAQ page. A lot of the information will be found in the different pages of this site.\n\nFor comments and suggestions regarding this web site, please e-mail Webmaster@earthworksyoga.com\n\nFor schedule and other local information, please contact Marco [link to email].")

  earthworks.make_task(frank, "Collect collateral for online marketing design")
  earthworks.status_update(frank, "The online marketing collateral should include ads in all the common online sizes as determined by the IAB guidelines (http://bit.ly/6cWKxh). Let me know if you have any questions.", {:assigned_user => corrina})
  earthworks.status_update(corrina, "It's done!", {:assigned_user => frank})
  earthworks.status_update(frank, "Please install and configure the WordPress plugin called “All in One SEO Pack”.", {:assigned_user => tomas})

  earthworks.make_page(frank, "Staff bios", " I know it's cheesy to do these 3rd-person things, but it's the norm and it would be goof for our clients to know JUST HOW COOL WE ARE!")
  earthworks.make_note(tomas, "Tom's bio", "Tomas has been building websites since 1991, when he and Al Gore invented the internet together. Since then, he’s been involved with the development of websites and microsites for such conglomerates as Nike, the North Face, Cabela’s, Visa, and Toys’R’Us. In his free time, Tomas enjoys the music of the Kinks and the beers of Brooklyn Brewery.")

  earthworks.make_task(corrina, "Earthworks images for site")
  earthworks.status_update(corrina, "Please upload images to the Files tab here. Images should include those of the Earthworks Yoga studio and any other images you want incorporated into site design. Thanks!", {:due_on => (fake_time + 1.day), :assigned_user => marco})
  earthworks.status_update(marco, "My photographer’s coming next Monday. I should have you these by Thursday.")
  earthworks.status_update(marco, "I uploaded the images to the Teambox Files tab on Thursday. Let me know if/when you’ve reviewed them and how they look.", { :due_on => (fake_time + 3.day), :assigned_user => corrina})

  earthworks.make_task(frank, "Contact area businesses for banner exchange")
  earthworks.status_update(frank, "Please contact Green Earth Cafe, Nellie’s Tacos, Fenton’s, ROOZ, and Cato’s about a banner exchange with EarthworksYoga.com. Verbiage for your email can be found here in Teambox on the Pages tab.", {:due_on => (fake_time + 1.day), :assigned_user => maya})

  earthworks.make_note(corrina, "Corrina's bio", "Corrina is a self-proclaimed design dork. After finishing cum laude from RISD in 2000, she went on to get a MFA at the Tisch School in New york City. Aside from her graphic design work , Corrina teaches two classes at the California College of Arts and Crafts in Oakland, California. Corrina loves Oakland and lives with her two cats. When she’s not at her desk in Photoshop, she’s running around Lake Merritt and enjoying yoga classes at Earthworks Yoga.")

  earthworks.make_conversation(corrina, nil, "I found a yoga website that I really love. It’s a dumb name for a studio, but the website design is flawless: Let’s Get Bent: http://bit.ly/8p0gmf")

  puts <<-EOS
Things that should be added to seed data:
  - Bio and cards
  - Add dates to some tasks and task lists for Gantt charts and Calendar testing
  - Upload files inside and outside comments
  - Build another project to test overview for all tasks
  - The last comment by Corrina doesn't have a reply field

You can now log in as "frank" or others with the password "papapa"
EOS
end

def seed_random_demo_data(opts={})
  require 'faker'
  I18n.reload!
  num_organizations = opts[:organizations]
  generated_users = []
  generated_projects = []
  project_roles = [:commenter, :participant, :admin]
  organization_roles = [:participant, :admin]
  status_values_undue = [:hold, :resolved, :rejected]
  
  user_login_match = /[^0-9A-Za-z0-9_]/
  
  organizations = num_organizations.times.map do
    num_users = opts[:users]
    
    users = (0...num_users).map do
      user = User.create(:login => Faker::Internet.user_name.gsub(user_login_match, '_'),
                   :password => 'papapa',
                   :password_confirmation => 'papapa',
                   :first_name => Faker::Name.first_name, :last_name => Faker::Name.last_name,
                   :betatester => true,
                   :notify_conversations => false,
                   :notify_tasks => false,
                   :email => Faker::Internet.email)
      if user.save
        user.activate!
        puts "User: #{user.login}"
        user
      else
        nil
      end
    end.compact
    
    generated_users += users
    org_name = Faker::Company.name
    home_page = %(<h1>#{org_name}</h1>
                  <p>This is an example site. You can log in as any user. The password is always <b>papapa</b>.</p>
                  <h2>Quicklinks for testing:</h2>)
    organization = Organization.create!(:name => org_name, :description => home_page)
    puts "Organization: #{organization.permalink}"
    
    users.each do |user|
      home_page += %(
        <form style="display:inline" method="post" action="/session?login=#{user.login}&amp;password=papapa" class="button-to">
          <input type="submit" value="Login as #{user.first_name}">
        </form>
          )
    end
    
    organization.add_member(users.first,   :admin)
    users[1..-1].each do |user|
      organization.add_member(user, organization_roles.sample)
    end
    
    organization
  end
  
  organizations.each do |organization|
    num_projects = opts[:projects]
    admin = organization.users.order('id ASC').first
    projects = num_projects.times.map do
      num_external_users = opts[:external_users]
      project = admin.projects.new(:name => Faker::Company.catch_phrase,
                                   :public => rand(100)>=80).tap do |p| 
        p.organization = organization
        p.save!
      end
      
      puts "Project: #{project.permalink}"

      project.add_users organization.users
      num_external_users.times do
        project.add_user(generated_users.sample, :role => project_roles.sample)
      end
      
      project
    end
    
    generated_projects += projects
  end
  
  puts 'Simulating activity...'
  num_activities = opts[:activities]
  
  (num_activities*generated_projects.count).times do
    project = generated_projects.sample
    types = [:conversation, :task_list, :page]
    
    types << :task if project.task_lists.count > 0
    types << :reply if project.conversations.count > 0
    types << :status if project.last_task
    if project.pages.count > 0
      types << :note
      types << :divider
    end
    
    type = types.sample
    user = project.users.sample
    
    case type
    when :conversation
      if rand(100)>80
        project.make_conversation(user, Faker::Company.bs.capitalize, Faker::Lorem.paragraph)
      else
        project.make_conversation(user, nil, Faker::Lorem.paragraph)
      end
    when :task
      # Either makes a new task or randomly closes the old task
      if project.last_task
        if rand(100)>30
          project.status_update(user, Faker::Lorem.paragraph, {:status => Task::STATUSES[status_values_undue.sample]})
        else
          project.last_task = nil
        end
      end
      
      if project.last_task
        project.last_task = nil
        project.made_task_comment = false
      else
        project.last_task = project.make_task(user, Faker::Company.bs.capitalize)
        project.made_task_comment = false
      end
    when :task_list
      # Task list, start_on and finish_on are set randomly to test the calendar view
      list_opts = {}
      if rand(100)>40
        list_opts[:start_on] = fake_time+(rand(64).days)
        list_opts[:finish_on] = list_opts[:start_on] + rand(64).days
      end
      project.make_task_list(user, Faker::Company.bs.capitalize, list_opts)
    when :status
      # Makes a new task comment, randomly setting due_on and assigned.
      # status will randomly switch to hold unless due_on is set
      stat_opts = {}
      project.last_task.reload
      stat_opts[:due_on] = project.last_task.due_on
      stat_opts[:assigned_id] = project.last_task.assigned_id
      if rand(100)>50
        stat_opts[:due_on] = fake_time+(rand(64).days) if rand(100)>80
        stat_opts[:assigned_id] = project.people.sample.id if stat_opts[:due_on] or rand(100)>80
        
        unless project.made_task_comment
          if stat_opts.has_key?(:due_on)
            stat_opts[:status] = Task::STATUSES[:open] unless project.last_task.status_name == :open
          elsif rand(100)>80
            stat_opts[:status] = Task::STATUSES[:hold]
          else
            stat_opts[:status] = Task::STATUSES[:open] unless project.last_task.status_name == :open
          end
        end
      end
      project.status_update(user, Faker::Lorem.paragraph, stat_opts)
      project.made_task_comment = true
    when :reply
      project.reply(user, Faker::Lorem.paragraph)
    when :page
      project.make_page(user, Faker::Lorem.words.join(' ').capitalize, Faker::Lorem.paragraph)
    when :note
      project.make_note(user, Faker::Lorem.words.join(' ').capitalize, Faker::Lorem.paragraphs.join("\n"))
    when :divider
      project.make_divider(user, Faker::Lorem.words.join(' ').capitalize)
    end
    
    print '.'
  end
  
  puts "\nDone."
  puts "#{Activity.count} pointless activities generated in #{Project.count} projects in #{Organization.count} organizations totalling #{User.count} users."
end

if ENV['BOXSEED_RANDOM']
  SEED_OPTS[:time_step] = 1.minutes
  seed_random_demo_data(SEED_OPTS)
else
  seed_data
end

