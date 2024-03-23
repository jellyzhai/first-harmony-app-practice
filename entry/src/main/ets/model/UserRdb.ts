import relationalStore from '@ohos.data.relationalStore';
import UIAbility from '@ohos.app.ability.UIAbility';


class UserRdb {
  private rdbStore: relationalStore.RdbStore
  private config: relationalStore.StoreConfig = {
    name: 'userInfo.db',
    securityLevel: relationalStore.SecurityLevel.S1
  }
  readonly employeeTableName = 'employee'
  private creationTableSQLs = [
    {
      [this.employeeTableName]: `CREATE TABLE IF NOT EXISTS ${this.employeeTableName} (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, age INTEGER)`
    }
  ]

  loadRdbStore(context: UIAbility['context']): Promise<relationalStore.RdbStore> {
    return new Promise((resolve, reject) => {
      relationalStore.getRdbStore(context, this.config, (err, rdbStore: relationalStore.RdbStore) => {
        if (!err) {
          this.creationTableSQLs.forEach(item => {
            try {
              rdbStore.executeSql(Object.values(item)[0], [], (err) => {
                if (err) {
                  console.log(`testTag UserRdb > err:`, JSON.stringify(err))
                }
              })
            } catch (err) {
              console.log(`testTag UserRdb > 创建表 ${Object.keys(item)[0]} 失败！`, JSON.stringify(err))
            }
          })
          this.rdbStore = rdbStore
          resolve(rdbStore)
          console.log('testTag', 'UserRdb > 加载 rdbStore 关系型数据库存储对象成功！')
          return
        }
        reject(err)
        console.log('testTag', 'UserRdb > 加载 rdbStore 关系型数据库存储对象失败！')
      })
    })
  }

  getRdbStore() {
    return this.rdbStore
  }
}

export const userRdb = new UserRdb()