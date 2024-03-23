@Entry
@Component
struct PositionSet {

  build() {
    Navigation() {
      Column() {
        Text('绝对定位属性：position')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .backgroundColor(Color.Blue)
          .position({
            x: 10,
            y: -10
          })

        Text('相对定位属性：offset')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .backgroundColor(Color.Brown)
          .offset({
            x: -20,
            y: 20
          })

        Text('markAnchor')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .backgroundColor(Color.Green)
          .markAnchor({
            // x > 0 向左偏移
            // y > 0 向上便宜
            x: 30,
            y: -20
          })
      }
      .width('100%')
      .height('100%')
    }
    .titleMode(NavigationTitleMode.Mini)
    .title('position/offset/markAnchor')
    .hideToolBar(true)
  }
}