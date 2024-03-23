import router from '@ohos.router'
import window from '@ohos.window'
import display from '@ohos.display'
import promptAction from '@ohos.promptAction'
import { PreferenceName, userPreference } from '../model/UserPreference'
import preferences from '@ohos.data.preferences'
// import GameResultDialog from '../components/GameResultDialog'

PersistentStorage.PersistProp('maxScoreRecord', 0)
// PersistentStorage.DeleteProp('maxScoreRecord')

const FishGameSettingEvent = 'FishGameSettingEvent'

export default class Food {
  imageUrl: Resource
  rotate: number
  size: number
  speed: number
  isShow: boolean
  x: number
  y? = 0
  id?: string
  score: number
  screenY? = 0

  constructor(food: Food) {
    Object.assign(this, food);
    this.id = Math.random().toString() + food.imageUrl.id
  }
}

@Preview
@Entry()
@Component
struct FishGameAnimation {
  currentContext = getContext(this)
  @State isStart: boolean = false
  @State isSetting: boolean = false
  @State isContinueButtonShow: boolean = false
  isResultDialogHide = true

  // 小鱼信息
  forwardFish = $r('app.media.fish')
  backwardFish = $r('app.media.fish_rev')
  fishWidth = 50
  fishHeight = 50
  @State @Watch('onModifiedFishSpeed') modifiedFishSpeed: number = 3.5
  @State fishSpeed: number = this.modifiedFishSpeed
  @State fish: Resource = this.forwardFish
  @State fishAngle: number = 0
  fishInitPositionX = 50
  fishInitPositionY = 130
  @State fishPositionX: number = this.fishInitPositionX
  @State fishPositionY: number = this.fishInitPositionY

  // 操作区域
  operationAreaDiameter = 160
  operationAreaCenterXY = 80
  operationAreaRadius = this.operationAreaDiameter / 2
  @State operationAreaPositionX: number = 30
  @State operationAreaPositionY: number = 180

  // 操作按钮
  movableButtonDiameter: number = 50
  movableButtonRadius: number = this.movableButtonDiameter / 2
  movableButtonInitPositionXY: number = 55
  @State movableButtonPositionX: number = this.movableButtonInitPositionXY
  @State movableButtonPositionY: number = this.movableButtonInitPositionXY

  // 背景信息
  gameBackgroundWidth = 0
  @State gameBackgroundPositionX: number = 0

  // 游戏窗口宽高
  windowHeight = 0
  windowWidth = 0

  // 屏幕顶部避开区域的高度，即摄像头占据的高度
  screenTopAvoidAreaHeight = 0
  // 最终显示的窗口对象
  lastWindow: window.Window
  // 获取显示器信息
  displayObj: display.Display
  intervalId = -1
  sinRadian = 0
  cosRadian = 0
  movableMaxWidth2Fish = 0

  // 小鱼生命信息
  liveColor = $r('app.color.heart_red')
  heartInitColors = [this.liveColor, this.liveColor, this.liveColor]
  @State heartColors: (Color | string | Resource)[] = this.heartInitColors
  @State @Watch('changeHeartColor') boomTimes: number = 0

  // 其他食物信息
  @State foods: Array<Food[]> = []
  allKindsOfFoods: Food[] = []
  initialFoods: Array<Food[]> = []
  @State foodCountPerRow: number = 7
  @State foodSpeedIncrement: number = 1
  moveOtherFoodIntervalId = -1

  // 数组项为，第n行食物组件的相对游戏窗口的 y 坐标
  rowsY = [45, 105, 165, 225, 285]

  // 分数
  @State score: number = 0
  @StorageLink('maxScoreRecord') maxScoreRecord: number = 0

  onModifiedFishSpeed() {
    this.fishSpeed = this.modifiedFishSpeed
  }

  // 设置信息弹窗
  settingDialogController = new CustomDialogController({
    builder: GameSettingDialog({
      modifiedFishSpeed: $modifiedFishSpeed,
      foodCountPerRow: $foodCountPerRow,
      foodSpeedIncrement: $foodSpeedIncrement
    }),
    autoCancel: false,
    alignment: DialogAlignment.TopEnd,
    offset: {
      dx: -20,
      dy: 55
    }
  })

