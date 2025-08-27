import { Controller } from "@hotwired/stimulus";
import GLightbox from "glightbox";

export default class extends Controller {
  static values = {
    selector:   { type: String,  default: "a[data-lightbox]" },
    loop:       { type: Boolean, default: true },
    touch:      { type: Boolean, default: true },
    closeOnOutsideClick: { type: Boolean, default: true }
  }

  connect() {
    this.lb = GLightbox({
      selector: this.selectorValue,
      loop: this.loopValue,
      touchNavigation: this.touchValue,
      closeOnOutsideClick: this.closeOnOutsideClickValue
      // 他にもオプション指定可（zoomable, draggable など）
    });
  }

  disconnect() {
    if (this.lb) this.lb.destroy();
  }

  // 任意: ボタン等から強制的に開きたいときに使える
  open(event) {
    event?.preventDefault();
    this.lb?.open();
  }
}