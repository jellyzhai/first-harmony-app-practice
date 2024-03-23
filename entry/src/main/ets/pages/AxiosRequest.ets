// 本地数据服务器：https://github.com/jellyzhai/node_server
import router from '@ohos.router'
import axios from '@ohos/axios'
import { PageTitle } from '../components/PageTitle'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct AxiosRequest {
  @State routeTitle: string = router.getParams()['title']
  @State loading: boolean = true
  @State okText: string = '创建'
  @State data: Array<{
    id: string;
    name: string;
    age: number
  }> = []
  dialogCreateController: CustomDialogController
  openCreateDialog = () => {
    this.dialogCreateController = new CustomDialogController({
      builder: UpdateCreateDialog({
        okText: '创建',
        dialogController: this.dialogCreateController,
        confirm: (name: string, age: number) => {
          this.addData(name, age).then(() => {
            this.getData()
            promptAction.showToast({ message: '创建数据成功！' })
          })
        }
      })
    })
    this.dialogCreateController.open()
  }
  dialogUpdateController: CustomDialogController
  openUpdateDialog = (data: AxiosRequest['data'][number]) => {
    this.dialogUpdateController = new CustomDialogController({
      builder: UpdateCreateDialog({
        okText: '更新',
        name: data.name,
        age: data.age,
        dialogController: this.dialogUpdateController,
        confirm: (name: string, age: number) => {
          this.updateData(Object.assign(data, { name, age }))
        }
      })
    })
    this.dialogUpdateController.open()
  }
  confirmDialogController: CustomDialogController
  openConfirmDialog = (confirm: () => void) => {
    this.confirmDialogController = new CustomDialogController({
      builder: CustomConfirmDialog({
        dialogContent: this.ConfirmDialogContent,
        confirm
      })
    })
    this.confirmDialogController.open()
  }
  addData = (name: string, age: number) => {
    return axios.post('http://192.168.0.116:3000/add', {
      id: Date.now().toString(),
      name,
      age
    }).then(() => {
      this.loading = false
      promptAction.showToast({ message: '创建数据成功！' })
    }).catch(() => {
      promptAction.showToast({ message: '创建数据失败！' })
    })
  }
  getData = () => {
    axios.get('http://192.168.0.116:3000/get')
      .then((res) => {
        this.loading = false
        this.data = res.data.data
      })
      .catch(error => {
        promptAction.showToast({ message: `获取数据失败！` })
        console.log(`获取数据失败！error: ${JSON.stringify(error)}`)
      })
  }
  updateData = (extraData: AxiosRequest['data'][number]) => {
    axios.put(`http://192.168.0.116:3000/update`, extraData)
      .then(() => {
        this.loading = false
        this.getData()
        promptAction.showToast({ message: '更新数据成功！' })
      })
      .catch(error => {
        promptAction.showToast({ message: '更新数据失败！' })
        console.log(`更新数据失败！error: ${JSON.stringify(error)}`)
      })
  }
  deleteData = (id: string) => {
    axios.delete(`http://192.168.0.116:3000/delete/${id}`)
      .then(() => {
        this.loading = false
        this.getData()
        promptAction.showToast({ message: '删除数据成功！' })
      })
      .catch(error => {
        promptAction.showToast({ message: '删除数据失败！' })
        console.log(`删除数据失败！error: ${JSON.stringify(error)}`)
      })
  }

  aboutToAppear() {
    this.getData()
  }

  @Builder
  DeleteListItem(data: AxiosRequest['data'][number]) {
    Row() {
      Button('删除')
        .backgroundColor('red')
        .fontColor('white')
        .onClick(() => {
          this.openConfirmDialog(() => this.deleteData(data.id))
        })

      Button('更新')
        .backgroundColor('red')
        .fontColor('white')
        .onClick(() => {
          this.openUpdateDialog(data)
        })
    }
  }

  @Builder ConfirmDialogContent() {
    Text('确认删除当前数据么？')
  }

  build() {
    Column() {
      PageTitle({ title: this.routeTitle })
        .margin({ bottom: 10 })

      Column({ space: 10 }) {
        if (this.loading) {
          LoadingProgress().width(50)
        } else {
          List({ space: 15 }) {
            ListItem() {
              Row() {
                Text('id').width('43%')
                Text('name').width('33%')
                Text('age').width('23%')
              }.width('100%')
            }

            if (!this.data.length) {
              ListItem() {
                Row() {
                  Text('暂无数据')
                }.width('100%')
              }
            } else {
              ForEach(this.data, (item) => {
                ListItem() {
                  Row() {
                    Text(item.id).width('43%')
                    Text(item.name).width('33%')
                    Text(item.age?.toString()).width('23%')
                  }
                }
                .width('100%')
                .swipeAction({
                  end: this.DeleteListItem(item)
                })
              })
            }
          }
          .height('auto')
          .layoutWeight(1)

          Row() {
            Button('添加数据').onClick(() => {
              this.openCreateDialog()
            })
          }
        }
      }.layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}

@CustomDialog
struct UpdateCreateDialog {
  okText: string
  name: string
  age: number
  dialogController: CustomDialogController
  cancel: () => void
  confirm: (name: string, age: number, id?: string) => void

  build() {
    Column({ space: 10 }) {
      Row() {
        Text('name: ')
        TextInput({ placeholder: '请输入名称', text: this.name ?? '' })
          .layoutWeight(1)
          .onChange(val => this.name = val)
      }

      Row() {
        Text('age: ')
        TextInput({ placeholder: '请输入年龄', text: this.age?.toString() ?? '' })
          .layoutWeight(1)
          .inputFilter('[0-9]')
          .onChange(val => this.age = +val)
      }

      Row({ space: 20 }) {
        Button('取消')
          .onClick(() => {
            this.dialogController.close()
            if (this.cancel instanceof Function) {
              this.cancel()
            }
          })
        Button(this.okText)
          .onClick(() => {
            this.dialogController.close()
            this.confirm(this.name, this.age)
          })
      }
    }
    .padding(10)
  }
}

@CustomDialog
struct CustomConfirmDialog {
  @BuilderParam dialogContent: any
  dialogController: CustomDialogController
  cancel: () => void
  confirm: () => void

  build() {
    Column({ space: 10 }) {
      this.dialogContent()

      Row({ space: 20 }) {
        Button('取消')
          .onClick(() => {
            if (this.cancel instanceof Function) {
              this.cancel()
            }
            this.dialogController.close()
          })
        Button('确认')
          .onClick(() => {
            this.confirm()
            this.dialogController.close()
          })
      }
    }
    .padding(10)
  }
}