/**
 * 住所→緯度経度変換 Stimulusコントローラ
 *
 * == 初学者向け解説 ==
 * このコントローラは、日本語住所から緯度経度を取得する機能を提供します。
 * @geolonia/normalize-japanese-addresses ライブラリを使用して、
 * 住所の正規化とジオコーディングを行います。
 *
 * == 主要機能 ==
 * 1. 住所入力値の取得とバリデーション
 * 2. 住所正規化とジオコーディング
 * 3. 緯度経度フィールドへの自動入力
 * 4. ユーザーフレンドリーなローディング表示
 * 5. エラーハンドリングと成功時通知
 *
 * == Stimulusパターンの学習ポイント ==
 * - Targetsによる要素の取得・制御
 * - 外部ライブラリの統合
 * - DOMの動的操作とアニメーション
 * - エラーハンドリングのベストプラクティス
 *
 * @see https://github.com/geolonia/normalize-japanese-addresses 住所正規化ライブラリ
 * @see https://stimulus.hotwired.dev/ Stimulus公式ドキュメント
 * @since 1.0.0
 */
import { Controller } from "@hotwired/stimulus";
import { normalize } from "@geolonia/normalize-japanese-addresses";

export default class extends Controller {
  /**
   * Stimulus Target設定
   * data-geocode-target="address" - 住所入力フィールド
   * data-geocode-target="lat" - 緯度入力フィールド
   * data-geocode-target="lng" - 経度入力フィールド
   */
  static targets = ["address", "lat", "lng"];

  /**
   * DOM要素の動的取得：検索ボタン
   * @returns {HTMLElement} 検索ボタン要素
   * @note 毎回DOM検索を行うため、頻繁な呼び出しには注意
   */
  get button() {
    const button = this.element.querySelector("#geocode-search-btn");
    if (!button) {
      console.warn("GeocodeController: 検索ボタンが見つかりません。ID 'geocode-search-btn' が設定されているか確認してください。");
    }
    return button;
  }

  /**
   * ローディング表示用のSVGスピナー
   * @returns {string} SVGアニメーションのHTML文字列
   * @note Tailwind CSSのanimate-spinクラスを使用
   */
  spinner() {
    return (
      '<svg class="inline w-4 h-4 mr-1 animate-spin text-blue-500" viewBox="0 0 24 24">' +
      '<circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"></circle>' +
      '<path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"></path>' +
      "</svg>"
    );
  }

  /**
   * Stimulusライフサイクル：コントローラ初期化時
   * @note DOM要素の初期設定やイベントリスナー設定に使用
   */
  connect() {
    console.log("GeocodeController: 住所→緯度経度変換機能が初期化されました");
  }

  /**
   * メイン機能：住所から緯度経度を検索・自動入力
   *
   * == 処理フロー ==
   * 1. 住所の入力値検証（空文字チェック）
   * 2. UI更新（ボタン無効化・ローディング表示）
   * 3. 住所正規化とジオコーディング
   * 4. 取得結果の緯度経度欄への反映
   * 5. UI復元（ボタン再有効化・成功通知）
   *
   * @public データ属性data-action="click->geocode#search"により呼び出し
   */
  search() {
    // Step 1: 住所の入力値検証
    const address = this.addressTarget.value.trim();

    if (!address) {
      alert("住所を入力してください");
      return;
    }

    // Step 2: ボタンクリック時の視覚フィードバック
    this._showClickAnimation();

    // Step 3: ローディング状態に移行
    this._showLoadingState();

    // Step 4: 住所正規化とジオコーディング
    this._geocodeAddress(address);
  }

  /**
   * プライベート：ボタンクリック時のアニメーション効果
   * @private
   * @note 押した感を演出し、ユーザビリティを向上
   */
  _showClickAnimation() {
    if (!this.button) {
      console.warn("GeocodeController: アニメーションをスキップします（ボタンが見つかりません）");
      return;
    }

    this.button.classList.add(
      "scale-95", // 少し縮小
      "bg-blue-200", // 背景色変更
      "transition", // スムーズなアニメーション
      "duration-150" // 150msの短時間
    );

    // 150ms後に元の状態に戻す
    setTimeout(() => {
      if (this.button) {
        this.button.classList.remove("scale-95", "bg-blue-200");
      }
    }, 150);
  }

