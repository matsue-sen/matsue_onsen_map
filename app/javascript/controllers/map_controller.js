import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

// Connects to data-controller="map"
export default class extends Controller {
  static targets = ["container"]
  static values = {
    onsens: Array
  }

  connect() {
    console.log("Map controller connected!"); // 追加
    console.log("Container target:", this.containerTarget); // 追加

    this.userLocationMarker = null; // 現在地マーカーを保持するプロパティ

    if (!this.containerTarget) { // 追加
      console.error("Map container target is missing!"); // 追加
      return; // 追加: ターゲットがない場合はこれ以上処理しない
    }

    this.map = L.map(this.containerTarget).setView([35.468, 133.0483], 11.5);
    console.log("Leaflet map initialized:", this.map); // 追加

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(this.map);
    console.log("Tile layer added."); // 追加

    // 温泉マーカーを保持するレイヤーグループを作成
    this.onsenMarkers = L.layerGroup().addTo(this.map);
    console.log("Onsen markers layer group created."); // 追加
    this._plotOnsens(); // 初期マーカーをプロット
    console.log("Initial onsens plotted."); // 追加
  }

  /**
   * ユーザーの現在地を取得して地図に表示します。
   * HTML側で <button data-action="click->map#locateUser">現在地</button> のようにして呼び出します。
   */
  locateUser() {
    if (!navigator.geolocation) {
      alert("お使いのブラウザは現在地取得機能に対応していません。");
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (position) => this._handleGeolocationSuccess(position),
      (error) => this._handleGeolocationError(error),
      {
        enableHighAccuracy: true, // 高精度な位置情報を要求
        timeout: 10000,           // 10秒でタイムアウト
        maximumAge: 0             // キャッシュを使用しない
      }
    );
  }

  /**
   * 温泉データを地図にプロットする
   * @private
   */
  _plotOnsens() {
    console.log("Plotting onsens. Data:", this.onsensValue);
    this.onsenMarkers.clearLayers();

    this.onsensValue.forEach(onsen => {
      if (onsen.geo_lat && onsen.geo_lng) {
        const onsenIcon = L.icon({
          // status_icon があるならそれを使い、なければデフォルト画像
          iconUrl: onsen.status_icon ? `/${onsen.status_icon}.svg` : '/onsen.png',
          iconSize: [32, 32],
          iconAnchor: [16, 32],
        });

        L.marker([onsen.geo_lat, onsen.geo_lng], { icon: onsenIcon })
          .bindPopup(onsen.name)
          .addTo(this.onsenMarkers);
      } else {
        console.warn("Onsen missing geo_lat or geo_lng:", onsen);
      }
    });

    console.log("Onsens plotting complete.");
  }


  disconnect() {
    console.log("Map controller disconnected."); // 追加
    if (this.map) {
      this.map.remove();
      this.map = null;
      console.log("Map removed."); // 追加
    }
  }


  /**
   * 現在地取得成功時の処理
   * @param {GeolocationPosition} position
   * @private
   */
  _handleGeolocationSuccess(position) {
    const { latitude, longitude } = position.coords;
    const userLatLng = L.latLng(latitude, longitude);

    // 地図の中心を現在地に移動し、ズームレベルを調整
    this.map.setView(userLatLng, 15);

    // 既存の現在地マーカーがあれば削除
    if (this.userLocationMarker) {
      this.userLocationMarker.remove();
    }

    // 新しいマーカーを作成して追加 (Leafletのデフォルトアイコンを使用)
    this.userLocationMarker = L.marker(userLatLng)
      .addTo(this.map)
      .bindPopup("<b>現在地</b>")
      .openPopup();
  }


  /**
   * 現在地取得失敗時の処理
   * @param {GeolocationPositionError} error
   * @private
   */
  _handleGeolocationError(error) {
    let message = "現在地の取得に失敗しました。";
    switch (error.code) {
      case error.PERMISSION_DENIED:
        message = "位置情報の利用が許可されていません。ブラウザの設定を確認してください。";
        break;
      case error.POSITION_UNAVAILABLE:
        message = "位置情報を取得できませんでした。";
        break;
      case error.TIMEOUT:
        message = "位置情報の取得がタイムアウトしました。";
        break;
    }
    alert(message);
    console.error("Geolocation error:", error);
  }
}
