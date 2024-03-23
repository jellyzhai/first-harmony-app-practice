import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { PageTitle } from '../components/PageTitle'

/*
 * 标题的mini模式，适合需要有返回按钮的页面组件
 * 其他模式，适用于平板宽屏布局模式，例如平板中的设置页面
 * */

@Entry
@Component
struct NavigationLayout {
  @State routeTitle: string = router.getParams()['title']
  @State currentIndex: number = 0

  arr: number[] = [1, 2, 3]
  menuConfig: NavigationMenuItem[] = [
    {
      icon: '/entry/src/main/resources/base/media/earth.png',
      value: '菜单项1',
      action: () => {
        promptAction.showToast({message: '点击了菜单项1'})
      }
    },
    {
      icon: '../../resources/base/media/icon.png',
      value: '菜单项2',
      action: () => {
        promptAction.showToast({message: '点击了菜单项2'})
      }
    },
    {
      icon: '../../resources/base/media/monica.png',
      value: '菜单项3',
      action: () => {
        promptAction.showToast({message: '点击了菜单项3'})
      }
    },
    {
      icon: '../../resources/base/media/select_checkbox.png',
      value: '菜单项4',
      action: () => {
        promptAction.showToast({message: '点击了菜单项4'})
      }
    },
  ]
  toolBarConfig: object = [
    {
      // icon: '../../resources/base/media/earth.png',
      value: '菜单项1',
      action: () => {
        this.currentIndex = 0
      }
    },
    {
      // icon: '../../resources/base/media/monica.png',
      value: '菜单项3',
      action: () => {
        this.currentIndex = 1
      }
    },
  ]

  build() {
    Column() {
      PageTitle({ title: this.routeTitle })

      Column() {
        Navigation() {
          TextInput({ placeholder: 'search...' })
            .width("90%")
            .height(40)
            .backgroundColor('#FFFFFF')

          List({ space: 12 }) {
            ForEach(this.arr, (item) => {
              ListItem() {
                NavRouter() {
                  Text("NavRouter" + item)
                    .width("100%")
                    .height(32)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(14)
                    .fontSize(16)
                    .fontWeight(500)
                    .textAlign(TextAlign.Center)

                  NavDestination() {
                    Text("NavDestinationContent" + item)
                  }
                  .title("NavDestinationTitle" + item)
                }
              }
            }, item => item)
          }
          .width("90%")
          .margin({ top: 12 })
        }
        .title("主标题")
        // .titleMode(NavigationTitleMode.Mini)
        .mode(NavigationMode.Split)
        .menus([
          {value: "menu1", icon: "../images/earth.png", action: ()=> {}},
          // {value: "menu2", icon: "./image/ic_public_add.svg", action: ()=> {}},
          // {value: "menu3", icon: "./image/ic_public_add.svg", action: ()=> {}},
          // {value: "menu4", icon: "./image/ic_public_add.svg", action: ()=> {}}
        ])
        // 内置配置会遮盖导航按钮的最后一个的点击
        // .toolBar({items: [
        //   {value: "func", action: ()=> {}},
        //   // {value: "func", icon: "./image/ic_public_highlights.svg", action: ()=> {}},
        //   // {value: "func", icon: "./image/ic_public_highlights.svg", action: ()=> {}}
        // ]})
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F1F3F5')
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}