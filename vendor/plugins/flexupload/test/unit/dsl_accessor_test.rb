require File.dirname(__FILE__) + '/../test_helper.rb'

class DslAccessorTest < Test::Unit::TestCase
  class CoolActiveRecord
    dsl_accessor :primary_key
    dsl_accessor :table_name
  end

  class Item < CoolActiveRecord
  end

  class LegacyItem < CoolActiveRecord
    primary_key :itcd
    table_name  :item
  end


  def test_accessor_without_initialization
    assert_equal nil, Item.primary_key
    assert_equal nil, Item.table_name

    Item.primary_key :itcd
    Item.table_name  :item

    assert_equal :itcd, Item.primary_key
    assert_equal :item, Item.table_name
  end

  def test_accessor_with_initialization
    assert_equal :itcd, LegacyItem.primary_key
    assert_equal :item, LegacyItem.table_name

    LegacyItem.primary_key :item_id
    LegacyItem.table_name  :item_table

    assert_equal :item_id,    LegacyItem.primary_key
    assert_equal :item_table, LegacyItem.table_name
  end
end


class DslDefaultAccessorTest < Test::Unit::TestCase

  class CoolActiveRecord
    dsl_accessor :primary_key, :default=>"id"
    dsl_accessor :table_name,  :default=>proc{|klass| klass.name.demodulize.underscore.pluralize}
  end

  class Item < CoolActiveRecord
  end

  class User < CoolActiveRecord
  end

  class Folder
    dsl_accessor :array_folder, :default=>[]
    dsl_accessor :hash_folder,  :default=>{}
  end

  class SubFolder < Folder
  end

  def test_default_accessor_with_string
    assert_equal "id", Item.primary_key
    assert_equal "id", User.primary_key
  end

  def test_default_accessor_with_proc
    assert_equal "items", Item.table_name
    assert_equal "users", User.table_name
  end

  def test_default_accessor_should_duplicate_empty_array_or_hash
    Folder.array_folder << 1
    Folder.hash_folder[:name] = "maiha"

    assert_equal([1], Folder.array_folder)
    assert_equal({:name=>"maiha"}, Folder.hash_folder)

    assert_equal([], SubFolder.array_folder)
    assert_equal({}, SubFolder.hash_folder)
  end
end


class DslOverwritenDefaultAccessorTest < Test::Unit::TestCase
  class CoolActiveRecord
    dsl_accessor :primary_key, :default=>"id"
    dsl_accessor :table_name,  :default=>proc{|klass| klass.name.demodulize.underscore.pluralize}
  end

  class Item < CoolActiveRecord
    primary_key :item_id
    table_name  :item_table
  end

  def test_overwrite_default_accessor
    assert_equal :item_id,    Item.primary_key
    assert_equal :item_table, Item.table_name
  end
end


class DslWriterAccessorTest < Test::Unit::TestCase
  class Item
    dsl_accessor :primary_key, :writer=>proc{|value| value.to_s}
  end

  def test_string_writer
    assert_equal "", Item.primary_key

    Item.primary_key :id
    assert_equal "id", Item.primary_key

    Item.primary_key "id"
    assert_equal "id", Item.primary_key
  end
end


