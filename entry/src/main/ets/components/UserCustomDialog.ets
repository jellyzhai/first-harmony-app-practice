@CustomDialog
struct UserCustomDialog {
  // 直接声明属性，就可以在当前组件中使用，必须要写的属性
  controller: CustomDialogController
  title: string = ''
  score: number = 0
  @StorageLink('maxScoreRecord') maxScoreRecord: number = 0
  @BuilderParam contentBuilder: () => any
  confirmText: string = 'Confirm'
  cancelText: string = 'Cancel'
  cancel: () => void
  confirm: () => void
  actionButtons: Array<{
    text: string;
    action: () => void
  }> = []

  build() {
    Column({ space: 15 }) {
      if (this.title) {
        Text(this.title)
          .fontWeight(FontWeight.Bold)
      }

      if (this.contentBuilder) {
        // 不能设置宽度
        this.contentBuilder()
      }

      if (this.actionButtons.length) {
        Row() {
          ForEach(this.actionButtons, (button: UserCustomDialog['actionButtons'][number]) => {
            Button(button.text)
              .onClick(() => {
                button.action()
                this.controller.close()
              })
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
      }
    }
    .padding(15)
  }
}

export default UserCustomDialog