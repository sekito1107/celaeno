class PayUnitCosts
  include Interactor

  def call
    return if context.game.finished?

    PayResolvePhaseCosts.call(context.to_h.merge(target_card_types: [ :unit ]))
  end
end
