import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.querySelectorAll('label').forEach(label => {
      label.addEventListener('mouseenter', () => {
        const card = label.querySelector('div')
        if (!label.querySelector('input').checked) {
          card.style.borderColor = "#5A3FE6"
        }
      })
      label.addEventListener('mouseleave', () => {
        const card = label.querySelector('div')
        if (!label.querySelector('input').checked) {
          card.style.borderColor = "#374151"
        }
      })
    })
  }

  select(event) {
    const soloCard = document.getElementById("type-solo")
    const sharedCard = document.getElementById("type-shared")
    const value = event.currentTarget.value

    if (value === "solo") {
      soloCard.style.borderColor = "#6C4DFF"
      soloCard.style.background = "rgba(108,77,255,0.1)"
      sharedCard.style.borderColor = "#374151"
      sharedCard.style.background = "#1F2937"
    } else {
      sharedCard.style.borderColor = "#6C4DFF"
      sharedCard.style.background = "rgba(108,77,255,0.1)"
      soloCard.style.borderColor = "#374151"
      soloCard.style.background = "#1F2937"
    }
  }
}

