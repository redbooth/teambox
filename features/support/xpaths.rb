module XPath
  module HTML
    include XPath
    extend self

  protected

    def locate_field(xpath, locator)
      ".//input[./@type = 'checkbox'][((./@id = '#{locator}' or ./@name = '#{locator}') or ./@id = //label[contains(./text(), '#{locator}')]/@for)] | .//label[contains(normalize-space(.), '#{locator}')]//.//input[./@type = 'checkbox']"
    end

  end
end

