- 使用 api9 版本
- 当前项目中，包含共享模块库，本地编辑器中，安装到手机时，需要先安装共享模块（虽然实际当前项目中没用到共享模块的代码）
  - 因为 entry 模块的包文件 oh-package.json5中，依赖引用了共享模块
    - ```json
      {
        "license": "",
        "devDependencies": {},
        "author": "",
        "name": "entry",
        "description": "Please describe the basic information.",
        "main": "",
        "version": "1.0.0",
        "dependencies": {
          "sharedlibrary": "file:../shared_library"
        }
      }
      ```
