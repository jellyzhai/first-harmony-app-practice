@Preview
@Entry
@Component
struct MarqueeText {
  @State start: boolean = true
  @State step: number = 50
  @State loop: number = Infinity
  @State fromStart: boolean = true
  @State src: string = 'Hello World! Stay Hungry! Stay Foolish!'
  @State imgs: {img: Resource}[] = [{img: $r('app.media.app_icon')}, {img: $r('app.media.app_icon')}]

  build() {
    Navigation() {
      Column({space: 10}) {
        Marquee({ start: this.start, src: this.src })
          .width('100%')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)

        ForEach(this.imgs, img => {
          Image(img.img)
            .width('50')
            .height('50')
        })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .titleMode(NavigationTitleMode.Mini)
    .title('Marquee Text')
  }
}