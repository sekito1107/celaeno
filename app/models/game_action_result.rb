class GameActionResult < Data.define(:success, :message, :phase_completed)
  def initialize(success:, message:, phase_completed: false)
    super
  end

  def success?
    success
  end

  def self.success(message:, phase_completed: false)
    new(success: true, message: message, phase_completed: phase_completed)
  end

  def self.failure(message:)
    new(success: false, message: message)
  end
end
