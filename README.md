# nim-uts-sdk-demo

网易云信 IM `nim-uts-sdk`（UTS 插件）的 uni-app x 演示工程。一套代码可编译到 Android / iOS / 鸿蒙三端。

## 功能

- 初始化 `nim-uts-sdk` 并登录
- 发送文本 / 图片 / 语音 / 视频 / 文件消息
- 附件上传进度显示与取消上传
- 登录态、连接状态监听

## 开发者首次配置

拉到代码后，需要自行配置以下内容才能跑通：

### 0. 安装 nim-uts-sdk 插件（必装）

本仓库已将 `uni_modules/nim-uts-sdk` 加入 `.gitignore`，克隆后工程里**没有这个插件**，需自行安装：

在 HBuilderX 中打开本工程 → 右键 `uni_modules` → "从插件市场导入" → 搜索 `nim-uts-sdk` 安装；或直接访问 [DCloud 插件市场 nim-uts-sdk](https://ext.dcloud.net.cn/plugin?name=nim-uts-sdk) 导入到本工程。

### 1. 云信账号信息（必填）

打开 `pages/index/index.uvue`，页面首屏有几个输入框，默认值是带 `*` 的占位串（**不可直接用于登录**）：

| 输入框 | 默认占位 | 说明 |
| --- | --- | --- |
| appkey | `b94d****a720f` | 在[云信控制台](https://app.netease.im/)创建应用后获取 |
| 账号ID | `YOUR_ACCID` | 测试账号的 accid |
| 账号Token | `e10adc****f883e` | 对应 accid 的 token |
| 会话ID | `YOUR_ACCID\|1\|TARGET_ACCID` | 目标会话 ID，格式 `类型\|目标类型\|目标账号` |

填入真实值后点"登录"，**登录成功**才会把 appkey/token/accountId 写入本地存储；下次启动自动回填，无需重复输入。

> 本仓库不会把真实 appkey/token 提交进 git——它们只存在你本机的 `uni.getStorageSync` 里。

### 2. 鸿蒙运行配置（鸿蒙端必填）

`manifest.json` 的 `app-harmony.distribute.signingConfigs` 字段值已留空，需要本机生成：

1. 在 HBuilderX 顶部菜单登录 DCloud 账号。
2. 打开 `manifest.json` → `app-harmony` 配置页，点击"重新生成"调试证书（或直接"运行 → 运行到鸿蒙"，HBuilderX 会自动生成并回填 `certpath / profile / storeFile / keyPassword / storePassword`）。
3. `compatibleSdkVersion` 保持 `"5.0.5(17)"`：云信鸿蒙 SDK `@nimsdk/nim` 要求 `minCompatibleSdkVersion = 17`，低于 17 会报 `00306004 Specification Limit Violation`。
4. `bundleName` 默认 `uni.app.UNI1997414`，如需改成自己的包名，同时要在 AGC 控制台匹配对应证书。

### 3. Android / iOS

- Android：`manifest.json` 的 `app-android` 段用默认配置即可，无需额外证书（debug keystore 由 HBuilderX 自动管理）。
- iOS：首次运行需在 HBuilderX 里配置开发者证书 / profile。

## 运行

在 HBuilderX 中打开本工程：

- 运行 → 运行到 Android / iOS / 鸿蒙

首次运行鸿蒙前，建议清掉旧产物避免 profile 合并冲突：

```sh
rm -rf unpackage/dist/dev/app-harmony
```

## 目录结构

```
.
├── pages/index/index.uvue        # 演示页：初始化 + 登录 + 收发消息
├── uni_modules/nim-uts-sdk/      # 云信 IM UTS 插件（已被 .gitignore 忽略，见上方"安装 nim-uts-sdk 插件"）
│   ├── utssdk/
│   │   ├── app-android/          # Android 桥接
│   │   ├── app-ios/              # iOS 桥接
│   │   ├── app-harmony/          # 鸿蒙桥接
│   │   ├── index.d.ts            # 类型声明
│   │   └── interface.uts         # 跨端接口
│   └── readme.md                 # 插件使用说明（初始化/服务清单/命名差异）
├── manifest.json                 # 工程配置（签名信息需本机生成）
└── debug/                        # 本机调试备忘（已被 .gitignore 忽略，勿提交）
    └── harmony.md                # 鸿蒙真实运行配置 + 测试账号真值
```

## 进一步文档

- 插件初始化与服务清单：见 `uni_modules/nim-uts-sdk/readme.md`
- 云信 IM 客户端 API：https://doc.yunxin.163.com/messaging2/client-apis?platform=client
