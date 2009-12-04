require File.dirname(__FILE__) + '/../spec_helper'

describe UploadsController do
  route_matches("/assets/22/original/test", 
    :get, 
    :controller => "uploads", 
    :action => "download", 
    :filename =>"test", :id => "22", :style => "original")
  route_matches("/assets/22/original/test......", 
    :get, 
    :controller => "uploads", 
    :action => "download", 
    :filename =>"test......", :id => "22", :style => "original")
  route_matches("/assets/22/original/test.test",          
    :get, 
    :controller => "uploads", 
    :action => "download", 
    :filename =>"test.test", :id => "22", :style => "original")
  route_matches("/assets/22/original/test.jpg",           
    :get, 
    :controller => "uploads", 
    :action => "download", 
    :filename =>"test.jpg", :id => "22", :style => "original")
  route_matches("/assets/22/original/test.test.jpg",      
    :get, 
    :controller => "uploads", 
    :action => "download", 
    :filename =>"test.test.jpg", :id => "22", :style => "original")
  route_matches("/assets/22/original/test.test.test.jpg", 
    :get, 
    :controller => "uploads", 
    :action => "download", 
    :filename =>"test.test.test.jpg", :id => "22", :style => "original")
end  