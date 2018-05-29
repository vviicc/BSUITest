# BSUITest

![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)
![Support](https://img.shields.io/badge/support-iOS%208%2B%20-blue.svg?style=flat)

## 介绍

为什么要开发这个工具？系统提供了UI自动化测试框架 `UI Testing`，但存在几个缺陷。

1. 必须连着真机跑，无法脱机运行

2. 要自己手写脚本代码

3. 没有提供回放与录制结果对比。

`BSUITest` 基于记录下每次的点击事件和时间点，无需编写测试脚本就可以直接在设备进行录制回放。并且提供了录制和回放期间录屏功能，根据录屏的截图进行回放和录制的对比，提供了方便的结果差异参考。

## Demo

`git clone` 本仓库，运行Example目录工程，注意：运行前先执行 `pod install`

截图

<img src="https://raw.githubusercontent.com/vviicc/BSUITest/master/Screenshot/s1.PNG" width="375">     <img src="https://raw.githubusercontent.com/vviicc/BSUITest/master/Screenshot/s2.PNG" width="375">

## 安装

推荐使用 [CocoaPods](https://cocoapods.org) 安装
```ruby
pod 'BSUITest'
```

如果只在Debug环境下使用
```ruby
pod 'BSUITest', :configurations => ['Debug']
```

要求：iOS 8+

**注意：因为使用了私有API，请提交审核前务必移除！** 可以注释pod `# pod 'BSUITest'`

## 使用

使用很简单，只需一行代码
```Objc
[[BSUITestManager sharedManager] setEnable:YES];
```

## 交流
有任何问题或想法，欢迎 PR 或 issue，请大神多多指点。


## 许可证

基于MIT许可证，请参看MIT文件。
