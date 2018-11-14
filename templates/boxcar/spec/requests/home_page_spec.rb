# frozen_string_literal: true

require "rails_helper"

describe HomePage do
  it "welcomes the user to boxcar", type: :feature do
    described_class.view

    expect(page).to have_content("Welcome to Boxcar!")
  end
end
