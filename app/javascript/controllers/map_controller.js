import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

// Connects to data-controller="map"
export default class extends Controller {
  static targets = ["container"]
  static values = { onsens: Array }

  connect() {
    this.onsens = this._parseOnsensData();
    console.log(this.onsens);

    this.map = L.map(this.containerTarget).setView([35.468, 133.0483], 11.5);

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(this.map);

    const onsenIcon = L.icon({
      iconUrl: '/onsen.svg',
      iconSize: [32, 32],
      iconAnchor: [16, 32],
    });

    this.onsens.forEach(onsen => {
      L.marker([onsen.geo_lat, onsen.geo_lng], { icon: onsenIcon })
        .addTo(this.map)
        .bindPopup(onsen.name);
    });
  }

  disconnect() {
    if (this.map) {
      this.map.remove();
      this.map = null;
    }
  }

  // === プライベートメソッド（内部処理用） ===

  /**
   * HTML要素からグルメデータを取得・パース
   * @returns {Array} グルメデータの配列
   */
  _parseOnsensData() {
    try {
      const rawData = this.element.dataset.mapOnsens || "[]";
      return JSON.parse(rawData);
    } catch (error) {
      console.warn("グルメデータのパースに失敗:", error);
      return [];
    }
  }
}
