import router from '@ohos.router'
import { PageTitle } from '../components/PageTitle'

@Entry
@Component
struct GridRowGridCol {
  @State routeTitle: string = router.getParams()['title']
  @State colors: Color[] = [Color.Green, Color.Blue, Color.Brown, Color.Gray, Color.Orange, Color.Pink, Color.Red, Color.Yellow]

  build() {
    Column() {
      PageTitle({ title: this.routeTitle })

      GridRow({ columns: { xs: 1, sm: 2, md: 4, lg: 6 }, gutter: { x: 10, y: 15 } }) {
        ForEach(this.colors, (color, index) => {
          GridCol() {
            Row() {
              Text(`${index}`)
                .fontColor(Color.White)
            }
            .width('100%')
            .height(50)
            .backgroundColor(color)
          }
        })
      }
      .layoutWeight(1)
      .width('100%')
      .margin({top: 18})
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}