# frozen_string_literal: true

class HomePage < BasePage
  class << self
    def view
      visit "/"
    end
  end
end
