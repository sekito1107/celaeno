class PlayCard
  include Interactor::Organizer

  organize ValidatePlay, CreateMove, ProcessCardMovement, TriggerPlayEffect

  around do |organizer_block|
    ActiveRecord::Base.transaction do
      organizer_block.call
    end
  end
end
