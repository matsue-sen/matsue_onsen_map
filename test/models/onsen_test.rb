require "test_helper"

class OnsenTest < ActiveSupport::TestCase
  def setup
    @onsen = onsens(:one)
  end

  test "should be valid" do
    assert @onsen.valid?
  end

  test "name should be present" do
    @onsen.name = nil
    assert_not @onsen.valid?
  end

  test "should have many reviews" do
    assert_respond_to @onsen, :reviews
  end

  test "should destroy associated reviews when deleted" do
    @onsen.reviews.create!(rating: 5, comment: "Great onsen!")
    review_count = @onsen.reviews.count
    assert_difference "Review.count", -review_count do
      @onsen.destroy
    end
  end

  test "should have many attached images" do
    assert_respond_to @onsen, :images
  end
end
