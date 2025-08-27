import { Controller } from "@hotwired/stimulus"

// <img data-controller="lightbox" data-action="click->lightbox#open" data-lightbox-src="画像URL"> の形式で使う
export default class extends Controller {
  static targets = ["overlay", "image"]

  connect() {
    // overlay がなければ動的に作成
    if (!document.querySelector("#lightbox-overlay")) {
      const overlay = document.createElement("div")
      overlay.id = "lightbox-overlay"
      overlay.className = "fixed inset-0 bg-black bg-opacity-80 flex items-center justify-center hidden z-50"
      overlay.innerHTML = `
        <div class="relative flex items-center justify-center w-full h-full">
          <img id="lightbox-image" class="max-h-[80vh] max-w-[80vw] rounded shadow-lg cursor-pointer object-contain" />
          <div id="lightbox-caption" class="absolute bottom-0 left-0 right-0 bg-black bg-opacity-70 text-white p-3 text-center rounded-b"></div>
        </div>
      `
      document.body.appendChild(overlay)

      overlay.addEventListener("click", () => {
        overlay.classList.add("hidden")
      })
    }
  }

  open(event) {
    event.preventDefault()
    event.stopPropagation()
    
    // 画像のsrc属性またはdata-lightbox-src属性からURLを取得
    const url = this.element.getAttribute("data-lightbox-src") || this.element.src
    const alt = this.element.alt || "画像"
    
    const overlay = document.querySelector("#lightbox-overlay")
    const img = document.querySelector("#lightbox-image")
    const caption = document.querySelector("#lightbox-caption")

    img.src = url
    caption.textContent = alt
    overlay.classList.remove("hidden")
  }
}