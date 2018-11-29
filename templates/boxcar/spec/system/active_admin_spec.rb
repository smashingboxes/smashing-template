# frozen_string_literal: true

require "rails_helper"

describe "Active Admin" do
  it "renders the admin page" do
    visit("/admin")

    expect(page).to have_content("Powered by Active Admin")
  end
end
