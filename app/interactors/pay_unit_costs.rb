class PayUnitCosts
  include Interactor

  def call
    return if context.game.finished?

    result = PayResolvePhaseCosts.call(context.to_h.merge(target_card_types: [ :unit ]))

    if result.pending_costs
      context.pending_costs ||= {}
      context.pending_costs.merge!(result.pending_costs)
    end
  end
end
