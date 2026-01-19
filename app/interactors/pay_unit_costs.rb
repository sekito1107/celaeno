class PayUnitCosts
  include Interactor

  def call
    PayResolvePhaseCosts.call(context.to_h.merge(target_card_types: [ :unit ]))
  end
end
