require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { create(:user) }
  let(:session_record) { user.sessions.create! }

  context "有効なセッションの場合" do
    it "接続に成功すること" do
      cookies.signed[:session_id] = session_record.id
      connect "/cable"
      expect(connection.current_user).to eq(user)
    end
  end

  context "有効なセッションがない場合" do
    it "接続を拒否すること" do
      cookies.signed[:session_id] = nil
      expect { connect "/cable" }.to have_rejected_connection
    end
  end

  context "セッションIDが無効な場合" do
    it "接続を拒否すること" do
      cookies.signed[:session_id] = "invalid_id"
      expect { connect "/cable" }.to have_rejected_connection
    end
  end
end
