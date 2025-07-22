require "application_system_test_case"

class OnsensTest < ApplicationSystemTestCase
  setup do
    @onsen = onsens(:one)
  end

  test "visiting the index" do
    visit onsens_url
    assert_selector "h1", text: "Onsens"
  end

  test "should create onsen" do
    visit admin_onsens_url
    click_on "New onsen"

    fill_in "Description", with: @onsen.description
    fill_in "Geo lat", with: @onsen.geo_lat
    fill_in "Geo lng", with: @onsen.geo_lng
    fill_in "Name", with: @onsen.name
    fill_in "Tags", with: @onsen.tags
    click_on "Create Onsen"

    assert_text "Onsen was successfully created"
    click_on "Back"
  end

  test "should update Onsen" do
    visit admin_onsen_url(@onsen)
    click_on "Edit this onsen", match: :first

    fill_in "Description", with: @onsen.description
    fill_in "Geo lat", with: @onsen.geo_lat
    fill_in "Geo lng", with: @onsen.geo_lng
    fill_in "Name", with: @onsen.name
    fill_in "Tags", with: @onsen.tags
    click_on "Update Onsen"

    assert_text "Onsen was successfully updated"
    click_on "Back"
  end

  test "should destroy Onsen" do
    visit admin_onsen_url(@onsen)
    accept_confirm { click_on "Destroy this onsen", match: :first }

    assert_text "Onsen was successfully destroyed"
  end
end
