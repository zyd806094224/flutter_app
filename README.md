## 项目简介（flutter_app）

这是一个为企业级应用设计的 **Flutter 脚手架 / 种子工程**，主要目标是：

- 为 **Flutter 初学者** 提供结构清晰、可直接上手的示例工程  
- 为 **中小型项目** 提供可扩展的基础架构，减少重复搭建工作  
- 演示常见业务场景：启动页、底部 Tab、WebView 加载、网络请求（GET/POST）、MVVM 架构等  

工程已经帮你实现了一套完整的基础骨架，可以直接在此基础上扩展业务功能。

---

## 整体功能概览

- **启动页（Splash）**
  - App 启动时展示启动页，带 **2 秒倒计时**
  - 支持右上角 **“跳过 + 倒计时”** 按钮，点击后立即进入主页
  - 渐变背景 + 简单 Logo 和标题文案

- **主页面（Home + 底部导航）**
  - 使用 `BottomNavigationBar` 实现 **4 个 Tab 切换**
  - 每个 Tab 对应一个模块（Module1~Module4），适合作为不同业务功能入口

- **Module1：资讯列表 + 吸顶 + 分区 Tab**
  - 使用 **MVVM + Provider** 管理状态
  - 使用 `CustomScrollView + SliverPersistentHeader` 实现类似商城的：
    - 分区 Tab 吸顶
    - 列表滚动时 **自动高亮当前分区**
    - 点击分区 Tab，列表滚动到对应分区
  - 使用假数据模拟资讯卡片列表
  - 通过 `pull_to_refresh` 实现 **下拉刷新 + 上拉加载更多**
  - 点击卡片会通过路由跳转到公共 WebView 页面加载指定网页

- **Module2：WebView 模块**
  - 使用 `webview_flutter` 加载指定网页
  - 支持：
    - 页面标题动态显示
    - 加载进度条
    - Android 与 iOS 平台网络权限、HTTP 访问配置（适配 HTTP 非 HTTPS 场景）

- **公共 WebView 页面**
  - 独立的 `WebViewPage`，可通过路由传入：
    - `url`：要加载的网页地址
    - `title`：可选标题（不传则从网页获取）
  - 任何页面可以通过 `AppRouter.pushWebView` 快速跳转并加载任意网页

- **Module3：网络请求示例（GET + POST）**
  - 演示如何在 MVVM 中调用封装好的 **Dio 网络模块**
  - 提供两个测试按钮：
    - `GET /user/test`
    - `POST /user/login`（带参数 `{ no: 'zhangsan', password: '123456' }`）
  - 请求状态 (`loading`) 与结果文案 (`resultMessage`) 全部通过 ViewModel 管理，并在页面上展示

- **Module4：预留模块**
  - 简单文字 + 图标展示，作为后续功能开发的占位模块

---

## 技术栈与架构设计

### 1. 状态管理与架构模式

- **架构模式：MVVM**
  - `views/`：页面 / 组件（View 层）
  - `viewmodels/`：业务逻辑与状态（ViewModel 层）
  - `models/`：数据模型（Model 层）
- **状态管理：Provider**
  - 通过 `ChangeNotifier` + `ChangeNotifierProvider` + `Consumer` 实现
  - 示例：
    - 启动页：`SplashView` + `SplashViewModel`
    - 首页：`HomeView` + `HomeViewModel`
    - Module1~Module4：各自对应的 View + ViewModel

> 对初学者友好：逻辑与 UI 分离清晰，每个页面一个独立 ViewModel，便于理解与维护。

### 2. 路由管理：go_router

- 使用 `go_router` 作为路由框架，提供：
  - 声明式路由表
  - 命名路由
  - `go` / `push` 两种导航方式
- 路由入口：`lib/routes/app_router.dart`
  - `/splash`：启动页
  - `/home`：主页面（包含子路由 module1~module4）
  - `/webview`：公共 WebView 页面（通过 `url` + `title` 参数加载网页）
- 封装了便捷方法：
  - `AppRouter.goToHome(context)`
  - `AppRouter.goToModule1(context)` 等
  - `AppRouter.goToWebView(...) / pushWebView(...)`

### 3. 网络层封装：Dio

> 目标：**企业级可扩展网络层**，开箱即用，便于后续扩展认证、日志、环境切换等。

- 相关目录：`lib/network/`

#### 3.1 请求配置（环境 & 超时）

- `request_config.dart`
  - 使用 `Environment` 枚举管理环境：`dev / qa / prod`
  - 为不同环境配置 Base URL（你已改成自己的开发地址）
  - 统一设置：
    - 连接超时
    - 发送超时
    - 接收超时
  - 提供 `createBaseOptions()` 供 Dio 使用

