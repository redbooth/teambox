class TransitionFromMapDataToUserMapAndOrganizationId < ActiveRecord::Migration
  class TeamboxData < ActiveRecord::Base
  end
  class Organization < ActiveRecord::Base
  end

  def self.up
    TeamboxData.all.each do |td|
      td.user_map = td.map_data['User']
      td.organization = Organization.find_by_permalink(td.map_data['target_organization'])
      td.save
    end

    remove_column :teambox_datas, :map_data
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
