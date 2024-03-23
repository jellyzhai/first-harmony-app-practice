import AbilityStage from '@ohos.app.ability.AbilityStage';
import Want from '@ohos.app.ability.Want';

export default class MyAbilityStage extends AbilityStage {
  onAcceptWant(want: Want) {
    if (want.abilityName === 'DocumentAbility') {
      return want.parameters.instanceKey + want.abilityName
    }
    return ''
  }
}