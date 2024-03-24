import AbilityStage from '@ohos.app.ability.AbilityStage';
import Want from '@ohos.app.ability.Want';

export default class MyAbilityStage extends AbilityStage {
  onAcceptWant(want: Want) {
    if (want.abilityName === 'DocumentAbility') {
      // 该 ability 为"launchType": "specified"
      // 生成返回 ability 的实例id,用于内部管理，
      // 返回的 id，如果对应着已经创建好的 ability 实例，那就直接拉起 该 ability；否则就新建 id为返回值的 ability
      return want.parameters.instanceKey + want.abilityName
    }
    return ''
  }
}