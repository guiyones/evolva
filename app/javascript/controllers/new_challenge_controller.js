import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["durationInput", "durationCustom", "questSection", "questSelect", "questIdField", "challengeTypeField", "summary", "summaryText", "submitBtn"]

  connect() {
    this.selectedDuration = null
    this.updateSummary()
  }

  selectDuration(event) {
    const btn = event.currentTarget
    const value = btn.dataset.days

    // Reset all buttons
    this.element.querySelectorAll("[data-duration-btn]").forEach(b => {
      b.style.borderColor = "#374151"
      b.style.background = "#1F2937"
      b.style.color = "#6b7280"
    })

    if (value === "custom") {
      this.durationCustomTarget.style.display = "block"
      this.durationInputTarget.value = ""
      this.durationInputTarget.focus()
      btn.style.borderColor = "#6C4DFF"
      btn.style.background = "rgba(108,77,255,0.1)"
      btn.style.color = "#f3f4f6"
    } else {
      this.durationCustomTarget.style.display = "none"
      this.durationInputTarget.value = value
      btn.style.borderColor = "#6C4DFF"
      btn.style.background = "rgba(108,77,255,0.1)"
      btn.style.color = "#f3f4f6"
    }
    this.updateSummary()
  }

  selectQuest(event) {
    const btn = event.currentTarget
    const questId = btn.dataset.questId

    this.element.querySelectorAll("[data-quest-btn]").forEach(b => {
      b.style.borderColor = "#374151"
      b.style.background = "#1F2937"
      b.style.color = "#6b7280"
    })

    btn.style.borderColor = "#6C4DFF"
    btn.style.background = "rgba(108,77,255,0.1)"
    btn.style.color = "#f3f4f6"

    this.questIdFieldTarget.value = questId
    this.updateSummary()
  }

  toggleQuest(event) {
    const value = event.currentTarget.value
    if (value === "yes") {
      this.questSelectTarget.style.display = "block"
    } else {
      this.questSelectTarget.style.display = "none"
      this.questIdFieldTarget.value = ""
      this.element.querySelectorAll("[data-quest-btn]").forEach(b => {
        b.style.borderColor = "#374151"
        b.style.background = "#1F2937"
        b.style.color = "#6b7280"
      })
    }
    this.updateSummary()
    this.updateSubmitLabel()
  }

  updateSummary() {
    const title = this.element.querySelector("[data-field='title']")?.value
    const days = this.durationInputTarget.value
    if (title && days) {
      this.summaryTextTarget.textContent = `${title} por ${days} dias`
      this.summaryTarget.style.display = "block"
    } else {
      this.summaryTarget.style.display = "none"
    }
  }

  updateSubmitLabel() {
    const questRadio = this.element.querySelector("input[name='quest_option']:checked")
    if (questRadio && questRadio.value === "yes") {
      this.submitBtnTarget.value = "Planejar desafio"
    } else {
      this.submitBtnTarget.value = "Começar agora"
    }
  }

  selectType(event) {
    const btn = event.currentTarget
    const value = btn.dataset.type

    this.element.querySelectorAll("[data-type-btn]").forEach(b => {
      b.style.borderColor = "#374151"
      b.style.background = "#1F2937"
      b.style.color = "#6b7280"
    })

    btn.style.borderColor = "#6C4DFF"
    btn.style.background = "rgba(108,77,255,0.1)"
    btn.style.color = "#f3f4f6"

    this.challengeTypeFieldTarget.value = value
  }

  customDuration(event) {
    this.durationInputTarget.value = event.currentTarget.value
    this.updateSummary()
  }

  selectSuggestion(event) {
    const btn = event.currentTarget
    const titleField = this.element.querySelector("[data-field='title']")
    titleField.value = btn.dataset.title
    if (btn.dataset.days) {
      this.durationInputTarget.value = btn.dataset.days
      // Highlight matching duration button
      this.element.querySelectorAll("[data-duration-btn]").forEach(b => {
        b.style.borderColor = "#374151"
        b.style.background = "#1F2937"
        b.style.color = "#6b7280"
        if (b.dataset.days === btn.dataset.days) {
          b.style.borderColor = "#6C4DFF"
          b.style.background = "rgba(108,77,255,0.1)"
          b.style.color = "#f3f4f6"
        }
      })
      this.durationCustomTarget.style.display = "none"
    }
    this.updateSummary()
  }
}