  // 传递给对话框的函数，需要绑定this为当前组件：使用箭头函数定义 或 传递时 bind(this)
  resultDialogConfirm = () => {
    this.restoreInitialGameState()
    this.startMoveOtherFood()
    this.isResultDialogHide = true
    this.isContinueButtonShow = false
  }
  resultDialogCancel = () => {
    this.restoreInitialGameState()
    this.isStart = false
    this.isResultDialogHide = true
    this.isContinueButtonShow = false
  }
  resultDialogController: CustomDialogController

  createOpenResultDialog() {
    this.resultDialogController = new CustomDialogController({
      builder: GameResultDialog({
        score: this.score,
        actionButtons: [
          {
            text: '继续下一局',
            action: this.resultDialogConfirm
          },
          {
            text: '我再想想',
            action: this.resultDialogCancel
          }
        ]
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center
    })

    this.resultDialogController.open()
    this.isResultDialogHide = false
  }

  // 点击手机底部返回，或手势返回; 最终返回了其他页面
  onBackPress() {
  }

  restoreInitialGameState() {
    this.score = 0
    this.boomTimes = 0
    this.foods = this.initialFoods
    this.fish = this.forwardFish
    this.fishPositionX = this.fishInitPositionX
    this.fishPositionY = this.fishInitPositionY
  }

  changeHeartColor() {
    if (this.boomTimes === 0) {
      this.heartColors = [this.liveColor, this.liveColor, this.liveColor]
    }

    if (this.boomTimes >= 1 && this.boomTimes <= 3) {
      this.heartColors.splice(this.boomTimes - 1, 1, Color.Gray)
    }

    if (this.boomTimes === 3) {
      clearInterval(this.moveOtherFoodIntervalId)
      this.createOpenResultDialog()
      this.isContinueButtonShow = true
    }
  }

  fishSwim(func: () => void) {
    animateTo({ duration: 300, curve: Curve.Smooth }, () => func())
  }

  handleFishMove(event: TouchEvent) {
    if (event.type === TouchType.Down) {
      // 小鱼运动定时器具
      this.intervalId = setInterval(() => {
        // 当小鱼移动到最右边屏幕时，向左移动背景图，使得小鱼看着像是往右走
        if (this.fishPositionX === this.movableMaxWidth2Fish) {
          this.gameBackgroundPositionX -= this.fishSpeed
        }

        // 当小鱼移动到最左边屏幕时，向右移动背景图，使得小鱼看着像是往左走
        if (this.fishPositionX === 0) {
          this.gameBackgroundPositionX += this.fishSpeed
        }

        if (this.fishSpeed === 0) {
          return
        }

        // 根据手指信息，计算出的小鱼的目的坐标
        const destinationX = this.fishPositionX + this.cosRadian * this.fishSpeed
        const destinationY = this.fishPositionY + this.sinRadian * this.fishSpeed

        // 小鱼的 目的XY坐标 的最大值
        this.movableMaxWidth2Fish = this.windowWidth - this.screenTopAvoidAreaHeight - 63
        const movableMaxHeight2Fish = this.windowHeight - 62

        // 限制小鱼移动范围
        this.fishPositionX = destinationX < 0 ? 0 : destinationX > this.movableMaxWidth2Fish ? this.movableMaxWidth2Fish : destinationX
        this.fishPositionY = destinationY < 0 ? 0 : destinationY > movableMaxHeight2Fish ? movableMaxHeight2Fish : destinationY
      }, 40)
    }
    if (event.type === TouchType.Move) {
      // 手指相对于 触发 onTouch 事件的组件(大圆) 的位置, 可能超出大圆
      const fingerX = event.touches[0].x
      const fingerY = event.touches[0].y

      // 手指位置与圆心坐标，在x y轴方向的差值，可能为负
      const xAxisDiff = fingerX - this.operationAreaCenterXY
      const yAxisDiff = fingerY - this.operationAreaCenterXY

      // 在坐标系中，以(0,0)为原点，X轴正方向 逆时针旋转到坐标点，所产生的弧度，即直角边 rightAngleSideY 对应的弧度[-PI, PI]
      const radian = Math.atan2(yAxisDiff, xAxisDiff)

      // 在坐标系中，以(0,0)为原点，X轴正方向 逆时针旋转到坐标点，所产生的角度，即直角边 rightAngleSideY 对应的角度;
      // 逆时针[0,-180°] 接着[180°, 0]之间，与小鱼组件 rotate属性旋转方向一致
      const angle = radian * 180 / Math.PI

      // 设置小鱼旋转角度
      this.fishAngle = angle

      // 改变鱼的方向
      if (this.fishAngle > -90 && this.fishAngle < 90) {
        this.fish = this.forwardFish
      } else {
        this.fish = this.backwardFish
        // 变成反方向图片后，小鱼自身还要旋转180°，正负都可以
        this.fishAngle -= 180
      }

      // 手指与操作按钮圆心位置，划出的直线距离
      const movingLineLength = Math.sqrt(Math.abs(xAxisDiff)**2 + Math.abs(yAxisDiff)**2)

      // 最终有效的：手指与操作按钮圆心位置，划出的直线距离，不能超出大圆
      const movedValidLineLength = Math.min(this.operationAreaRadius, movingLineLength)

      // 根据操作按钮旋转的弧度计算 正弦值 和 余弦值
      this.sinRadian = Math.sin(radian)
      this.cosRadian = Math.cos(radian)

      // 设置操作按钮 在大圆内的位置坐标
      this.movableButtonPositionX = this.operationAreaCenterXY + this.cosRadian * movedValidLineLength - this.movableButtonRadius
      this.movableButtonPositionY = this.operationAreaCenterXY + this.sinRadian * movedValidLineLength - this.movableButtonRadius

      // 恢复小鱼速度, 即小鱼走的斜线距离
      this.fishSpeed = this.modifiedFishSpeed
    }
    if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      clearInterval(this.intervalId)
      animateTo({ duration: 500, curve: Curve.ExtremeDeceleration }, () => {
        // 恢复移动按钮位置
        this.movableButtonPositionX = this.movableButtonInitPositionXY
        this.movableButtonPositionY = this.movableButtonInitPositionXY

        // 恢复小鱼角度，小鱼速度归零
        this.fishAngle = 0
        this.fishSpeed = 0
      })
    }
  }

  startMoveOtherFood() {
    this.moveOtherFoodIntervalId = setInterval(() => {
      this.foods = this.foods.map((rowFoods, rowIndex) => {
        return rowFoods.map((food) => {
          const newFood = Object.assign(new Food(food), { x: food.x - food.speed, isShow: true })
          const handleFoodHide = () => {
            animateTo({
              curve: Curve.Linear,
              duration: 700,
            }, () => newFood.isShow = false)

            if (newFood.score < 0) {
              this.boomTimes += 1
            } else {
              this.score += newFood.score
              this.maxScoreRecord = this.score > this.maxScoreRecord ? this.score : this.maxScoreRecord
            }

            return this.getNewFood(rowIndex)
          }

          if (newFood.x < -newFood.size) {
            return this.getNewFood(rowIndex)
          }

          // 判断小鱼是否碰到食物或炸弹
          if (newFood.isShow) {
            // 小鱼方向等信息
            const oneThirdFishHeight = this.fishHeight / 3
            const forwardFishMouthX = this.fishPositionX + this.fishWidth
            const forwardFishMouthY = this.fishPositionY + oneThirdFishHeight * 2
            const backwardFishMouthX = this.fishPositionX
            const backwardFishMouthY = forwardFishMouthY
            const fishHalfWidth = this.fishWidth / 2
            const fishCenterX = this.fishPositionX + fishHalfWidth

            // 食物方向等信息
            const foodHalfWidth = newFood.size / 2
            const foodHalfHeight = newFood.size / 2
            const foodCenterX = newFood.x + foodHalfWidth
            const foodCenterY = newFood.screenY + foodHalfHeight
            const foodInRight = (newFood.x - this.fishPositionX) > 0
            const foodInLeft = (newFood.x - this.fishPositionX) < 0
            const food2FishDiffX = foodCenterX - fishCenterX

            // 判断结果
            const isForwardFish = this.fish.id === this.forwardFish.id && food2FishDiffX > 0
            const isBackwardFish = this.fish.id === this.backwardFish.id && food2FishDiffX < 0
            const isRightOverlay = Math.sqrt(Math.abs(foodCenterX - forwardFishMouthX)**2 + Math.abs(foodCenterY - forwardFishMouthY)**2) < foodHalfWidth
            const isLeftOverlay = Math.sqrt(Math.abs(foodCenterX - backwardFishMouthX)**2 + Math.abs(foodCenterY - backwardFishMouthY)**2) < foodHalfWidth

            if ((isForwardFish && foodInRight && isRightOverlay) || (isBackwardFish && foodInLeft && isLeftOverlay)) {
              return handleFoodHide()
            }
          }
          return newFood
        })
      })
    }, 40)
  }

  /* 只能在 gameBackgroundWidth 值初始化之后，才能调用
   * @parameter lines 食物图片所在的行数
   * */
  getNewFood(rowIndex: number, columnIndex?: number) {
    const randomFoodIndex = Math.floor(Math.random() * this.allKindsOfFoods.length)
    const newFood = new Food(this.allKindsOfFoods[randomFoodIndex])

    newFood.screenY = this.rowsY[rowIndex]

    if (columnIndex !== undefined) {
      newFood.x += columnIndex * newFood.size
    }

    return newFood
  }

  initFoods() {
    this.foods = []
    this.allKindsOfFoods = [
      new Food({
        imageUrl: $r('app.media.crab'),
        size: 26,
        rotate: 0,
        speed: 0.8 + ((this.foodSpeedIncrement - 1) / 10),
        isShow: true,
        x: this.gameBackgroundWidth + 26,
        score: 1
      }),
      new Food({
        imageUrl: $r('app.media.small_lobster'),
        size: 30,
        rotate: -90,
        speed: 1 + ((this.foodSpeedIncrement - 1) / 10),
        isShow: true,
        x: this.gameBackgroundWidth + 30,
        score: 1
      }),
      new Food({
        imageUrl: $r('app.media.squid'),
        size: 34,
        rotate: 0,
        speed: 1.1 + ((this.foodSpeedIncrement - 1) / 10),
        isShow: true,
        x: this.gameBackgroundWidth + 34,
        score: 2
      }),
      new Food({
        imageUrl: $r('app.media.gold_fish'),
        size: 39,
        rotate: -15,
        speed: 1.2 + ((this.foodSpeedIncrement - 1) / 10),
        isShow: true,
        x: this.gameBackgroundWidth + 39,
        score: 3
      }),
      new Food({
        imageUrl: $r('app.media.swordfish'),
        size: 42,
        rotate: -45,
        speed: 1.3 + ((this.foodSpeedIncrement - 1) / 10),
        isShow: true,
        x: this.gameBackgroundWidth + 42,
        score: 4
      }),
      new Food({
        imageUrl: $r('app.media.bomb'),
        size: 45,
        rotate: 0,
        speed: 0.9 + ((this.foodSpeedIncrement - 1) / 10),
        isShow: true,
        x: this.gameBackgroundWidth + 45,
        score: -1
      })
    ]
    this.initialFoods = Array(5).fill(0).map((_, rowIndex) => Array(this.foodCountPerRow)
      .fill(0)
      .map((_, columnIndex) => this.getNewFood(rowIndex, columnIndex)))
    this.foods = this.initialFoods
  }

  getPreferenceData() {
    const fishGamePreference = userPreference.preferenceMap.get(PreferenceName.FishGamePreference)

    fishGamePreference.get('fishSpeed', this.modifiedFishSpeed, (error, value: number) => {
      if (error) {
        console.log('testTag userPreference 获取 fishSpeed 错误')
        return
      }
      this.modifiedFishSpeed = value
      this.fishSpeed = value
    })

    fishGamePreference.get('foodCountPerRow', this.foodCountPerRow, (error, value: number) => {
      if (error) {
        console.log('testTag userPreference 获取 foodCountPerRow 错误')
        return
      }
      this.foodCountPerRow = value
    })

    fishGamePreference.get('foodSpeedIncrement', this.foodSpeedIncrement, (error, value: number) => {
      if (error) {
        console.log('testTag userPreference 获取 foodSpeedIncrement 错误')
        return
      }
      this.foodSpeedIncrement = value
    })
  }

  aboutToAppear() {
    this.getPreferenceData()

    this.displayObj = display.getDefaultDisplaySync()
    // 因为窗口旋转了，所以显示器的宽度，就变成了游戏界面的高度
    this.windowHeight = px2vp(this.displayObj.width)
    this.windowWidth = px2vp(this.displayObj.height)

    window.getLastWindow(this.currentContext)
      .then(lastWindow => {
        this.lastWindow = lastWindow
        lastWindow.setPreferredOrientation(window.Orientation.LANDSCAPE)
        lastWindow.setWindowSystemBarEnable([])
        const avoidArea = lastWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
        this.screenTopAvoidAreaHeight = px2vp(avoidArea.topRect.height)
        this.gameBackgroundWidth = this.windowWidth - this.screenTopAvoidAreaHeight
        this.initFoods()
      })
  }

  aboutToDisappear() {
    this.lastWindow.setPreferredOrientation(window.Orientation.UNSPECIFIED)
    this.currentContext.eventHub.off(FishGameSettingEvent)
  }

  onPageHide() {
    clearInterval(this.moveOtherFoodIntervalId)
  }

  onPageShow() {
    if (this.isStart && this.boomTimes < 3) {
      this.startMoveOtherFood()
    }
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(16)
          .padding(5)
          .borderRadius(5)
          .margin({ left: 20 })
          .fontColor(Color.White)
          .backgroundColor('rgba(0,0,0,0.2)')
          .onClick(() => {
            router.back()
          })

        Blank()

        if (this.isStart) {
          // 红心
          Row({ space: 10 }) {
            Text() {
              Span(`最高记录：`)
              Span(this.maxScoreRecord.toString())
                .fontWeight(FontWeight.Bold)
            }

            ForEach(this.heartColors, (color) => {
              Image($r('app.media.heart'))
                .width(30)
                .height(30)
                .fillColor(color)
            })

            Text() {
              Span(`当前分数：`)
              Span(this.score.toString())
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.Orange)
            }
          }
          .zIndex(9)
          .transition({
            type: TransitionType.Insert,
            opacity: 0,
            translate: { y: '-100%' }
          })
        }

        Blank()

        Image($r('app.media.setting'))
          .width(32)
          .margin({ right: 20 })
          .padding(5)
          .borderRadius(16)
          .backgroundColor('rgba(0,0,0,0.2)')
          .onClick(() => {
            // this.createOpenSettingDialog()
            this.settingDialogController.open()
          })
      }
      .width('100%')
      .zIndex(99)
      .position({ x: 0, y: 15 })

