class PaySpellCosts
  include Interactor

  def call
    PayResolvePhaseCosts.call(context.to_h.merge(target_card_types: [ :spell ]))
  end
end
