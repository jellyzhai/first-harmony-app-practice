@Entry
@Component
struct RelativeContainerLayout {
  build() {
    Navigation() {
      RelativeContainer() {
        Row() {
          Text('row1')
        }
        .width(100)
        .height(100)
        .backgroundColor(Color.Blue)
        .id('row1')

        Row() {
          Text('row2')
        }
        .width(100)
        .height(100)
        .backgroundColor(Color.Brown)
        .alignRules({
          right: {
            anchor: '__container__', align: HorizontalAlign.End
          }
        })
        .id('row2')

        Row() {
          Text('row3')
        }
        .width(100)
        .height(100)
        .backgroundColor(Color.Green)
        .alignRules({
          // row3 的顶部 top, 位于锚点 row2 的 底部bottom
          top: { anchor: 'row2', align: VerticalAlign.Bottom },
          // row3 的右侧位置 right, 位于锚点 row2 的 左侧开始 start
          right: { anchor: 'row2', align: HorizontalAlign.Start },
        })
        .id('row3')

        Row() {
          Text('row4')
        }
        .width(100)
        .height(100)
        .backgroundColor(Color.Orange)
        .alignRules({
          top: { anchor: 'row3', align: VerticalAlign.Bottom },
          right: { anchor: 'row3', align: HorizontalAlign.Start },
        })
        .id('row4')

        Row() {
          Text('row5')
        }
        .width(100)
        .height(100)
        .backgroundColor(Color.Red)
        .alignRules({
          top: { anchor: 'row3', align: VerticalAlign.Bottom },
          left: { anchor: 'row3', align: HorizontalAlign.End },
        })
        .id('row5')
      }
      .width(300)
      .height(300)
      .backgroundColor(Color.Gray)
      .borderRadius(10)
      .clip(true)
    }
    .backgroundColor(Color.Pink)
    .titleMode(NavigationTitleMode.Mini)
    .title('RelativeContainer 布局')
  }
}