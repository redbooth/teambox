require File.dirname(__FILE__) + '/test_helper'

class TabTest < Test::Unit::TestCase
  include Widgets
  
  EXPECTED_INSTANCE_METHODS = %w{highlights link name title html highlighted? highlights_on links_to named titled}
  
  def setup    
    @myname = 'Paolo'
    @mysurname = 'Dona'
   
    @tab = Tab.new :name => 'tab', :link => {:controller => 'pippo', :action => 'pluto'}
    @simple_tab = Tab.new :name => 'simple_tab', :link => {:controller =>'pippo'}

    @dyntab = Tab.new :name => @myname, 
                      :link => {:controller => 'pippo', :action => @myname},
                      :highlights => [{:controller => @mysurname}]
    
    @distab = Tab.new :name => 'disabled_tab', 
                      :link => {:controller => 'pippo'}, 
                      :disabled_if => proc { 1 == 1 }

    @empty = Tab.new :name => 'empty'
  end
     
  def test_initialize_with_hash
    tab = Tab.new :name => 'sample'
    assert tab
    assert_equal 'sample', tab.name
  end
  
  def test_initialize_with_block
    tab = Tab.new do |t|
      t.name = 'sample'
    end
    assert tab
    assert_equal 'sample', tab.name
  end
  
  def test_initialize_with_highlights_array
    tab = Tab.new :name=>'test', :highlights => [{:action=>'list'}, {:action => 'index'}]
    assert_kind_of Array, tab.highlights
    assert_equal 2, tab.highlights.size
    assert_kind_of Hash, tab.highlights[0]
    assert_kind_of Hash, tab.highlights[1]
  end
  
  def test_initialize_with_single_highlight
    tab = Tab.new :name=>'test', :highlights => {:action=>'list'}
    assert_kind_of Array, tab.highlights
    assert_equal 1, tab.highlights.size
    assert_kind_of Hash, tab.highlights[0]
  end
  
    
  def test_presence_of_instance_methods
    EXPECTED_INSTANCE_METHODS.each do |instance_method|
      assert @tab.respond_to?(instance_method), "#{instance_method} is not defined in #{@tab.inspect} (#{@tab.class})" 
    end     
  end
  
  def test_name_dynamic
    assert_equal 'Paolo', @dyntab.name
   
    @dyntab.name= @mysurname 
    assert_equal 'Dona', @dyntab.name
  end
  
  def test_links_to
    assert_equal({:controller => 'pippo', :action => 'pluto'}, @tab.link)
    
    @tab.link= {:controller => 'pluto'}
    assert_equal({:controller => 'pluto'}, @tab.link)
  end
  
  def test_links_to_dynamic
    assert_equal({:controller => 'pippo', :action => 'Paolo'}, @dyntab.link)
    
    @dyntab.link= {:controller => @mysurname}  
    assert_equal({:controller => 'Dona'}, @dyntab.link)
  end
  
  def test_highlighted?
    t = Tab.new :name => 'cats', :highlights => {:controller => 'cats'}
    assert t.highlighted?({:controller => 'cats'})
  end

  def test_disabled?
    assert @distab.disabled?
    assert !@simple_tab.disabled?
  end
  
end
