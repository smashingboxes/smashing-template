# frozen_string_literal: true

require "rails_helper"

describe "Home Page" do
  it "welcomes the user to boxcar" do
    visit("/")

    expect(page).to have_content("Welcome to Boxcar!")
  end

  it "renders a react component", js: true do
    visit("/")

    expect(page).to have_content("Hello World From React!")
  end
end
