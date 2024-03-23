import router from '@ohos.router'
import { PageTitle } from '../components/PageTitle'

@Entry
@Component
struct FlexLayout {
  @State routeTitle: string = router.getParams()['title']
  @State colors: Color[] = [
  Color.Blue,
  Color.Brown,
  Color.Gray,
  Color.Green,
  Color.Orange,
  Color.Pink,
  Color.Red,
  ]

  scrollerObj = new Scroller()

  build() {
    Scroll(this.scrollerObj) {
      Column() {
        PageTitle({ title: this.routeTitle })

        Flex({
          direction: FlexDirection.Column,
          wrap: FlexWrap.Wrap,
          // justifyContent: FlexAlign.SpaceEvenly,
          // alignItems: ItemAlign.Center,
          // alignContent: FlexAlign.Center
        }) {
          ForEach(this.colors, (color, index) => {
            Column() {
              Text(`${index + 1}`)
            }
            .backgroundColor(color)
            .width(100)
            .flexBasis('auto')
            // .flexShrink(1)
            .flexGrow(1)
            .height(200)
          })
        }
        .height(450)
        .width('100%')
        .border({ width: 1, radius: 10 })

        Flex({
          wrap: FlexWrap.Wrap,
          // justifyContent: FlexAlign.SpaceEvenly,
          // alignItems: ItemAlign.Center,
          // alignContent: FlexAlign.Center // 整体内容交叉轴布局方式
        }) {
          ForEach(this.colors, (color, index) => {
            Column() {
              Text(`${index + 1}`)
            }
            .backgroundColor(color)
            .width(100)
            .flexBasis('auto')
            .flexShrink(1)
            .height(200)
          })
        }
        .height(450)
        .width('100%')
        .border({ width: 1, radius: 10 })
      }
      .width('100%')
      .padding(16)
    }
    .scrollable(ScrollDirection.Vertical) // 默认值
    .scrollBarWidth(8)
    .edgeEffect(EdgeEffect.Spring) // 弹簧效果
    // .scrollBar(BarState.On) // 默认 BarState.Auto
    // .scrollBarColor(Color.Gray)
    .width('100%')
    .height('100%')
    .onScrollStart(() => {
      console.log('开始滚动');
    })
    .onScrollStop(() => {
      console.log('停止滚动')
    })
    .onScrollEdge(() => {
      console.log('滚动到边缘')
    })
  }
}