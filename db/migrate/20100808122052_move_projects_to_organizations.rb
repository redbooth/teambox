class MoveProjectsToOrganizations < ActiveRecord::Migration
  def self.up
    description = if User.count > 0 # existing installation
      %(
        <h1>You just upgraded Teambox</h1>
        <p>We've added new features to this version, like better <b>user role management</b> and <b>first page customization</b></p>
        <p>To configure your installation, follow these steps:</p>
        <ol>
          <li>Log in normally.</li>
          <li>Go to your <a href='/organizations'>organization page</a>.</li>
          <li>Manage users. At this moment, they are all administrators. You probably don't want that.</li>
          <li>Configure the HTML for the entrance page.</li>
          <li>Optionally upload a logo for your organization.</li>
        </ol>
        <p>You're all set up! For support, refer to the <a href="http://teambox.com/community">Teambox community</a>.</p>
        <p>Enjoy!</p>
        <br/>
        <p style="font-size: 10px">If you like what we're doing, why not tell your friends about us or blog about it?</p>
      )
    end
    
    begin
    
    organization = Organization.create!(:name => "Your company name", :permalink => "organization", :description => description)
    
    Project.find_each(:batch_size => 500) do |project|
      project.update_attribute :organization_id, organization.id
    end
    User.find_each(:batch_size => 500) do |user|
      organization.add_member(user)
    end
    
    rescue
    end
  end

  def self.down
    Project.find_each(:batch_size => 500) do |project|
      project.update_attribute :organization_id, nil
    end
    Organization.destroy_all
  end
end