      if (!this.isStart) {
        Button('开始游戏')
          .centerButtonStyle()
          .onClick(() => {
            this.startMoveOtherFood()
            animateTo({ duration: 700, curve: Curve.FastOutSlowIn }, () => {
              this.isStart = true
            })
          })
      }

      if (this.isStart) {
        // 其他食物
        Column() {
          ForEach(
            this.foods,
            (rowFoods: Food[], rowIndex) => {
              Row() {
                ForEach(
                  rowFoods,
                  (food: Food) => {
                    if (food.isShow) {
                      Image(food.imageUrl)
                        .position({ x: food.x })
                        .width(food.size)
                        .height(food.size)
                        .rotate({ angle: food.rotate })
                        .transition({
                          type: TransitionType.Delete,
                          opacity: 0
                        })
                    }
                  },
                  food => food.id
                )
              }
              .width('100%')
              // 高度为最大食物的高度
              .height(45)
              .position({ x: 0, y: this.rowsY[rowIndex] })
            }
          )
        }
        .width('100%')
        .height('100%')


        // 小鱼
        Image(this.fish)
          .width(this.fishWidth)
          .rotate({ angle: this.fishAngle, centerX: '50%', centerY: '50%' })
          .position({ x: this.fishPositionX, y: this.fishPositionY })
          .transition({
            type: TransitionType.Insert,
            translate: { x: -120 }
          })

        // 摇杆按钮
        Stack() {
          Circle({ width: this.operationAreaDiameter, height: this.operationAreaDiameter })
            .fill('rgba(0,0,0,0.2)')
          Circle({ width: this.movableButtonDiameter, height: this.movableButtonDiameter })
            .fill('rgba(0,0,0,0.4)')
            .position({ x: this.movableButtonPositionX, y: this.movableButtonPositionY })
        }
        .position({ x: this.operationAreaPositionX, y: this.operationAreaPositionY })
        /*
         * 过渡动画/转场动画，有3点要求：
         * 1. 目标动画组件 需要放在使用显示变量的if条件中
         * 2. 目标动画组件 使用 transition 过渡动画属性，里面配置的是 组件显示时的起点状态 和 组件隐藏时的终点状态
         * 3. 显示变量 需要放在 animateTo 显性动画方法的配置参数方法中改变
         * 优点：只需控制一个显示变量，而不需要改变多个动画属性目的值的变量
         * */
        .transition({
          type: TransitionType.Insert,
          translate: { y: '100%' },
          opacity: 0
        })
        .onTouch(this.handleFishMove.bind(this))
      }

