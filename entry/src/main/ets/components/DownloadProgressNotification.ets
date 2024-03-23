import promptAction from '@ohos.promptAction'
import notificationManager from '@ohos.notificationManager'
import wantAgent, { WantAgent } from '@ohos.app.ability.wantAgent'
import emitter from '@ohos.events.emitter'
import wantConstant from '@ohos.ability.wantConstant'

enum StateEnum {
  NOT_START = '未开始',
  DOWNLOADING = '下载中',
  PAUSE = '暂停',
  DONE = '完成',
}

@Component
export struct DownloadProgressNotification {
  @State progressValue: number = 0
  @State stateText: StateEnum = StateEnum.NOT_START
  wantAgentForStartAbility: WantAgent = {}
  wantAgentForSendEvent: WantAgent = {}
  taskId: number = -1
  isSupportTemplate: boolean = false
  fileName = 'bilibili'
  maxValue = 100
  notifyId = Date.now()
  eventHub: Context['eventHub']

  download() {
    this.stateText = StateEnum.DOWNLOADING
    this.taskId = setInterval(() => {
      if (this.progressValue >= this.maxValue) {
        this.pause(() => this.stateText = StateEnum.DONE)
        return
      }
      this.progressValue += 10
      this.notify()
    }, 2000)
  }

  pause(func?: () => void) {
    clearInterval(this.taskId)
    this.taskId = -1
    if (func instanceof Function) {
      func()
    }
  }

  cancel() {
    this.pause()
    this.stateText = StateEnum.NOT_START
    this.progressValue = 0
    notificationManager.cancel(this.notifyId)
  }

  notify() {
    if (!this.isSupportTemplate) {
      promptAction.showToast({ message: '当前系统不支持进度通知！' })
      return
    }

    const template: notificationManager.NotificationTemplate = {
      name: 'downloadTemplate',
      data: {
        progressValue: this.progressValue,
        progressMaxValue: this.maxValue
      }
    }
    const request: notificationManager.NotificationRequest = {
      id: this.notifyId,
      template,
      wantAgent: this.wantAgentForStartAbility,
      content: {
        contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: this.fileName + '.mp4',
          additionalText: `${this.stateText} ${this.progressValue}%`,
          text: ''
        },
      },
      // 只显示暂时无点击效果
      actionButtons: [
        {
          title: '暂停',
          wantAgent: this.wantAgentForSendEvent,
          extras: {
            actionButtonsTitle: '暂停'
          }
        },
        {
          title: '继续',
          wantAgent: this.wantAgentForSendEvent,
          extras: {
            actionButtonsTitle: '继续'
          }
        }
      ]
    }
    notificationManager.publish(request)
      .catch(reason => console.log('testTag DownloadProgressNotification > 进度通知失败：', JSON.stringify(reason)))
  }

  listenNotifyButtonEvent() {
    this.eventHub = getContext(this).eventHub
    this.eventHub.on('action.system.home', (data) => {
      console.log('testTag', 'DownloadProgressNotification > listenNotifyButtonEvent > data: ', JSON.stringify(data))
    })
  }

  async aboutToAppear() {
    // this.listenNotifyButtonEvent()
    const startAbilityWantAgentInfo: wantAgent.WantAgentInfo = {
      requestCode: 0,
      operationType: wantAgent.OperationType.START_ABILITY,
      wantAgentFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG],
      wants: [
        {
          bundleName: 'com.example.myapplication',
          abilityName: 'EntryAbility',
          parameters: {
            pageUrl: 'pages/NotificationManagerPractice'
          }
        }
      ]
    }
    this.wantAgentForStartAbility = await wantAgent.getWantAgent(startAbilityWantAgentInfo)

    const sendEventWantAgentInfo: wantAgent.WantAgentInfo = {
      requestCode: 1,
      operationType: wantAgent.OperationType.SEND_COMMON_EVENT,
      wantAgentFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG],
      wants: [
        {
          action: wantConstant.Action.ACTION_HOME
        }
      ]
    }
    this.wantAgentForSendEvent = await wantAgent.getWantAgent(sendEventWantAgentInfo)
    this.isSupportTemplate = await notificationManager.isSupportTemplate('downloadTemplate')
  }

  aboutToDisappear() {
    // this.eventHub.off('action.system.home')
    console.log('testTag', 'DownloadProgressNotification > 下载组件消失')
  }

  build() {
    Row({ space: 10 }) {
      Image($r('app.media.video'))
        .width(72)
        .height(67)

      Column({ space: 15 }) {
        Row() {
          Text(`${this.fileName}.mp4`)
            .fontColor('white')
          Text(`${this.stateText} ${this.progressValue}%`)
            .fontColor('white')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Progress({ value: this.progressValue, total: this.maxValue })
          .backgroundColor(Color.White)

        Row() {
          Text(`${(this.progressValue * 2.78).toFixed(2)} MB`)
            .fontColor('white')

          Row({ space: 10 }) {
            if (this.stateText === StateEnum.DONE) {
              Button('打开')
                .onClick(() => {
                  promptAction.showToast({ message: '未实现' })
                })
            } else {
              Button('取消')
                .onClick(() => {
                  this.cancel()
                })

              if (this.stateText === StateEnum.NOT_START) {
                Button('开始')
                  .onClick(() => {
                    this.download()
                  })
              }

              if (this.stateText === StateEnum.PAUSE) {
                Button('继续')
                  .onClick(() => {
                    this.download()
                  })
              }

              if (this.stateText === StateEnum.DOWNLOADING) {
                Button('暂停')
                  .onClick(() => {
                    this.pause(() => {
                      this.stateText = StateEnum.PAUSE
                      this.notify()
                    })
                  })
              }
            }

          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(10)
    .borderRadius(8)
    .backgroundColor('#1f1f23')
  }
}