import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "link", "copyButton"]
  static classes = ["hidden"]

  toggle(event) {
    event.preventDefault()
    this.panelTarget.classList.toggle(this.hiddenClass || "is-hidden")
  }

  copy(event) {
    event.preventDefault()
    const text = this.linkTarget.innerText.trim()
    navigator.clipboard.writeText(text).then(() => {
      this.copyButtonTarget.innerText = "Copiado!"
    })
  }
}
