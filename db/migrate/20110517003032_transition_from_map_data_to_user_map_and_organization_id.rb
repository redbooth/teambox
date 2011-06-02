class TransitionFromMapDataToUserMapAndOrganizationId < ActiveRecord::Migration
  class TeamboxData < ActiveRecord::Base
    belongs_to :organization
  end
  class Organization < ActiveRecord::Base
  end

  def self.up
    TeamboxData.all.each do |td|
      if td.map_data
        td.user_map = td.map_data['User']
        td.organization = Organization.find_by_permalink(td.map_data['target_organization'])
        td.save
      end
    end

    remove_column :teambox_datas, :map_data
  end

  def self.down
    add_column :teambox_datas, :map_data, :text

    TeamboxData.reset_column_information

    TeamboxData.all.each do |td|
      td.map_data['User'] = td.user_map if td.user_map
      td.map_data['target_organization'] = td.organization.permalink if td.organization
      td.save
    end

  end
end
