class DistanceCalculatorService
  # 地球の半径（km）
  EARTH_RADIUS = 6371.0

  # 2点間の距離を計算する（Haversine formula）
  #
  # @param lat1 [Float] 1点目の緯度
  # @param lng1 [Float] 1点目の経度
  # @param lat2 [Float] 2点目の緯度
  # @param lng2 [Float] 2点目の経度
  # @return [Float] 2点間の距離（km）
  def self.calculate(lat1, lng1, lat2, lng2)
    # 度からラジアンに変換
    lat1_rad = lat1 * Math::PI / 180
    lng1_rad = lng1 * Math::PI / 180
    lat2_rad = lat2 * Math::PI / 180
    lng2_rad = lng2 * Math::PI / 180

    # 緯度と経度の差
    delta_lat = lat2_rad - lat1_rad
    delta_lng = lng2_rad - lng1_rad

    # Haversine formula
    a = Math.sin(delta_lat / 2)**2 +
        Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(delta_lng / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    # 距離を計算
    EARTH_RADIUS * c
  end
end
