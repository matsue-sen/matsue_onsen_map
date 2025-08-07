require "test_helper"

class DistanceCalculatorServiceTest < ActiveSupport::TestCase
  test "calculate distance between same points" do
    distance = DistanceCalculatorService.calculate(35.4681, 133.0486, 35.4681, 133.0486)
    assert_equal 0.0, distance.round(2)
  end

  test "calculate distance between different points" do
    # 東京と大阪の距離（概算）
    distance = DistanceCalculatorService.calculate(35.6762, 139.6503, 34.6937, 135.5023)
    assert_in_delta 400.0, distance, 50.0  # 約400km（誤差50km以内）
  end

  test "calculate distance with negative coordinates" do
    # ニューヨークとロンドンの距離（概算）
    distance = DistanceCalculatorService.calculate(40.7128, -74.0060, 51.5074, -0.1278)
    assert_in_delta 5500.0, distance, 500.0  # 約5500km（誤差500km以内）
  end

  test "calculate distance with decimal precision" do
    # 松江市内の2点間の距離
    distance = DistanceCalculatorService.calculate(35.4681, 133.0486, 35.4567, 133.1234)
    assert distance > 0
    assert distance < 10  # 10km以内
  end
end
