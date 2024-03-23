import router from '@ohos.router'

interface RouteItem {
  name: string;
  url: string;
}

@Entry
@Component
struct Index {
  @State routes: RouteItem[] = [
    {
      name: '路由页面间共享元素转场动画',
      url: 'pages/SharedElePageA'
    },
    {
      name: '组件属性变化素的属性动画',
      url: 'pages/PropertyAnimation'
    },
    {
      name: 'Tabs页签布局',
      url: 'pages/TabsLayout'
    },
    {
      name: 'GridRowGridCol页签布局',
      url: 'pages/GridRowGridCol'
    },
    {
      name: 'Scroll/FlexLayout布局',
      url: 'pages/FlexLayout'
    },
    {
      name: 'Navigation 布局',
      url: 'pages/Navigation_NavRouter_NavDestination'
    },
    {
      name: 'RelativeContainer 布局',
      url: 'pages/RelativeContainerLayout'
    },
    {
      name: 'position/offset/markAnchor',
      url: 'pages/PositionSet'
    },
    {
      name: 'MarqueeText',
      url: 'pages/MarqueeText'
    },
    {
      name: 'http',
      url: 'pages/HttpRequest'
    },
    {
      name: 'axios',
      url: 'pages/AxiosRequest'
    },
    {
      name: '首选项设置-本地存储',
      url: 'pages/PreferenceSetting'
    },
    {
      name: '关系型数据库-本地存储',
      url: 'pages/RelationalDataBase'
    },
    {
      name: '通知',
      url: 'pages/NotificationManagerPractice'
    },
    {
      name: 'UIAbility启动模式',
      url: 'pages/DocumentList'
    },
    {
      name: '小鱼游戏动画实践',
      url: 'pages/FishGameAnimation'
    }
  ]

  build() {
    List({ space: 20 }) {
      ForEach(this.routes, (item: RouteItem, index) => {
        ListItem() {
          Text(`${index + 1}. ${item.name}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Blue)
            .onClick(() => {
              router.pushUrl({ url: item.url, params: { title: item.name } })
            })
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}