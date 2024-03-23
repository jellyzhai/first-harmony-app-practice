import common from '@ohos.app.ability.common'
import Want from '@ohos.app.ability.Want'
import { PageTitle } from '../components/PageTitle'

@Entry
@Component
struct DocumentEditor {
  @State isEditable: boolean = true
  @State docTemporaryTitle: string = ''
  @State docTitle: string = '文档标题'
  @State docContent: string = '请输入文档内容'
  titleInputId: string = Date.now().toString()
  context = getContext(this) as common.UIAbilityContext
  backFunc = () => {
    const want: Want = {
      bundleName: 'com.example.myapplication',
      moduleName: 'entry',
      abilityName: 'EntryAbility'
    }

    this.context.startAbility(want)
  }

  build() {
    Column({ space: 10 }) {
      PageTitle({ title: '文档编辑', parentBackFunc: this.backFunc })

      Column({ space: 10 }) {
        if (this.isEditable) {
          Row() {
            TextInput({ text: this.docTitle })
              .id(this.titleInputId)
              .fontWeight(FontWeight.Bold)
              .fontSize(20)
              .backgroundColor(Color.White)
              .layoutWeight(1)
              .onAppear(() => {
                // focusControl.requestFocus(this.titleInputId)
              })
              .onChange(value => {
                this.docTemporaryTitle = value
              })
            Button('确定')
              .onClick(() => {
                this.isEditable = false
                this.docTitle = this.docTemporaryTitle
              })
          }
          // .width('100%')
          // .justifyContent(FlexAlign.End)
        } else {
          Text(this.docTitle)
            .fontWeight(FontWeight.Bold)
            .fontSize(20)
            .onClick(() => {
              this.isEditable = true
            })
        }

        TextArea({ placeholder: this.docContent })
          .backgroundColor(Color.White)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
