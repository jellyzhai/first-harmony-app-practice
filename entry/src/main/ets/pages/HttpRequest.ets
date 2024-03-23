// 本地数据服务器：https://github.com/jellyzhai/node_server

import router from '@ohos.router'
import http from '@ohos.net.http'
import { PageTitle } from '../components/PageTitle'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct HttpRequest {
  @State routeTitle: string = router.getParams()['title']
  @State loading: boolean = true
  @State okText: string = '创建'
  @State data: Array<{
    id: string;
    name: string;
    age: number
  }> = []
  dialogCreateController: CustomDialogController
  getDialogCreateController = () => {
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
  }
  dialogUpdateController: CustomDialogController
  createUpdateController = (data: HttpRequest['data'][number]) => {
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
  }
  addData = (name: string, age: number) => {
    return http.createHttp().request('http://192.168.0.116:3000/add', {
      method: http.RequestMethod.POST,
      extraData: {
        id: Date.now().toString(),
        name,
        age
      }
    }).then(() => {
      this.loading = false
      promptAction.showToast({ message: '创建数据成功！' })
    }).catch(() => {
      promptAction.showToast({ message: '创建数据失败！' })
    })
  }
  getData = () => {
    http.createHttp().request('http://192.168.0.116:3000/get', {
      method: http.RequestMethod.GET
    })
      .then((data) => {
        this.loading = false
        this.data = JSON.parse(data.result as string).data
      })
      .catch(error => {
        this.data = error
        promptAction.showToast({ message: '获取数据失败！' })
      })
  }
  updateData = (extraData: HttpRequest['data'][number]) => {
    return http.createHttp().request(`http://192.168.0.116:3000/update`, {
      method: http.RequestMethod.PUT,
      extraData
    })
      .then(() => {
        this.loading = false
        this.getData()
        promptAction.showToast({ message: '更新数据成功！' })
      })
      .catch(error => {
        this.data = error
        promptAction.showToast({ message: '更新数据失败！' })
      })
  }
  deleteData = (id: string | number) => {
    http.createHttp().request(`http://192.168.0.116:3000/delete/${id}`, {
      method: http.RequestMethod.DELETE
    })
      .then(() => {
        this.loading = false
        this.getData()
        promptAction.showToast({ message: '删除数据成功！' })
      })
      .catch(error => {
        this.data = error
        promptAction.showToast({ message: '删除数据失败！' })
      })
  }

  aboutToAppear() {
    this.getData()
  }

  @Builder
  DeleteListItem(data: HttpRequest['data'][number]) {
    Row() {
      Button('删除')
        .backgroundColor('red')
        .fontColor('white')
        .onClick(() => {
          this.deleteData(data.id)
        })

      Button('更新')
        .backgroundColor('red')
        .fontColor('white')
        .onClick(() => {
          this.createUpdateController(data)
          this.dialogUpdateController.open()
        })
    }
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
              this.getDialogCreateController()
              this.dialogCreateController.open()
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