#### 3.2 通用响应模型

- `api_response.dart`
  - 约定接口返回格式为：
    - `{"code": 0, "message": "success", "data": ...}`
  - 提供：
    - `isSuccess` 判断
    - 泛型 `data` 解析能力

#### 3.3 异常统一处理

- `network_exceptions.dart`
  - 将 `DioError` 统一转换为 `NetworkException`
  - 涵盖：
    - 超时
    - 连接失败
    - 服务器错误（4xx/5xx）
    - 请求取消
    - 未知错误
  - 对初学者友好：UI 层只需要展示 `e.message` 即可。

#### 3.4 拦截器设计

- `interceptors/header_interceptor.dart`
  - 统一添加公共请求头：
    - `Accept-Language`（语言）
    - `App-Version`（应用版本）
    - `Platform`（平台标识）
- `interceptors/log_interceptor.dart`
  - 使用 `dart:developer` 的 `log` 统一打印：
    - 请求方法、URL、header、body
    - 响应状态码、数据
    - 错误信息与堆栈
- `interceptors/token_interceptor.dart`
  - 负责：
    - 在请求头中写入 `Authorization: Bearer <token>`
    - 当返回 `401` 时尝试调用 `refreshTokenHandler` 刷新 Token（示例结构已写好，待接入真实接口）
    - 避免并发刷新导致多次重复请求

#### 3.5 DioClient 单例封装

- `dio_client.dart`
  - 统一维护 `Dio` 实例（单例）
  - 设置 BaseOptions + 拦截器
  - 对外暴露简单易用的 API：
    - `get<T>()`
    - `post<T>()`
  - 内部统一解析 `ApiResponse<T>`，统一抛出 `NetworkException`，调用方代码非常简洁。

### 4. WebView 体系

- 使用 `webview_flutter` 实现多平台 WebView（Android + iOS）
- Android 侧：
  - `AndroidManifest.xml` 中添加：
    - `INTERNET` 权限
    - `usesCleartextTraffic="true"`（允许 HTTP，适用于开发环境）
  - `minSdkVersion` 提升至 19，满足插件要求
- iOS 侧：
  - `Podfile` 设置 `platform :ios, '12.0'`
  - `Info.plist` 添加 `NSAppTransportSecurity`，允许 HTTP（开发调试用）
- 公共 WebView 页面可复用：
  - `WebViewViewModel` 管理加载状态、标题、进度、导航状态
  - `WebViewPage` 负责展示 UI、处理进度条、错误遮罩

### 5. 刷新与列表交互

- 使用 `pull_to_refresh` 实现：
  - 下拉刷新
  - 上拉加载更多
- Module1 示例：
  - `SmartRefresher + CustomScrollView + SliverList` 组合
  - 吸顶 Tab + 多分区列表 + 加载更多业务逻辑全部打通

---

## 目录结构简要说明

```text
lib/
  main.dart                // 应用入口，配置主题与路由
  routes/
    app_router.dart        // 全局路由配置（go_router）
  views/                   // View 层（页面UI）
    splash/                // 启动页
    home/                  // 主页面（底部导航）
    module1/               // 模块1 - 资讯列表 + 吸顶Tab
    module2/               // 模块2 - WebView 页面
    module3/               // 模块3 - 网络请求示例
    module4/               // 模块4 - 预留模块
    webview/               // 公共WebView页面
  viewmodels/              // ViewModel 层（业务逻辑）
    splash/
    home/
    module1/
    module2/
    module3/
    module4/
    webview/
  models/                  // 数据模型（如 NewsArticle）
  network/                 // 网络层封装（Dio + 拦截器 + 异常）
```

---

## 给你的下一步建议（作为初学者）

1. **先从 Module1 / Module3 看起**
   - Module1：理解列表、吸顶、刷新、分页
   - Module3：理解 GET / POST 请求、异常处理与 UI 绑定
2. **尝试接入真实接口**
   - 修改 `request_config.dart` 中的 `baseUrl`
   - 在 `Module3ViewModel` 中把 `/user/test`、`/user/login` 换成真实接口
3. **根据业务拆分更多 Module**
   - 在 `home_view.dart` 中增加更多 Tab
   - 在 `routes/app_router.dart` 中增加对应路由
4. **逐步引入更多企业级能力（可选）**
   - 本地缓存（如 shared_preferences / hive）
   - 全局异常上报（如 Sentry）
   - 多环境配置（开发 / 测试 / 灰度 / 生产）

这个种子工程已经为你打好了一套相对完整的基础架构，可以直接在此基础上快速开发你的业务功能。祝你玩得开心，也欢迎你在此项目上不断尝试和练习。  
