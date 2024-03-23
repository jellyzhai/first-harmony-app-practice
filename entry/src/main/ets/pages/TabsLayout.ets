import router from '@ohos.router'
import { PageTitle } from '../components/PageTitle'

@Entry
@Component
struct TabsLayout {
  @State routeTitle: string = router.getParams()['title']
  @State currentIndex: number = 0
  @State leftBarCurrentIndex: number = 0
  @State leftBarCurrentColor: string | Color = Color.White
  @State leftBarSelectedColor: string | Color = Color.Blue
  tabsController = new TabsController()

  @Builder TabsTextTopBar() {
    Tabs({ barPosition: BarPosition.Start }) {
      TabContent() {
        Text('left content')
      }
      .tabBar('left')
      .backgroundColor(Color.Pink)

      TabContent() {
        Text('right content')
      }
      .tabBar('right')
      .backgroundColor(Color.Pink)
    }
    .width('100%')
  }

  @Builder CustomLeftBar(index: number, iconUrl: Resource, text: string) {
    Column() {
      Image(this.leftBarCurrentIndex === index ? $r('app.media.select_checkbox') : iconUrl)
        .width(25)
        .height(25)
      Text(text)
        .fontSize(20)
        .fontColor(this.leftBarCurrentIndex === index ? this.leftBarSelectedColor : this.leftBarCurrentColor)
    }
  }

  @Builder TabsCustomLeftBar() {
    Tabs({ barPosition: BarPosition.Start }) {
      TabContent() {
        Text('top content')
      }
      .backgroundColor(Color.Brown)
      .tabBar(this.CustomLeftBar(0, $r('app.media.earth'), 'top'))

      TabContent() {
        Text('bottom content')
      }
      .backgroundColor(Color.Brown)
      .tabBar(this.CustomLeftBar(1, $r('app.media.monica'), 'bottom'))
    }
    .vertical(true)
    .barWidth('30%')
    .width('100%')
    .onChange(index => {
      this.leftBarCurrentIndex = index
    })
  }

  @Builder SubTabBarTabs() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        Text('this is right top').fontColor(Color.White)
      }
      .tabBar(new SubTabBarStyle('top'))
      .backgroundColor(Color.Pink)

      TabContent() {
        Text('this is right bottom').fontColor(Color.White)
      }
      .tabBar(new SubTabBarStyle('bottom'))
      .backgroundColor(Color.Pink)
    }
    .width('100%')
    .vertical(true)
    .barWidth('25%')
  }

  @Builder BottomTabBarTabs() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        Text('this is left bottom').fontColor(Color.White)
      }
      .tabBar(new BottomTabBarStyle($r('app.media.earth'), 'left'))
      .backgroundColor(Color.Green)

      TabContent() {
        Text('this is right bottom').fontColor(Color.White)
      }
      .tabBar(new BottomTabBarStyle($r('app.media.monica'), 'right'))
      .backgroundColor(Color.Green)
    }
    .width('100%')
    .vertical(false)
  }

  build() {
    Column() {
      PageTitle({ title: this.routeTitle })

      Column() {
        Tabs({ barPosition: BarPosition.End }) {
          TabContent() {
            this.TabsTextTopBar()
          }
          .backgroundColor(Color.Gray)
          .border({ radius: 10 })
          .tabBar({
            icon: this.currentIndex === 0 ? $r('app.media.select_checkbox') : $r('app.media.monica'),
            text: 'Home'
          })

          TabContent() {
            this.TabsCustomLeftBar()
          }
          .backgroundColor(Color.Grey)
          .border({ radius: 10 })
          .tabBar({
            icon: this.currentIndex === 1 ? $r('app.media.select_checkbox') : $r('app.media.icon'),
            text: 'New Goods'
          })

          TabContent() {
            this.SubTabBarTabs()
          }
          .backgroundColor('#30C')
          .border({ radius: 10 })
          .tabBar({
            icon: this.currentIndex === 2 ? $r('app.media.select_checkbox') : $r('app.media.earth'),
            text: 'Cart'
          })

          TabContent() {
            this.BottomTabBarTabs()
          }
          .backgroundColor('#35D')
          .border({ radius: 10 })
          .tabBar({
            icon: this.currentIndex === 3 ? $r('app.media.select_checkbox') : $r('app.media.app_icon'),
            text: 'My'
          })
        }
        // 默认值
        // .vertical(false)
        // 默认值
        // .scrollable(true)
        // 默认值
        // .barMode(BarMode.Fixed)
        // 默认值
        // .animationDuration(300)
        .width('100%')
        .onChange((index) => {
          this.currentIndex = index
        })
      }
      .width('100%')
      .layoutWeight(1)
      .margin({ top: 18 })
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}