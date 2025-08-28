require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  def setup
    @onsen = onsens(:one)
    @review = @onsen.reviews.build(rating: 5, comment: "素晴らしいグルメでした")
  end

  test "should be valid" do
    assert @review.valid?
  end

  test "should belong to onsen" do
    assert_respond_to @review, :onsen
  end

  test "should have many attached images" do
    assert_respond_to @review, :images
  end

  test "rating should be present" do
    @review.rating = nil
    assert_not @review.valid?
  end

  test "rating should be a number" do
    @review.rating = "not a number"
    assert_not @review.valid?
  end

  test "rating should be between 1 and 5" do
    @review.rating = 0
    assert_not @review.valid?

    @review.rating = 6
    assert_not @review.valid?

    @review.rating = 5
    assert @review.valid?
  end

  test "comment can be blank" do
    @review.comment = nil
    assert @review.valid?
  end

  test "should be destroyed when onsen is destroyed" do
    @review.save!
    review_count = @onsen.reviews.count
    assert_difference "Review.count", -review_count do
      @onsen.destroy
    end
  end

  test "should have correct onsen association" do
    @review.save!
    assert_equal @onsen, @review.onsen
  end
end
