// import { PageTitle } from 'sharedlibrary'
import router from '@ohos.router'
import { middleRate } from '../../stylesConfig/sharedTransition'
import { PageTitle } from '../components/PageTitle'
import { SharedElePageA } from './SharedElePageA'

@Entry
@Component
struct SharedElePageB {
  detail = router.getParams() as SharedElePageA['infoArr'][0]

  build() {
    Column() {
      PageTitle({ title: this.detail.title })

      Column() {
        Image(this.detail.imgUrl)
          .width(30)
          .height(30)
          .sharedTransition(this.detail.id, { ...middleRate })

        Text(this.detail.description)
          .fontSize(18)
      }
      .margin({ top: 18 })
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .padding(16)
    .height('100%')
  }
}