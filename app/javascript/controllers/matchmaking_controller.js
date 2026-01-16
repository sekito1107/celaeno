import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static values = { 
    userId: Number,
    waitDuration: { type: Number, default: 6000 }
  }
  static targets = ["searchingState", "matchedState"]

  connect() {
    this.matched = false
    this.consumer = createConsumer()
    this.channel = this.consumer.subscriptions.create(
      { channel: "MatchmakingChannel" },
      { received: this.handleMessage.bind(this) }
    )
  }

  disconnect() {
    this.channel?.unsubscribe()
    this.consumer?.disconnect()
    if (this.redirectTimeoutId) clearTimeout(this.redirectTimeoutId)
  }

  handleMessage(data) {
    if (data.action === "matched" && !this.matched) {
      this.matched = true
      this.triggerEncounterAnimation()
      
      this.redirectTimeoutId = setTimeout(() => {
        // Turboが利用可能な場合はTurbo.visitを使用、そうでなければ通常の遷移
        if (window.Turbo) {
          window.Turbo.visit(`/games/${data.game_id}`)
        } else {
          window.location.href = `/games/${data.game_id}`
        }
      }, this.waitDurationValue)
    }
  }

  triggerEncounterAnimation() {
    // コンテナ全体に match-found クラスを追加
    this.element.classList.add("match-found")

    // ステータステキストの表示切替
    if (this.hasSearchingStateTarget) {
      this.searchingStateTarget.classList.add("hidden")
    }
    
    if (this.hasMatchedStateTarget) {
      this.matchedStateTarget.classList.remove("hidden")
    }
  }
}
