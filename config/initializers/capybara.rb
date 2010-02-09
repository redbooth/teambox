# This monkey-patching does not work here so it I put it in the 0.2.0 gem
# however, this is clearly not the best solution, probably the project should
# be forked and that gem used.
# module Capybara
#   class Session
#     def click_element(locator)
#       element = wait_for(XPath.element(locator))
#       raise Capybara::ElementNotFound, "the element '#{locator}' could not be found" unless element
#       element.click
#     end
#   end
#
#   class XPath
#     def element(locator)
#       append("//div[@id=#{s(locator)}]")
#     end
#   end
# end
#
# module Capybara
#   class << self
#     class_eval <<-RUBY, __FILE__, __LINE__+1
#       def click_element(*args, &block)
#         page.click_element(*args, &block)
#       end
#     RUBY
#   end
# end