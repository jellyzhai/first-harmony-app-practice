import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import { userPreference, PreferenceName } from '../model/UserPreference';
import { userRdb } from '../model/UserRdb';

export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    userPreference.getPreference(this.context, PreferenceName.FirstPreference)
    userPreference.getPreference(this.context, PreferenceName.FishGamePreference)
    userRdb.loadRdbStore(this.context)
    console.log('testTag', 'EntryAbility > onCreate > want: ', JSON.stringify(want))
  }

  onNewWant(want, launchParam) {
    console.log('testTag', 'EntryAbility > onNewWant > want: ', JSON.stringify(want))
    console.log('testTag', 'EntryAbility > onNewWant > launchParam: ', JSON.stringify(launchParam))
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }
}
