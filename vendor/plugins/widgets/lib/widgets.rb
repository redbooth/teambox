# Widgets
require 'widgets/core'
require 'widgets/css_template'
require 'widgets/disableable'

##### Navigation #####
require 'widgets/navigation_item'
require 'widgets/navigation'
require 'widgets/navigation_helper'
ActionController::Base.helper Widgets::NavigationHelper

##### Tabnav #####
require 'widgets/tab'
require 'widgets/tabnav'
require 'widgets/tabnav_helper'
ActionController::Base.helper Widgets::TabnavHelper

