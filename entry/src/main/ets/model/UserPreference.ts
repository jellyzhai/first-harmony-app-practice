import preferences from '@ohos.data.preferences'
import UIAbility from '@ohos.app.ability.UIAbility'

class UserPreference {
  preferenceMap: Map<string, preferences.Preferences> = new Map()

  getPreference(context: UIAbility['context'], name: string): Promise<preferences.Preferences> {
    return new Promise((resolve, reject) => {
      const getPreferenceError = (err) => {
        reject(err)
        console.log('testTag', 'UserPreference > 获取首选项实例失败：', JSON.stringify(err))
      }

      if (!name.trim()) {
        getPreferenceError(`设置的首选项实例的名称不是有效字符串`)
        return
      }

      if (this.preferenceMap.get(name)) {
        getPreferenceError(`设置的首选项实例的名称 ${name} 已存在`)
        return
      }

      preferences.getPreferences(context, name, (err, pref) => {
        if (err) {
          getPreferenceError(err)
          return
        }

        resolve(pref)
        this.preferenceMap.set(name, pref)
        console.log('testTag', 'UserPreference > 获取首选项实例成功！')
      })
    })
  }
}

export const userPreference = new UserPreference()

export enum PreferenceName {
  FirstPreference = 'FirstPreference',
  FishGamePreference = 'FishGamePreference',
}