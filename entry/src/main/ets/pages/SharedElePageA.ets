// import { PageTitle } from 'sharedlibrary'
import router from '@ohos.router'
import { middleRate } from '../../stylesConfig/sharedTransition'
import { PageTitle } from '../components/PageTitle'

@Entry
@Component
struct SharedElePageA {
  @State routeTitle: string = router.getParams()['title']
  infoArr = [
    {
      id: 'earth',
      imgUrl: $r('app.media.earth'),
      title: 'earth detail',
      description: 'this is earth detail'
    },
    {
      id: 'monica',
      imgUrl: $r('app.media.monica'),
      title: 'monica detail',
      description: 'this is monica detail'
    }
  ]

  build() {
    Column() {
      PageTitle({ title: this.routeTitle })

      List({ space: 15 }) {
        ForEach(this.infoArr, (item: SharedElePageA['infoArr'][0]) => {
          ListItem() {
            Row() {
              Image(item.imgUrl)
                .width(25)
                .height(25)
                .margin({ right: 8 })
                .sharedTransition(item.id, { ...middleRate })

              Text(item.title)
                .fontSize(18)
                .fontColor(Color.Blue)
            }
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/SharedElePageB',
              params: item
            })
          })
        })
      }
      .margin({ top: 18 })
    }
    .padding(16)
    .width('100%')
    .height('100%')
  }
}

export {
  SharedElePageA
}
