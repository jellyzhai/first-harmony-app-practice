import router from '@ohos.router'
import common from '@ohos.app.ability.common'
import { PageTitle } from '../components/PageTitle'
import Want from '@ohos.app.ability.Want'

// 4.0系统真机中无法实现持久化功能
// PersistentStorage.PersistProp('docArray', [])

@Entry
@Component
struct DocumentList {
  @State routeTitle: string = router.getParams()['title']
  @StorageLink('docArray') numbers: number[] = []
  @State count: number = 0
  context = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.count = this.numbers.length
  }

  build() {
    Column({ space: 10 }) {
      PageTitle({ title: this.routeTitle })

      Text('新建文档')
        .fontColor($r('app.color.harmony_blue'))
        .onClick(() => {
          this.numbers.push(++this.count)
          const want: Want = {
            bundleName: 'com.example.myapplication',
            moduleName: 'entry',
            abilityName: 'DocumentAbility',
            parameters: {
              /*
               * 用于区分，不同文档打开对应不同的文档编辑 ability，
               * 下次再去打开相同文档时，可以进入到匹配 instanceKey 的 ability
               * */
              instanceKey: this.count
            }
          }

          this.context.startAbility(want)
        })

      List({ space: 8 }) {
        ForEach(this.numbers, (item) => {
          ListItem() {
            Text('文档' + item)
              .fontColor($r('app.color.harmony_blue'))
              .onClick(() => {
                const want: Want = {
                  bundleName: 'com.example.myapplication',
                  moduleName: 'entry',
                  abilityName: 'DocumentAbility',
                  parameters: {
                    instanceKey: item
                  }
                }

                this.context.startAbility(want)
              })
          }
        })
      }
      .width('100%')
      .height('auto')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}