# nim-uts-sdk-demo

网易云信 IM `nim-uts-sdk`（UTS 插件）的 uni-app x 演示工程。一套代码可编译到 Android / iOS / 鸿蒙三端。

## 功能

- 初始化 `nim-uts-sdk`
- 登录 / 登出 / 登录状态监听
- 用户、好友、本地会话、消息、群 5 个常用模块接口测试
- 页面底部展示接口调用和查询返回结果
- 页面顶部监听状态区域展示监听回调内容

## 开发者首次配置

拉到代码后，需要自行配置以下内容才能跑通：

### 0. 安装 nim-uts-sdk 插件（必装）

本仓库已将 `uni_modules/nim-uts-sdk` 加入 `.gitignore`，克隆后工程里**没有这个插件**，需自行安装：

在 HBuilderX 中打开本工程 → 右键 `uni_modules` → "从插件市场导入" → 搜索 `nim-uts-sdk` 安装；或直接访问 [DCloud 插件市场 nim-uts-sdk](https://ext.dcloud.net.cn/plugin?name=nim-uts-sdk) 导入到本工程。

### 1. 云信账号信息（必填）

打开 `pages/index/index.uvue`，修改 `DEMO_LOGIN_CONFIG`。其他使用者只需要改这里的 `appKey / accountId / token`：

```uts
const DEMO_LOGIN_CONFIG : DemoLoginConfig = {
	appKey: 'your yunxin appKey',
	accountId: 'login account id',
	token: 'login token'
}
```

| 字段 | 说明 |
| --- | --- |
| `appKey` | 在[云信控制台](https://app.netease.im/)创建应用后获取 |
| `accountId` | 测试账号的 accid |
| `token` | 对应 accid 的 token |

首页已拆成“初始化”和“登录”两块：先点击“初始化”，成功后再点击“登录”。页面输入框仍可临时修改配置。

> iOS uni-app-x 当前同步 Storage 桥接存在返回 `undefined` 抛错问题，Demo 在 iOS 下会跳过本地缓存写入。Android / Harmony 仍会通过 `uni.setStorageSync` 保存页面输入值。

### 2. 模块测试说明

登录成功后，可以从首页进入以下模块：

| 模块 | 说明 |
| --- | --- |
| 用户 | 获取用户列表、云端获取用户、搜索用户、更新自己资料、用户监听 |
| 好友 | 获取好友列表、按账号获取好友、添加好友、删除好友、好友监听 |
| 本地会话 | 获取会话列表、创建会话、删除会话、置顶会话、本地会话监听 |
| 消息 | 查询消息、创建文本消息、发送消息、消息监听 |
| 群 | 创建群、获取已加入群列表、获取群资料、获取群成员列表、群监听 |

列表类接口拉取成功后，会自动把第一条数据回填到后续操作使用的输入框。例如本地会话页获取会话列表后，会把第一条 `conversationId` 填入“会话 ID”，后续可以直接点击置顶或删除。

### 3. 鸿蒙运行配置（鸿蒙端必填）

`manifest.json` 的 `app-harmony.distribute.signingConfigs` 字段值已留空，需要本机生成：

1. 在 HBuilderX 顶部菜单登录 DCloud 账号。
2. 打开 `manifest.json` → `app-harmony` 配置页，点击"重新生成"调试证书（或直接"运行 → 运行到鸿蒙"，HBuilderX 会自动生成并回填 `certpath / profile / storeFile / keyPassword / storePassword`）。
3. `compatibleSdkVersion` 保持 `"5.0.5(17)"`：云信鸿蒙 SDK `@nimsdk/nim` 要求 `minCompatibleSdkVersion = 17`，低于 17 会报 `00306004 Specification Limit Violation`。
4. `bundleName` 默认 `uni.app.UNI1997414`，如需改成自己的包名，同时要在 AGC 控制台匹配对应证书。

### 4. Android / iOS

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
├── pages/index/index.uvue        # 首页：默认配置 + 初始化 + 登录 + 模块入口
├── pages/common/demo-utils.uts   # Demo 公共工具：输入框缓存封装
├── pages/user/user.uvue          # 用户模块常用接口
├── pages/friend/friend.uvue      # 好友模块常用接口
├── pages/local-conversation/     # 本地会话模块常用接口
├── pages/message/message.uvue    # 消息模块常用接口
├── pages/team/team.uvue          # 群模块常用接口
├── uni_modules/nim-uts-sdk/      # 云信 IM UTS 插件（已被 .gitignore 忽略，见上方"安装 nim-uts-sdk 插件"）
│   ├── utssdk/
│   │   ├── app-android/          # Android 桥接
│   │   ├── app-ios/              # iOS 桥接
│   │   ├── app-harmony/          # 鸿蒙桥接
│   │   ├── index.d.ts            # 类型声明
│   │   └── interface.uts         # 跨端接口
│   └── readme.md                 # 插件使用说明（初始化/服务清单/命名差异）
└── manifest.json                 # 工程配置（签名信息需本机生成）
```

## 进一步文档

- 插件初始化与服务清单：见 `uni_modules/nim-uts-sdk/readme.md`
- 云信 IM 客户端 API：https://doc.yunxin.163.com/messaging2/client-apis?platform=client
