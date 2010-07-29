class RenameUserLanguageToLocale < ActiveRecord::Migration
  def self.up
    rename_column :users, :language, :locale
    
    User.update_all({:locale => 'sl'}, :locale => 'si')
    User.update_all({:locale => 'pt-BR'}, :locale => 'pt')
  end

  def self.down
    rename_column :users, :locale, :language
  end
end
