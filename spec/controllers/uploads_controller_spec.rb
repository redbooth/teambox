require File.dirname(__FILE__) + '/../spec_helper'

describe UploadsController do
  #{:get,'/assets/22/original/test.jpg'}.should route_for(:controller => 'uploads', :action => 'download')


  #{:get,''}.should route_to(:controller => 'uploads', :action => 'download')
  #{:get,''}.should route_to(:controller => 'uploads', :action => 'download')
  #{:get,''}.should route_to(:controller => 'uploads', :action => 'download')

end  