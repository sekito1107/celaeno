require 'rails_helper'

RSpec.describe User, type: :model do
  # ===========================================
  # バリデーション
  # ===========================================
  describe 'バリデーション' do
    describe 'name' do
      it '必須であること' do
        user = build(:user, name: nil)
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include("can't be blank")
      end
    end

    describe 'email_address' do
      it '必須であること' do
        user = build(:user, email_address: nil)
        expect(user).not_to be_valid
        expect(user.errors[:email_address]).to include("can't be blank")
      end

      it '一意であること' do
        create(:user, email_address: 'test@example.com')
        user = build(:user, email_address: 'test@example.com')
        expect(user).not_to be_valid
        expect(user.errors[:email_address]).to include('has already been taken')
      end

      it '大文字小文字を区別せずに一意であること' do
        create(:user, email_address: 'test@example.com')
        user = build(:user, email_address: 'TEST@EXAMPLE.COM')
        expect(user).not_to be_valid
      end

      it '正しいフォーマットであること' do
        invalid_emails = [ 'invalid', 'invalid@', '@example.com', 'user@.com' ]
        invalid_emails.each do |email|
          user = build(:user, email_address: email)
          expect(user).not_to be_valid, "#{email} should be invalid"
        end
      end

      it '正しいフォーマットを許可すること' do
        valid_emails = [ 'user@example.com', 'user+tag@example.com', 'user.name@example.co.jp' ]
        valid_emails.each do |email|
          user = build(:user, email_address: email)
          expect(user).to be_valid, "#{email} should be valid"
        end
      end
    end

    describe 'password' do
      it '8文字以上であること' do
        user = build(:user, password: 'short')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('is too short (minimum is 8 characters)')
      end

      it '8文字以上なら有効であること' do
        user = build(:user, password: 'validpass')
        expect(user).to be_valid
      end
    end
  end

  # ===========================================
  # 正規化
  # ===========================================
  describe 'email_addressの正規化' do
    it '小文字に変換されること' do
      user = create(:user, email_address: 'TEST@EXAMPLE.COM')
      expect(user.email_address).to eq('test@example.com')
    end

    it '前後の空白が除去されること' do
      user = create(:user, email_address: '  test@example.com  ')
      expect(user.email_address).to eq('test@example.com')
    end
  end

  # ===========================================
  # 認証
  # ===========================================
  describe '認証' do
    let!(:user) { create(:user, email_address: 'auth@example.com', password: 'password123') }

    describe '.authenticate_by' do
      it '正しい認証情報でユーザーを返すこと' do
        result = User.authenticate_by(email_address: 'auth@example.com', password: 'password123')
        expect(result).to eq(user)
      end

      it '間違ったパスワードでnilを返すこと' do
        result = User.authenticate_by(email_address: 'auth@example.com', password: 'wrongpassword')
        expect(result).to be_nil
      end

      it '存在しないメールアドレスでnilを返すこと' do
        result = User.authenticate_by(email_address: 'nonexistent@example.com', password: 'password123')
        expect(result).to be_nil
      end
    end
  end

  # ===========================================
  # セッション関連
  # ===========================================
  describe 'sessionsアソシエーション' do
    let(:user) { create(:user) }

    it 'セッションを持てること' do
      session = user.sessions.create!(user_agent: 'Test Agent', ip_address: '127.0.0.1')
      expect(user.sessions).to include(session)
    end

    it 'ユーザー削除時にセッションも削除されること' do
      user.sessions.create!(user_agent: 'Test Agent', ip_address: '127.0.0.1')
      expect { user.destroy }.to change(Session, :count).by(-1)
    end
  end

  # ===========================================
  # 削除時の挙動
  # ===========================================
  describe '削除時の挙動' do
    let!(:user) { create(:user) }

    context 'アクティブなゲームに参加していない場合' do
      it '削除できること' do
        expect { user.destroy }.to change(User, :count).by(-1)
      end
    end

    context '終了したゲームに参加している場合' do
      let(:game) { create(:game, status: :finished) }
      let!(:game_player) { create(:game_player, user: user, game: game) }

      it '削除できること' do
        expect { user.destroy }.to change(User, :count).by(-1)
      end
    end

    context 'マッチング中のゲームに参加している場合' do
      let(:game) { create(:game, status: :matching) }
      let!(:game_player) { create(:game_player, user: user, game: game) }

      it '削除できず、エラーが追加されること' do
        expect { user.destroy }.not_to change(User, :count)
        expect(user.errors[:base]).to include("アクティブなゲームに参加中のユーザーは削除できません")
      end
    end

    context 'プレイ中のゲームに参加している場合' do
      let(:game) { create(:game, status: :playing) }
      let!(:game_player) { create(:game_player, user: user, game: game) }

      it '削除できず、エラーが追加されること' do
        expect { user.destroy }.not_to change(User, :count)
        expect(user.errors[:base]).to include("アクティブなゲームに参加中のユーザーは削除できません")
      end
    end
  end
end
