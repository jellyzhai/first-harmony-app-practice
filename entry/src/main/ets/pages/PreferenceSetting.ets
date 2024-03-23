import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import { PageTitle } from '../components/PageTitle'
import { PreferenceName, userPreference } from '../model/UserPreference'

@Entry
@Component
struct PreferenceSetting {
  preference: preferences.Preferences
  colorConfig = {
    [Color.Black]: '黑',
    [Color.Blue]: '蓝',
    [Color.Green]: '绿',
  }
  @State routeTitle: string = router.getParams()['title']
  @State showSetting: boolean = false
  @State message: string = 'Hello World'
  @State fontSize: number = 16
  @State fontColor: string | Color = Color.Black

  aboutToAppear() {
    this.preference = userPreference.preferenceMap?.get(PreferenceName.FirstPreference)
    this.preference?.get('fontColor', this.fontColor, (error, value: Color) => {
      if (!error) {
        this.fontColor = value
      }
    })
    this.preference?.get('fontSize', this.fontSize, (error, value: Color) => {
      if (!error) {
        this.fontSize = value
      }
    })
  }

  build() {
    Column({ space: '20px' }) {
      PageTitle({ title: this.routeTitle })
        .margin({ bottom: 10 })

      Column({ space: '16px' }) {
        Text(this.message)
          .fontSize(this.fontSize)
          .fontColor(this.fontColor)

        Text('设置(点击试试)')
          .fontSize(this.fontSize)
          .fontColor(this.fontColor)
          .onClick(() => {
            this.showSetting = true
          })

        if (this.showSetting) {
          Column() {
            Column() {
              Row() {
                Text('关闭')
                  .onClick(() => this.showSetting = false)
              }
              .width('100%')
              .justifyContent(FlexAlign.End)

              Row() {
                Text(`字体大小：${this.fontSize}`)
                Slider({
                  value: this.fontSize,
                  min: 16,
                  max: 28,
                  step: 4,
                })
                  .showSteps(true)
                  .showTips(true)
                  .layoutWeight(1)
                  .onChange(value => {
                    this.fontSize = value
                    this.preference?.put('fontSize', this.fontSize, (error) => {
                      if (!error) {
                        this.preference?.flush()
                      }
                    })
                  })
              }
              .justifyContent(FlexAlign.SpaceBetween)

              Row() {
                Text(`字体颜色：${this.colorConfig[this.fontColor]}`)
                Blank()
                Row() {
                  ForEach(Object.keys(this.colorConfig), (color: string) => {
                    Radio({ value: color, group: 'color' })
                      .margin({ left: 20 })
                      .checked(this.fontColor === color)
                      .onChange(checked => {
                        if (checked) {
                          this.fontColor = color
                          this.preference?.put('fontColor', this.fontColor, (error) => {
                            if (!error) {
                              this.preference?.flush()
                            }
                          })
                        }
                      })
                  })
                }
              }
              .width('100%')
            }
            .backgroundColor(Color.White)
            .margin(10)
            .padding(10)
            .borderRadius(5)
            .justifyContent(FlexAlign.End)
          }
          .width('100%')
          .height('100%')
          .borderRadius(8)
          .position({ x: 0, y: 0 })
          .justifyContent(FlexAlign.End)
          .backgroundColor('rgba(0,0,0,0.1)')
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}