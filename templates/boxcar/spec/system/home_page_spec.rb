# frozen_string_literal: true

require "rails_helper"

describe "Home Page" do
  it "welcomes the user to boxcar" do
    visit("/")

    expect(page).to have_content("Welcome to Boxcar!")
  end

    it "renders a react component" do
    visit("/")

    expect(page).to have_content("You can put your react components here!")
  end
end
