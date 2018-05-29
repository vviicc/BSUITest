# BSUITest

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)]
[![Platform](https://img.shields.io/cocoapods/p/BSUITest.svg?style=flat)](https://cocoapods.org/pods/BSUITest)

## 介绍

为什么要开发这个工具？苹果官方有提供 `UI Testing` UI自动化测试框架，但是存在如下几个问题：1.要连着真机跑，无法脱机运行 2.需要自己写测试脚本代码 3.没有提供回放与录制比较。`BSUITest`通过记录点击事件和点击时机实现不用写UI测试脚本便可实现测试用例录制回放功能，在录制和回放期间录屏并输出两者的截图相似度可作为测试结果参考。

## Demo
`git clone`这个仓库，运行example下工程即可，请先`pod install`

截图


## 安装

推荐使用 [CocoaPods](https://cocoapods.org)
```ruby
pod 'BSUITest'
```

如果是只在Debug环境使用
```ruby
pod 'BSUITest', :configurations => ['Debug']
```

要求：iOS8+

## 注意

**因为使用到了私有API，提交上架前务必移除！**可以注释掉pod`# pod 'BSUITest'`

## 使用
使用很简单，只需一行代码
```Objective C
[[BSUITestManager sharedManager] setEnable:YES];
```
## 交流
遇到任何问题，欢迎提交 PR 或者 issue，欢迎大神们多指点。

## 许可证

使用 MIT 许可证，见 LICENSE 文件。
