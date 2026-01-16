require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "renders the landing page successfully" do
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("CALL OF CELEANO")
      expect(response.body).to include("プレアデス星団の彼方へ")
      expect(response.body).to include('href="/assets/home') # Verifies stylesheet link
    end

    it "allows unauthenticated access" do
      # Ensure no redirect to login
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end
end