      if (this.isContinueButtonShow) {
        Column() {
          Button('继续下一局')
            .centerButtonStyle()
            .onClick(() => {
              this.isContinueButtonShow = false
              this.resultDialogConfirm()
            })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0 })
        .zIndex(10)
        .backgroundColor(`rgba(0,0,0,0.2)`)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.sea_invert'), ImageRepeat.X)
    .backgroundImageSize({ width: '200%', height: '100%' })
    .backgroundImagePosition({ x: this.gameBackgroundPositionX, y: 0 })
  }
}

@Styles function centerButtonStyle() {
  .position({ x: '50%', y: '50%' })
  .translate({ x: '-50%', y: '-50%' })
  .transition({
    type: TransitionType.Delete,
    opacity: 0
  })
}

@CustomDialog
struct GameResultDialog {
  // 直接声明属性，就可以在当前组件中使用，必须要写的属性
  controller: CustomDialogController
  @Prop score: number
  @StorageLink('maxScoreRecord') maxScoreRecord: number = 0
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
      Text('Game Over !')
        .fontWeight(FontWeight.Bold)

      Column({ space: 10 }) {
        Text(`当前分数：${this.score}`)
          .fontColor(Color.Orange)
        Text(`${this.score < this.maxScoreRecord ? '你差点就打破纪录了，下次加油！' : '恭喜你刷新了最高纪录！'}`)
      }
      .width('100%')

