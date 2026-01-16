module Lobby
  class GameModeCardComponent < ViewComponent::Base
    def initialize(title:, description:, image_path:, action_text:, badge: "CASUAL")
      @title = title
      @description = description
      @image_path = image_path
      @action_text = action_text
      @badge = badge
    end

    private

    attr_reader :title, :description, :image_path, :action_text, :badge
  end
end
