import router from '@ohos.router'

@Component
export struct PageTitle {
  title: string = 'Page Title'

  build() {
    Stack() {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      Row() {
        Image($r('app.media.ic_public_back'))
          .width(20)
          .height(20)
          .fillColor(Color.Blue)
      }
      .width('100%')
      .padding(0)
      .onClick(() => {
        router.back()
      })
    }
    .width('100%')
  }
}