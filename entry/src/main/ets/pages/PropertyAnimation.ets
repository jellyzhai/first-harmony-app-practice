import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { PageTitle } from '../components/PageTitle'

@Entry
@Component
struct PropertyAnimation {
  @State routeTitle: string = router.getParams()['title']
  @State bgc: Color | string = '#FF007DFF'
  @State opacityNum: number = 1
  @State translateOpt: TranslateOptions = { x: 0, y: 0 }
  @State rotateOpt: RotateOptions = { angle: 360 }
  @State scaleOpt: ScaleOptions = { x: 1, y: 1 }
  isClicked: boolean = false
  @State showImg: boolean = true

  build() {
    Column() {
      PageTitle({ title: this.routeTitle })

      Column() {
        Button('点我试试')
          .backgroundColor(this.bgc)
          .opacity(this.opacityNum)
          .scale(this.scaleOpt)
          .rotate(this.rotateOpt)
          .translate(this.translateOpt)
          .onClick((event) => {
            console.log(JSON.stringify(event))
            this.scaleOpt = JSON.stringify(this.scaleOpt) === JSON.stringify({ x: 1, y: 1 })
              ? { x: 1.5, y: 1.5 } : { x: 1, y: 1 }
            this.rotateOpt = this.rotateOpt.angle === 360 ? { angle: -360 } : { angle: 360 }
            this.translateOpt = this.translateOpt.x === 0 ? { x: 50, y: 50 } : { x: 0, y: 0 }
            this.opacityNum = this.opacityNum === 1 ? 0.5 : 1
            this.bgc = this.bgc === Color.Brown ? '#FF007DFF' : Color.Brown

            this.isClicked = true
          })
          .animation({
            duration: 1000,
            curve: Curve.Sharp,
            playMode: PlayMode.Alternate,
            onFinish: () => {
              if (this.isClicked) {
                promptAction.showToast({ message: '属性动画结束', bottom: 500 })
              }
            }
          })

        Divider()

        AnimateToComp()

        Divider()

        Button('点击查看组件删除/插入过度动画')
          .onClick(() => {
            animateTo({ duration: 1000, curve: Curve.LinearOutSlowIn }, () => {
              this.showImg = !this.showImg
            })
          })

        if (this.showImg) {
          Image($r('app.media.monica'))
            .width(30)
            .height(30)
            .transition({
              type: TransitionType.All,
              // 写组件消失的动画终点属性
              scale: { x: 0, y: 0 },
              rotate: { angle: 360 }
            })
        }
      }
      .width('100%')
      .layoutWeight(1)
      .margin({ top: 18 })
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}

@Component
struct AnimateToComp {
  @State routeTitle: string = router.getParams()['title']
  @State bgc: Color | string = '#FF007DFF'
  @State opacityNum: number = 1
  @State translateOpt: TranslateOptions = { x: 0, y: 0 }
  @State rotateOpt: RotateOptions = { angle: 360 }
  @State scaleOpt: ScaleOptions = { x: 1, y: 1 }
  isClicked: boolean = false

  build() {

    Button('再点我试试')
      .backgroundColor(this.bgc)
      .opacity(this.opacityNum)
      .scale(this.scaleOpt)
      .rotate(this.rotateOpt)
      .translate(this.translateOpt)
      .onClick(() => {
        animateTo({
          duration: 1000,
          curve: Curve.ExtremeDeceleration,
          onFinish: () => {
            if (this.isClicked) {
              promptAction.showToast({ message: '属性动画结束', bottom: 500 })
            }
          }
        }, () => {
          this.scaleOpt = JSON.stringify(this.scaleOpt) === JSON.stringify({ x: 1, y: 1 })
            ? { x: 1.5, y: 1.5 } : { x: 1, y: 1 }
          this.rotateOpt = this.rotateOpt.angle === 360 ? { angle: -360 } : { angle: 360 }
          this.translateOpt = this.translateOpt.x === 0 ? { x: 50, y: 50 } : { x: 0, y: 0 }
          this.opacityNum = this.opacityNum === 1 ? 0.5 : 1
          this.bgc = this.bgc === Color.Brown ? '#FF007DFF' : Color.Brown
        })

        this.isClicked = true
      })

  }
}