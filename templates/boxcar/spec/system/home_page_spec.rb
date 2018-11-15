# frozen_string_literal: true

require "rails_helper"

describe "Home Page" do
  it "welcomes the user to boxcar" do
    visit("/")

    expect(page).to have_content("Welcome to Boxcar!")
  end
end