  /**
   * プライベート：ローディング状態のUI表示
   * @private
   * @note API処理中であることをユーザーに明示
   */
  _showLoadingState() {
    if (!this.button) {
      console.warn("GeocodeController: ローディング状態の表示をスキップします（ボタンが見つかりません）");
      return;
    }

    // 元のボタンテキストを保存
    this.originalButtonText = this.button.innerHTML;

    // ローディング表示に変更
    this.button.innerHTML = this.spinner() + "座標取得中...";
    this.button.disabled = true;
    this.button.classList.add("opacity-50", "cursor-wait");
  }

  /**
 * プライベート：住所正規化とジオコーディング
 * @private
 * @param {string} address 住所文字列
 */
  async _geocodeAddress(address) {
    try {
      // 住所正規化とジオコーディング実行
      const result = await normalize(address);

      this._handleGeocodeSuccess(result);
    } catch (error) {
      this._handleGeocodeError(error);
    } finally {
      this._restoreButtonState();
    }
  }

  /**
   * プライベート：ジオコーディング成功時の処理
   * @private
   * @param {Object} result ジオコーディング結果
   */
  _handleGeocodeSuccess(result) {
    if (result.point && result.point.lat && result.point.lng) {
      // 緯度経度フィールドに自動入力
      this.latTarget.value = result.point.lat.toFixed(6);
      this.lngTarget.value = result.point.lng.toFixed(6);

      // 成功通知を表示
      this._showSuccessNotification(
        `緯度経度を取得しました: ${result.point.lat.toFixed(6)}, ${result.point.lng.toFixed(6)}`
      );

      console.log("ジオコーディング結果:", result);
    } else {
      alert("該当する座標が見つかりませんでした。住所をご確認ください。");
    }
  }

  /**
   * プライベート：ジオコーディング失敗時の処理
   * @private
   * @param {Error} error エラーオブジェクト
   */
  _handleGeocodeError(error) {
    console.error("住所→緯度経度変換エラー:", error);
    alert("座標取得に失敗しました。住所をご確認ください。");
  }

  /**
   * プライベート：ボタン状態の復元
   * @private
   */
  _restoreButtonState() {
    if (!this.button) {
      console.warn("GeocodeController: ボタン状態の復元をスキップします（ボタンが見つかりません）");
      return;
    }

    // 元のボタンテキストを復元（保存されていない場合はデフォルト値を使用）
    this.button.innerHTML = this.originalButtonText || "住所→座標";
    this.button.disabled = false;
    this.button.classList.remove("opacity-50", "cursor-wait");
  }

  /**
   * プライベート：成功時の控えめな通知表示
   * @private
   * @param {string} message 通知メッセージ
   * @note アラートの代わりに、画面右上に一時的なトースト通知を表示
   */
  _showSuccessNotification(message) {
    // トースト通知要素を作成
    const notification = document.createElement("div");
    notification.textContent = message;
    notification.className = [
      "fixed",
      "top-4",
      "right-4", // 位置：画面右上
      "bg-green-500",
      "text-white", // 色：緑背景・白文字
      "px-4",
      "py-2",
      "rounded",
      "shadow-lg", // スタイル：パディング・角丸・影
      "z-50", // 最前面表示
      "transition-opacity",
      "duration-300", // フェードアニメーション
    ].join(" ");

    // DOMに追加して表示
    document.body.appendChild(notification);

    // 3秒後にフェードアウト開始
    setTimeout(() => {
      notification.classList.add("opacity-0");

      // フェードアウト完了後にDOM削除
      setTimeout(() => {
        if (notification.parentNode) {
          notification.parentNode.removeChild(notification);
        }
      }, 300);
    }, 3000);
  }
} 
