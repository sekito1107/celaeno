import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['card'];
  static values = {
    isOpponent: Boolean,
    gameId: String,
  };

  connect() {
    // Only animate for the owner's hand to avoid excessive animations for opponent (unless desired)
    // Actually user requirement implies "Draw Animation" which generally means "I drew a card".
    // Let's support both but maybe tune it.

    // Key unique to this game and this hand (player vs opponent)
    const storageKey = this._getStorageKey();

    const currentCardIds = this.cardTargets
      .map((el) => el.dataset.cardId)
      .filter((id) => id);
    const storedIds = this._getStoredIds(storageKey);

    if (Array.isArray(storedIds)) {
      // Find new cards (present in current but not in stored)
      const newCardIds = currentCardIds.filter((id) => !storedIds.includes(id));

      newCardIds.forEach((id) => {
        const cardEl = this.cardTargets.find((el) => el.dataset.cardId === id);
        if (cardEl) {
          this.animateDraw(cardEl);
        }
      });
    } else {
      // First load (or cleared cache) - do not animate existing cards
      // Just save state
    }

    // Save current state
    sessionStorage.setItem(storageKey, JSON.stringify(currentCardIds));
    this._initialLoadComplete = true;
  }

  // No longer used for detection, but kept if we need individual callbacks
  cardTargetConnected(element) {
    if (this._initialLoadComplete) {
      this._processNewCard(element);
    }
  }

  _processNewCard(cardEl) {
    const id = cardEl.dataset.cardId;
    if (!id) return;

    const storageKey = this._getStorageKey();
    const storedIds = this._getStoredIds(storageKey);

    if (storedIds) {
      // If it's not in the stored list (newly added), add it and animate
      if (!storedIds.includes(id)) {
        this.animateDraw(cardEl);
        storedIds.push(id);
        sessionStorage.setItem(storageKey, JSON.stringify(storedIds));
      }
    } else {
      // If no storage (first load or cleared), unlikely to animate single new card unless logic changes.
      // But for consistency let's update storage
      const currentCardIds = this.cardTargets
        .map((el) => el.dataset.cardId)
        .filter((pid) => pid);
      sessionStorage.setItem(storageKey, JSON.stringify(currentCardIds));
    }
  }

  _getStorageKey() {
    return `hand_cards_${this.gameIdValue}_${this.isOpponentValue ? 'opponent' : 'player'}`;
  }

  _getStoredIds(key) {
    const json = sessionStorage.getItem(key);
    try {
      return json ? JSON.parse(json) : null;
    } catch {
      return null;
    }
  }

  animateDraw(cardElement) {
    // Find the deck element
    // Player deck: inside .play-mat (but not .play-mat-opponent) -> .field-deck-area
    // Opponent deck: inside .play-mat-opponent -> .field-deck-area

    let deckSelector = '.play-mat:not(.play-mat-opponent) .field-deck-area';
    if (this.isOpponentValue) {
      deckSelector = '.play-mat-opponent .field-deck-area';
    }

    // Deck Selector within the same game board (closest .game-board or similar container if exists, else global fallback)
    // Assuming .game-board wraps the entire game view
    const gameBoard = this.element.closest('.game-board') || document;
    const deck = gameBoard.querySelector(deckSelector);
    if (!deck) {
      console.warn(
        'Deck element not found for animation selector:',
        deckSelector
      );
      return;
    }

    const deckRect = deck.getBoundingClientRect();
    const cardRect = cardElement.getBoundingClientRect();

    // Calculate center-to-center delta
    const deckCenterX = deckRect.left + deckRect.width / 2;
    const deckCenterY = deckRect.top + deckRect.height / 2;

    const cardCenterX = cardRect.left + cardRect.width / 2;
    const cardCenterY = cardRect.top + cardRect.height / 2;

    const deltaX = deckCenterX - cardCenterX;
    const deltaY = deckCenterY - cardCenterY;

    // Animate using Web Animations API
    // Ensure z-index is high during animation so it flies over other elements
    const keyframes = [
      {
        transform: `translate(${deltaX}px, ${deltaY}px) scale(0.2) rotate(180deg)`,
        opacity: 0,
        zIndex: 100,
      },
      {
        transform: `translate(${deltaX * 0.1}px, ${deltaY * 0.1}px) scale(1.1) rotate(5deg)`,
        opacity: 1,
        zIndex: 100,
        offset: 0.7,
      },
      {
        transform: `translate(0, 0) scale(1) rotate(0deg)`,
        opacity: 1,
        zIndex: 'auto',
      },
    ];

    const animation = cardElement.animate(keyframes, {
      duration: 1200, // Slower duration as requested
      easing: 'cubic-bezier(0.2, 0.8, 0.2, 1)',
      fill: 'forwards',
    });

    // Explicitly set z-index on element style during animation if keyframes don't handle it well in all browsers
    cardElement.style.zIndex = '100';
    animation.onfinish = () => {
      cardElement.style.zIndex = '';
    };
  }
}
