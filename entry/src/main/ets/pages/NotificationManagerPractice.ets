import router from '@ohos.router'
import notificationManager from '@ohos.notificationManager'
import { PageTitle } from '../components/PageTitle'
import promptAction from '@ohos.promptAction'
import image from '@ohos.multimedia.image'
import { DownloadProgressNotification } from '../components/DownloadProgressNotification'

@Entry
@Component
struct NotificationManagerPractice {
  @State routeTitle: string = router.getParams()['title']
  @State slotType: number = notificationManager.SlotType.CONTENT_INFORMATION
  pixelMap: PixelMap
  slotTypes: Array<{
    text: string;
    group: string;
    value: string;
  }> = [
    {
      text: '未知类型',
      group: 'slotType',
      value: '0'
    },
    {
      text: '社交类型',
      group: 'slotType',
      value: '1'
    },
    {
      text: '服务类型',
      group: 'slotType',
      value: '2'
    },
    {
      text: '内容类型',
      group: 'slotType',
      value: '3'
    },
    {
      text: '其他类型',
      group: 'slotType',
      value: '65535'
    },
  ]

  notify(requestConfig: notificationManager.NotificationRequest, successToast: string, failedToast: string) {
    notificationManager.publish(requestConfig, (err) => {
      if (!err) {
        promptAction.showToast({ message: successToast })
        return
      }
      promptAction.showToast({ message: failedToast })
      console.log(`testTag basicNotification > ${failedToast}`, JSON.stringify(err))
    })
  }

  basicNotification() {
    const requestConfig: notificationManager.NotificationRequest = {
      // 如果都不加 id 配置，多次发布通知使用相同的id 会导致覆盖上一个提示内容
      id: Date.now(),
      slotType: this.slotType,
      groupName: 'basicTextNotification',
      showDeliveryTime: true, // 开启显示通知时间，真机上不设置页显示，模拟器中需要设置
      deliveryTime: Date.now(), // 设置通知的时间
      content: {
        contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: '这是短文本通知标题',
          text: '这是短文本通知内容；这是短文本通知内容；这是短文本通知内容；这是短文本通知内容；这是短文本通知内容；',
          additionalText: '附加内容',
        }
      }
    }

    this.notify(requestConfig, '短文本提示通知成功', '短文本提示通知失败')
  }

  longNotification() {
    const requestConfig: notificationManager.NotificationRequest = {
      id: Date.now(),
      slotType: this.slotType,
      content: {
        contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_LONG_TEXT,
        longText: {
          title: '这是长文本通知，展开前标题',
          text: '这是长文本通知，展开前内容',
          expandedTitle: '这是长文本通知，展开后标题',
          additionalText: '附加内容',
          longText: '这是长文本通知，展开后内容；这是长文本通知，展开后内容；这是长文本通知，展开后内容；这是长文本通知，展开后内容；这是长文本通知，展开后内容；',
          briefText: '不显示：这是长文本简要文本',
        }
      }
    }

    this.notify(requestConfig, '长文本提示通知成功', '长文本提示通知失败')
  }

  multiLineNotification() {
    const requestConfig: notificationManager.NotificationRequest = {
      id: Date.now(),
      slotType: this.slotType,
      content: {
        contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_MULTILINE,
        multiLine: {
          title: '这是多行文本通知，展开前标题',
          text: '这是多行文本通知，展开前内容',
          longTitle: '这是多行文本通知，展开后标题',
          additionalText: '附加内容',
          lines: [
            '第一行',
            '第2行:这是多行文本通知，展开后内容；这是多行文本通知，展开后内容；这是多行文本通知，展开后内容；',
            '第3行'
          ],
          briefText: '不显示：这是多行文本简要文本；',
        }
      }
    }

    this.notify(requestConfig, '多行文本提示通知成功', '多行文本提示通知失败')
  }

  pictureNotification() {
    console.log('testTag NotificationManagerPractice > pictureNotification> this.pixelMap', JSON.stringify(this.pixelMap))
    const requestConfig: notificationManager.NotificationRequest = {
      id: Date.now(),
      slotType: this.slotType,
      content: {
        contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_PICTURE,
        picture: {
          title: '这是图片文本通知，展开前标题',
          text: '这是图片文本通知，展开前内容',
          expandedTitle: '这是图片文本通知，展开后标题',
          additionalText: '附加内容',
          briefText: '简要文本；',
          picture: this.pixelMap,
        }
      }
    }

    this.notify(requestConfig, '图片文本提示通知成功', '图片文本提示通知失败')
  }

  async aboutToAppear() {
    const file = await getContext(this).resourceManager.getMediaContent($r('app.media.ms_desktop'))
    // 模拟器中可以正常显示，4.0的系统中，不显示图片
    const pixelMap = await image.createImageSource(file.buffer)
      .createPixelMap({ desiredSize: { width: 320, height: 180 } })
    this.pixelMap = pixelMap
  }

  build() {
    Column({ space: 10 }) {
      PageTitle({ title: this.routeTitle })
        .onAppear(() => {
          console.log('testTag NotificationManagerPractice > PageTitle组件显示了！')
        })

      Column({ space: 10 }) {
        Button('基础文本通知')
          // .visibility(Visibility.Hidden)
          // .overlay('这是掩码文本')
          // .shadow({ radius: 20, color: Color.Gray, offsetY: 10 })
          // .mask(new RectAttribute().radiusWidth('100%').radiusHeight('100%'))
          .onClick(() => {
            this.basicNotification()
          })
        Button('长文本通知')
          .onClick(() => this.longNotification())
        Button('多行文本通知')
          .onClick(() => this.multiLineNotification())
        Button('图片+文本通知')
          .onClick(() => {
            this.pictureNotification()
          })

        DownloadProgressNotification()

        Row() {
          Text('通知类型：')

          Column() {
            ForEach(this.slotTypes, (item: NotificationManagerPractice['slotTypes'][number]) => {
              Row() {
                Text(item.text)
                Radio({ group: item.group, value: item.value })
                  // .enabled(false)
                  .checked(this.slotType === +item.value)
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.slotType = +item.value
                    }
                  })
              }
            })
          }
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        // .mask(new RectAttribute()) 暂时不知如何使用这个组件的公共属性方法
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}