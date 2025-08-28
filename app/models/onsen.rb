class Onsen < ApplicationRecord
  has_many :reviews, dependent: :destroy

  has_many_attached :images

  validates :name, presence: true

  validates :images,
  content_type: [ "image/jpeg", "image/png", "image/gif" ], # 許可ファイル形式
  size: { less_than: 5.megabytes },                       # 1枚あたり5MB未満
  limit: { max: 5 }                                     # 最大3枚まで

  # 住所変換するやつ。
  geocoded_by :address, latitude: :geo_lat, longitude: :geo_lng
  after_validation :geocode, if: :will_save_change_to_address?

  # @example Onsen.within_bounds([sw_lat, sw_lng, ne_lat, ne_lng])
  scope :within_bounds, ->(bounds) {
    return all if bounds.blank?
    sw_lat, sw_lng, ne_lat, ne_lng = bounds.map(&:to_f)
    where(geo_lat: sw_lat..ne_lat, geo_lng: sw_lng..ne_lng)
  }



  # @example Onsen.search(q: "玉造", tags: "露天風呂", lat: 35.1, lng: 132.5, radius_km: 10)
  def self.search(params)
    scope = all
    scope = apply_text_search(scope, params[:q])
    scope = apply_tag_search(scope, params[:tags])
    scope = apply_location_search(scope, params)
    scope
  end

  private_class_method

  # テキスト検索：名前・説明文の部分一致検索
  #
  # @param scope [ActiveRecord::Relation] 検索対象スコープ
  # @param query [String, nil] 検索クエリ
  # @return [ActiveRecord::Relation] 絞り込み後のスコープ
  def self.apply_text_search(scope, query)
    return scope unless query.present?

    q = query.strip
    scope.where("name ILIKE :q OR description ILIKE :q", q: "%#{q}%")
  end

  # タグ検索：カンマ区切りタグのOR条件検索
  #
  # @param scope [ActiveRecord::Relation] 検索対象スコープ
  # @param tags_param [String, nil] カンマ区切りタグ文字列
  # @return [ActiveRecord::Relation] 絞り込み後のスコープ
  def self.apply_tag_search(scope, tags_param)
    return scope unless tags_param.present?

    tags = tags_param.split(",").map(&:strip).reject(&:blank?)
    return scope unless tags.any?

    tag_query = tags.map { |_t| "tags ILIKE ?" }.join(" OR ")
    tag_values = tags.map { |t| "%#{t}%" }
    scope.where(tag_query, *tag_values)
  end

  # 価格が0円以上のみ登録可能
  class Onsen < ApplicationRecord
    has_many_attached :images
    has_many :reviews

    # -----------------------------
    # ここから追加
    # 料金の整数化（空欄は nil に）
    before_validation :normalize_price

    private

    def normalize_price
      if price.present? && price.to_s.strip != ""
        self.price = price.to_i
      else
        self.price = nil
      end
    end
    # ここまで追加
    # -----------------------------

    # バリデーション
    validates :name, presence: true
    validates :price,
      numericality: {
        only_integer: true,
        greater_than: 0,
        message: "は1円以上の整数で入力してください"
      },
      allow_nil: true
  end

  # 位置情報検索：二段階フィルタによる距離絞り込み
  #
  # @param scope [ActiveRecord::Relation] 検索対象スコープ
  # @param params [Hash] 位置パラメータ（lat, lng, radius_km）
  # @return [ActiveRecord::Relation, Array<Onsen>] 絞り込み後の結果
  def self.apply_location_search(scope, params)
    return scope unless location_search_valid?(params)

    lat, lng, radius = extract_location_params(params)
    scope = apply_rectangular_filter(scope, lat, lng, radius)
    apply_precise_distance_filter(scope, lat, lng, radius)
  end

  # 位置検索パラメータの有効性チェック
  #
  # @param params [Hash] パラメータハッシュ
  # @return [Boolean] 有効な位置パラメータが揃っているか
  def self.location_search_valid?(params)
    params[:lat].present? && params[:lng].present? && params[:radius_km].present?
  end

  # 位置検索パラメータの抽出・正規化
  #
  # @param params [Hash] パラメータハッシュ
  # @return [Array<Float>] [緯度, 経度, 半径] の配列
  def self.extract_location_params(params)
    lat = params[:lat].to_f
    lng = params[:lng].to_f
    radius = [ [ params[:radius_km].to_f, 1 ].max, 50 ].min  # 1-50km制限
    [ lat, lng, radius ]
  end

  # 第一段階：矩形範囲でデータベースレベル絞り込み
  #
  # @param scope [ActiveRecord::Relation] 検索対象スコープ
  # @param lat [Float] 基準緯度
  # @param lng [Float] 基準経度
  # @param radius [Float] 検索半径（km）
  # @return [ActiveRecord::Relation] 矩形範囲で絞り込み後のスコープ
  def self.apply_rectangular_filter(scope, lat, lng, radius)
    lat_delta = radius / 111.0  # 緯度1度≈111km
    lng_delta = radius / (111.0 * Math.cos(lat * Math::PI / 180))  # 経度補正

    scope.where(
      geo_lat: (lat - lat_delta)..(lat + lat_delta),
      geo_lng: (lng - lng_delta)..(lng + lng_delta)
    )
  end

  # 第二段階：厳密な球面距離計算による最終絞り込み
  #
  # @param scope [ActiveRecord::Relation] 矩形で絞り込み済みスコープ
  # @param lat [Float] 基準緯度
  # @param lng [Float] 基準経度
  # @param radius [Float] 検索半径（km）
  # @return [Array<Onsen>] 距離条件を満たすグルメ配列
  def self.apply_precise_distance_filter(scope, lat, lng, radius)
    scope.select do |onsen|
      DistanceCalculatorService.calculate(lat, lng, onsen.geo_lat, onsen.geo_lng) <= radius
    end
  end

  def open_now
    if sales_s.blank? || sales_f.blank?
          return "営業時間不明"
    end

    Time.zone = "Tokyo"
    now = Time.zone.now
    wday = %w[日 月 火 水 木 金 土][now.wday] # 現在の曜日を取得
    # holidayが空でなく、かつその曜日が含まれていたら休業

    return "休業中(定休日)" if holiday.present? && holiday.include?(wday)

    now_sec   = now.hour * 3600 + now.min * 60
    open_sec  = sales_s.to_time.hour * 3600 + sales_s.to_time.min * 60
    close_sec = sales_f.to_time.hour * 3600 + sales_f.to_time.min * 60

    if open_sec > close_sec
      close_sec += 24 * 3600
    end

    if close_sec - now_sec <= 30.minutes && now_sec < close_sec
      "まもなく閉店 (閉店まであと#{(close_sec - now_sec) / 60}分)"

    elsif open_sec <= now_sec && now_sec <= close_sec
      "営業中"

    elsif now_sec < open_sec && open_sec - now_sec <= 30.minutes
      "まもなく開店 (開店まであと#{(open_sec - now_sec) / 60}分)"

    else
      sales_s_time = sales_s.to_time
      if now_sec < open_sec
        # 今日の開店前
        "営業時間外 (#{sales_s_time.strftime('%H:%M')} から開店)"
      else
        # 今日の営業は終了 → 翌日の開店まで待つ
        "営業時間外 (明日 #{sales_s_time.strftime('%H:%M')} に開店)"
      end
    end
  end

  # 営業状態アイコン
  def status_icon
    return "close" if sales_s.blank? || sales_f.blank?

    Time.zone = "Tokyo"
    now = Time.zone.now

    now_sec   = now.hour * 3600 + now.min * 60
    open_sec  = sales_s.to_time.hour * 3600 + sales_s.to_time.min * 60
    close_sec = sales_f.to_time.hour * 3600 + sales_f.to_time.min * 60

    if open_sec > close_sec
      close_sec += 24 * 3600
    end

    if open_sec <= now_sec && now_sec <= close_sec
      if close_sec - now_sec <= 30.minutes
        "close_soon"
      else
        "open"
      end
    elsif now_sec < open_sec
      if open_sec - now_sec <= 30.minutes
        "open_soon"
      else
        "close"
      end
    else
      # 今日の営業終了 → 翌日の開店待ち
      "close"
    end
  end
end
