require "rails_helper"

RSpec.describe MatchmakingChannel, type: :channel do
  let(:user) { create(:user) }
  let(:session_record) { user.sessions.create! }

  before do
    # cookies.signed[:session_id] をシミュレートするためにスタブ化
    # channel spec では stub_connection や cookies の扱いが通常と少し異なる場合があるが
    # ここでは connection.rb のロジックを通すために接続時の認証をテストする

    # 接続のセットアップ
    stub_connection current_user: user
  end

  it "ユーザーのストリームを購読すること" do
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(user)
  end

  it "購読解除時にマッチングから離脱すること" do
    subscribe
    expect(user).to receive(:leave_matchmaking!)
    unsubscribe
  end
end
