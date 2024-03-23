import router from '@ohos.router'
import axios from '@ohos/axios'
import { PageTitle } from '../components/PageTitle'
import promptAction from '@ohos.promptAction'
import { userRdb } from '../model/UserRdb'
import relationalStore from '@ohos.data.relationalStore'
import preferences from '@ohos.data.preferences'

@Entry
@Component
struct RelationalDataBase {
  @State routeTitle: string = router.getParams()['title']
  @State loading: boolean = true
  @State okText: string = '创建'
  @State data: Array<{
    id: number;
    name: string;
    age: number
  }> = []
  rdbStore: relationalStore.RdbStore
  dialogCreateController: CustomDialogController
  openCreateDialog = () => {
    this.dialogCreateController = new CustomDialogController({
      builder: UpdateCreateDialog({
        okText: '创建',
        dialogController: this.dialogCreateController,
        confirm: (name: string, age: number) => {
          this.addData(name, age)
        }
      })
    })
    this.dialogCreateController.open()
  }
  dialogUpdateController: CustomDialogController
  openUpdateDialog = (data: RelationalDataBase['data'][number]) => {
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
    this.rdbStore.insert(userRdb.employeeTableName, { name, age }, (err, rowId) => {
      if (!err) {
        promptAction.showToast({ message: '创建数据成功！rowId: ' + rowId })
        console.log('testTag RelationalDataBase > 创建数据成功 rowId：', rowId)
        this.getData()
        return
      }
      promptAction.showToast({ message: '创建数据失败！' })
      console.log('testTag RelationalDataBase > 创建数据失败！')
    })
  }
  getData = async () => {
    this.data = []

    try {
      const predicates = new relationalStore.RdbPredicates(userRdb.employeeTableName)
      const resultSet = await this.rdbStore.query(predicates)
      // const resultSet = await this.rdbStore.querySql(`SELECT * FROM ${userRdb.employeeTableName}`)
      const columnNames = resultSet.columnNames

      while (!resultSet.isAtLastRow) {
        resultSet.goToNextRow()
        const rowData = {} as RelationalDataBase['data'][number]

        columnNames.forEach((name, index) => {
          if (name.toLowerCase() === 'id') {
            rowData.id = resultSet.getLong(index)
          }
          if (name.toLowerCase() === 'name') {
            rowData.name = resultSet.getString(index)
          }
          if (name.toLowerCase() === 'age') {
            rowData.age = resultSet.getLong(index)
          }
        })

        this.data.push(rowData)
      }
    } catch (error) {
      promptAction.showToast({ message: `获取数据失败！` })
      console.log(`testTag RelationalDataBase > 获取数据失败！error: ${JSON.stringify(error)}`)
    }
    this.loading = false
  }
  updateData = (newData: RelationalDataBase['data'][number]) => {
    const predicates = new relationalStore.RdbPredicates(userRdb.employeeTableName)
    predicates.equalTo('id', newData.id)

    this.rdbStore.update(newData, predicates, (err, rowNumber) => {
      if (!err) {
        this.getData()
        promptAction.showToast({ message: `更新数据成功！` })
        console.log(`testTag RelationalDataBase > 更新数据成功！rowNumber: ${JSON.stringify(rowNumber)}`)
        return
      }

      promptAction.showToast({ message: '更新数据失败！' })
      console.log(`testTag RelationalDataBase > 更新数据失败！error: ${JSON.stringify(err)}`)
    })
  }
  deleteData = (id: number) => {
    const predicates = new relationalStore.RdbPredicates(userRdb.employeeTableName)
    predicates.equalTo('id', id)

    this.rdbStore.delete(predicates, (err, rowNumber) => {
      if (!err) {
        this.getData()
        promptAction.showToast({ message: `删除数据成功！` })
        console.log(`testTag RelationalDataBase > 删除数据成功！rowNumber: ${JSON.stringify(rowNumber)}`)
        return
      }

      promptAction.showToast({ message: '删除数据失败！' })
      console.log(`testTag RelationalDataBase > 删除数据失败！error: ${JSON.stringify(err)}`)
    })
  }

  aboutToAppear() {
    this.rdbStore = userRdb.getRdbStore()
    this.getData()
  }

  @Builder
  DeleteListItem(data: RelationalDataBase['data'][number]) {
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
                    Text(item.id.toString()).width('43%')
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
          .width('auto')
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