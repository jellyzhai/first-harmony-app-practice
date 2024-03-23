import AbilityStage from '@ohos.app.ability.AbilityStage';
export default class MyAbilityStage extends AbilityStage {
    onAcceptWant(want) {
        if (want.abilityName === 'DocumentAbility') {
            return want.parameters.instanceKey + want.abilityName;
        }
        return '';
    }
}
//# sourceMappingURL=MyAbilityStage.js.map