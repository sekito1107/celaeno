class ResolvePhase
  include Interactor::Organizer

  # 1. PaySpellCosts: スペルのコストのみ支払う
  # 2. ResolveSpells: スペル効果の発動
  # 3. ProcessDeaths: スペルによる死亡処理
  # 4. PayUnitCosts: ユニットのコストを支払う
  # 5. RevealCards: ユニットの公開・登場（召喚時効果）
  # 6. TriggerRoundStartEffects: ラウンド開始時効果
  # 7. ExecuteCombat: 戦闘処理
  # 8. ProcessDeaths: 戦闘による死亡処理
  # 9. ProcessStatusEffects: 状態異常処理
  # 10. TriggerRoundEndEffects: ラウンド終了時効果（墓地効果を含む）
  organize PaySpellCosts,
           ResolveSpells,
           ProcessDeaths,
           PayUnitCosts,
           RevealCards,
           TriggerRoundStartEffects,
           ExecuteCombat,
           ProcessDeaths,
           ProcessStatusEffects,
           TriggerRoundEndEffects
end