      if (this.actionButtons.length) {
        Row() {
          ForEach(this.actionButtons, (button: GameResultDialog['actionButtons'][number]) => {
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

@CustomDialog
struct GameSettingDialog {
  fishGamePreference = userPreference.preferenceMap.get(PreferenceName.FishGamePreference)
  controller: CustomDialogController
  eventHub = getContext(this).eventHub
  @Link modifiedFishSpeed: number
  speedText = {
    '1.5': '低',
    '3.5': '中',
    '5.5': '高',
  }
  @Link foodCountPerRow: number
  foodCountText = {
    '4': '低',
    '7': '中',
    '10': '高',
  }
  @Link foodSpeedIncrement: number
  foodSpeedIncrementText = {
    '1': '低',
    '4': '中',
    '7': '高',
  }

  updatePreference(key: 'modifiedFishSpeed' | 'foodCountPerRow' | 'foodSpeedIncrement', value: number) {
    this[key] = value
    this.fishGamePreference.put(key, value)
    this.fishGamePreference.flush()
  }

  build() {
    Column() {
      Row() {
        Text('设置')
          .fontWeight(FontWeight.Bold)
        Blank()
        Text('×')
          .fontSize(30)
          .fontColor($r('app.color.harmony_blue'))
          .onClick(() => this.controller.close())
      }
      .width('100%')

      Row({ space: 10 }) {
        Text('捕食者速度:')
          .width(85)
        Slider({ value: this.modifiedFishSpeed, min: 1.5, max: 5.5, step: 2 })
          .showSteps(true)
          .layoutWeight(1)
          .onChange((value, mode) => {
            if (mode === SliderChangeMode.End) {
              this.updatePreference('modifiedFishSpeed', value)
            }
          })
        Text(this.speedText[this.modifiedFishSpeed.toString()])
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row({ space: 10 }) {
        Text('食物数量:')
          .width(85)
        Slider({ value: this.foodCountPerRow, min: 4, max: 10, step: 3 })
          .showSteps(true)
          .layoutWeight(1)
          .onChange((value, mode) => {
            console.log('testTag Slider onChange 食物数量变化前:', this.foodCountPerRow)
            console.log('testTag Slider onChange 食物数量变化后:', value, mode)
            if (mode === SliderChangeMode.End) {
              this.updatePreference('foodCountPerRow', value)
            }
          })
        Text(this.foodCountText[this.foodCountPerRow.toString()])
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row({ space: 10 }) {
        Text('食物速度:')
          .width(85)
        Slider({ value: this.foodSpeedIncrement, min: 1, max: 7, step: 3 })
          .showSteps(true)
          .layoutWeight(1)
          .onChange((value, mode) => {
            if (mode === SliderChangeMode.End) {
              this.updatePreference('foodSpeedIncrement', value)
            }
          })
        Text(this.foodSpeedIncrementText[this.foodSpeedIncrement.toString()])
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding({ left: 15, right: 15, top: 10, bottom: 10 })
  }
}