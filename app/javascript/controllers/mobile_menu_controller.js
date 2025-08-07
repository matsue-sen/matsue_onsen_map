import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-menu"
export default class extends Controller {
  static targets = ["button", "menu"]

  connect() {
    // 初期状態ではメニューは非表示
    this.hideMenu()
  }

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.showMenu()
    } else {
      this.hideMenu()
    }
  }

  showMenu() {
    this.menuTarget.classList.remove("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "true")
    
    // ハンバーガーアイコンをクローズアイコンに変更
    const hamburgerIcon = this.buttonTarget.querySelector("svg:first-child")
    const closeIcon = this.buttonTarget.querySelector("svg:last-child")
    
    if (hamburgerIcon && closeIcon) {
      hamburgerIcon.classList.add("hidden")
      closeIcon.classList.remove("hidden")
    }
  }

  hideMenu() {
    this.menuTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")
    
    // クローズアイコンをハンバーガーアイコンに変更
    const hamburgerIcon = this.buttonTarget.querySelector("svg:first-child")
    const closeIcon = this.buttonTarget.querySelector("svg:last-child")
    
    if (hamburgerIcon && closeIcon) {
      hamburgerIcon.classList.remove("hidden")
      closeIcon.classList.add("hidden")
    }
  }

  // メニュー外をクリックした時にメニューを閉じる
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideMenu()
    }
  }

  // 画面サイズが変更された時にメニューを閉じる（デスクトップサイズになった場合）
  resize() {
    if (window.innerWidth >= 768) { // md breakpoint
      this.hideMenu()
    }
  }
} 