# Silhouette Windows 开发教程（完全零基础版）

这是一份操作手册。看不懂术语时不要跳过，也不要一次复制十个文件。每一课都要先达到“验收条件”，再进行下一课。

## 你正在开发什么

Silhouette Windows 是一个真正的 Windows 原生客户端，不是网页，也不是 Electron。

它由四部分组成：

```text
界面：用户看到和点击的内容
业务逻辑：创建房间、发送消息、显示状态
网络：HTTPS、WebSocket、WebRTC
安全：加密、密钥、安全存储
```

软件运行时的数据流：

```text
你的 Windows 客户端
  ├─ HTTPS -> Silhouette 服务器：登录、一次性密文、配置
  ├─ WebSocket -> Silhouette 服务器：只交换 P2P 连接信息
  └─ WebRTC -> 对方设备：聊天文字、附件、已读回执
```

## 第一部分：先认识工具

### 1. VS Code 是什么

VS Code 是你写代码的地方。它不是编译器。真正负责编译的是 Flutter、Dart、Visual Studio C++ 工具链。

界面主要区域：

- 左侧文件图标：项目文件。
- 左侧放大镜：全项目搜索。
- 左侧分叉图标：Git 源代码管理。
- 左侧播放图标：运行与调试。
- 左侧方块图标：扩展。
- 下方“终端”：输入命令。
- 下方“问题”：显示代码错误。

### 2. 打开正确的工作区

双击：

```text
C:\dev\Silhouette.code-workspace
```

左侧最上方应该显示：

```text
SILHOUETTE WINDOWS
```

如果打开的是网站项目或空窗口：

1. 点击“文件”。
2. 点击“打开工作区”。
3. 选择 `C:\dev\Silhouette.code-workspace`。

### 3. 安装扩展

点击左侧“扩展”，搜索并安装：

```text
Flutter
发布者：Dart Code
扩展 ID：Dart-Code.flutter
```

它会自动安装 Dart 扩展。然后重启 VS Code。

安装成功的判断方法：

1. 打开 `lib/main.dart`。
2. 右下角能看到 `Dart` 和设备信息。
3. 按 `Ctrl+Shift+P`。
4. 输入 `Flutter: Run Flutter Doctor`。
5. 能找到这个命令。

### 4. 什么是终端

在 VS Code 顶部点击：

```text
终端 -> 新建终端
```

提示符应该位于：

```text
PS C:\dev\silhouette_app>
```

如果不在这个目录，输入：

```powershell
cd C:\dev\silhouette_app
```

终端命令输入后按 Enter 执行。不要把命令输入到 Dart 文件里。

## 第二部分：学会运行程序

### 5. 第一次运行

在终端输入：

```powershell
flutter pub get
flutter run -d windows
```

解释：

- `flutter pub get`：下载项目依赖。
- `flutter run`：编译并运行。
- `-d windows`：指定运行 Windows 版。

第一次编译可能需要几十秒。看到 Windows 示例窗口表示成功。

### 6. 使用 F5 调试

1. 点击左侧“运行和调试”。
2. 顶部选择 `Silhouette - Windows Debug`。
3. 按 F5。

停止程序：

- 点击调试工具条红色方块；或者
- 在运行程序的终端按 `q`。

不要直接结束 VS Code 进程，这会让你分不清程序是否正常退出。

### 7. 热重载

程序运行时修改 Dart UI 文件并按 `Ctrl+S`，Flutter 通常会立即刷新界面，这叫热重载。

以下修改通常不能只靠热重载：

- Windows C++ 文件。
- 安装新插件。
- 修改程序入口初始化。
- 修改系统权限。

遇到这种情况，先停止程序，再重新按 F5。

## 第三部分：理解最少量的 Dart

### 8. 变量

```dart
final roomName = '未命名聊天室';
var connected = false;
const maxFileSize = 10 * 1024 * 1024;
```

- `final`：赋值一次，运行时确定。
- `var`：以后可以修改。
- `const`：编译时常量。

安全相关的值默认使用 `final`，不要到处使用可修改的全局变量。

### 9. 函数

```dart
String greeting(String name) {
  return '你好，$name';
}
```

含义：函数接收一个字符串 `name`，返回一个字符串。

异步函数：

```dart
Future<void> connect() async {
  await signalingClient.connect();
}
```

网络和文件操作通常是异步的。漏写 `await` 可能造成界面显示“已完成”，实际还没完成。

### 10. 类

```dart
class RoomRecord {
  RoomRecord({required this.id, required this.name});

  final String id;
  final String name;
}
```

类可以理解为一种数据模板。每个聊天室记录都是一个 `RoomRecord` 对象。

### 11. null

```dart
String? displayName;
```

问号表示它允许为空。没有问号的变量必须有值。

不要为了消除错误随便加 `!`。`value!` 的意思是“我保证它不为空”，保证错误会导致程序崩溃。

## 第四部分：理解 Flutter

### 12. Widget 是什么

Flutter 里几乎所有界面元素都是 Widget：

- `Text`：文字。
- `Icon`：图标。
- `Row`：横向排列。
- `Column`：纵向排列。
- `Padding`：内边距。
- `Container`：可设置尺寸和装饰的容器。
- `Scaffold`：页面骨架。

示例：

```dart
Column(
  children: [
    Text('Silhouette'),
    Text('Private by design'),
  ],
)
```

### 13. StatelessWidget 和 StatefulWidget

`StatelessWidget`：显示内容不由自身修改。

`StatefulWidget`：内部状态会改变。

项目最终使用 Riverpod 管理状态，所以大多数页面可以保持为 `ConsumerWidget`，不要让每个组件各自维护一份连接状态。

### 14. BuildContext

`BuildContext` 表示当前 Widget 在界面树中的位置。它可用于读取主题、语言和导航。

不要把 `BuildContext` 长时间保存到 service 中，也不要在异步操作结束后直接使用已经销毁的页面 context。

## 第五部分：每次修改的标准流程

### 15. 修改前

```powershell
git status
```

正常情况下应显示：

```text
On branch main
nothing to commit, working tree clean
```

为新功能创建分支：

```powershell
git switch -c feature/app-shell
```

不要直接在 `main` 上长期开发复杂功能。

### 16. 修改后

```powershell
dart format .
flutter analyze
flutter test
```

三条命令必须成功。

然后：

```powershell
git status
git diff
git add .
git commit -m "Build native application shell"
```

提交信息要说明做了什么，不要写 `update`、`test`、`123`。

### 17. 报错时怎么做

按这个顺序：

1. 只看第一条红色错误。
2. 找到文件路径和行号。
3. 不要同时修改十个地方。
4. 修复第一条后重新运行 `flutter analyze`。
5. 不要删除自己看不懂的安全代码来让编译通过。

把错误发给协作者时包含：

- 你执行的完整命令。
- 从第一条错误开始的完整输出。
- 修改过的文件。
- 你期望发生什么。
- 实际发生什么。

## 第六部分：Silhouette 的实际开发顺序

### 18. 第一阶段：原生外壳

目标：不接服务器，先完成稳定界面。

建立页面：

```text
HomePage
MessagePage
UrlPage
ChatCreatePage
ChatRoomPage
SettingsPage
```

需要完成：

- 左侧或顶部导航。
- 深色与浅色主题。
- 中文和英文。
- Windows 窗口最小尺寸。
- Silhouette Logo 和应用图标。
- 自适应宽度。

验收：

- 窗口缩小时没有黄黑溢出条。
- 125%、150%、200% 系统缩放正常。
- 所有按钮都能键盘 Tab 聚焦。
- 文本不会被裁切。

### 19. 第二阶段：项目架构

创建目录：

```text
lib/core
lib/features/auth
lib/features/message
lib/features/url_share
lib/features/chat
```

职责：

- `presentation`：页面和 Widget。
- `data`：数据模型和 repository。
- `services`：网络、WebRTC、文件传输。
- `core`：共享配置、加密、主题和基础网络。

界面文件中不要直接写 WebSocket 连接代码。

### 20. 第三阶段：设置持久化

先保存非敏感设置：

- 主题。
- 语言。
- 窗口尺寸。

使用 `shared_preferences`。

敏感内容以后使用 `flutter_secure_storage`，不要把密钥放进普通偏好设置。

### 21. 第四阶段：HTTPS API

创建统一 `ApiClient`：

```text
GET  /api/config
GET  /api/auth/me
POST /api/auth/signup
POST /api/auth/login
POST /api/auth/logout
POST /api/secrets
GET  /api/secrets/:id
GET  /api/ice
```

每个请求必须处理：

- 加载中。
- 成功。
- 网络不可用。
- 超时。
- 服务器错误。
- 返回格式错误。

不要在 UI 中直接调用 `http.get`。

### 22. 第五阶段：WebSocket 信令

WebSocket 只传：

- join
- offer
- answer
- ICE candidate
- peer joined/left

绝对不能传：

- 聊天正文。
- 附件内容。
- 房间密钥。

先写假的 UI 日志验证信令顺序，再加入 WebRTC。

### 23. 第六阶段：WebRTC

每个参与者对应一个 `RTCPeerConnection`。每个连接建立一个名为 `silhouette` 的 DataChannel。

连接状态机：

```text
idle
connecting
connected
disconnected
failed
closed
```

UI 只订阅状态，不直接控制底层 peer connection。

### 24. 第七阶段：加密消息

发送流程：

```text
用户输入
  -> 创建 messageId
  -> 生成新的 12 字节 nonce
  -> AES-256-GCM 加密
  -> DataChannel 发送
  -> 本地显示单勾
```

接收流程：

```text
收到密文
  -> 验证并解密
  -> 验证数据包字段
  -> 显示消息
  -> 页面前台且消息可见
  -> 加密发送 read 回执
```

解密失败时丢弃数据包，不要尝试显示部分内容。

### 25. 第八阶段：附件

附件最大 10 MB，按 48 KB 分块。必须实现：

- 文件元数据。
- 分块序号。
- 总块数。
- SHA-256。
- 发送进度。
- 接收进度。
- 中断状态。
- 完成后系统保存对话框。

不要一次把多个 10 MB 文件全部放进内存。

### 26. 第九阶段：聊天室列表

保存：

- 房间 ID。
- 用户自定义名称。
- 创建或加入。
- 到期时间。
- 最近打开时间。

不保存聊天正文。

房间密钥放入 Windows 安全存储，普通列表只保存密钥的引用 ID。

### 27. 第十阶段：Message 和 URL

客户端本地生成密钥和密文，只把密文上传服务器。分享链接 `#` 后存放密钥。

必须测试：

- 有效期。
- 查看次数。
- 延迟揭示。
- IP 限制。
- 错误密钥。
- 已销毁内容。

### 28. 第十一阶段：Google 登录

Windows 客户端通过系统默认浏览器登录。不要内嵌 Google 登录页。

流程需要服务器提供一次性票据，票据只能使用一次且最多有效 60 秒。

这一步必须在邮箱登录和 P2P 稳定后再做。

## 第七部分：GitHub

### 29. 第一次发布

1. 点击 VS Code 左侧源代码管理。
2. 点击 `Publish Branch`。
3. 登录 GitHub。
4. 仓库名填写 `silhouette-windows`。
5. 初期选择 Private。
6. 确认发布。

GitHub 不应该包含：

- `.env`。
- Firebase 服务端 Secret。
- Cloudflare Secret。
- 服务器 root 密码。
- 房间链接和用户数据。
- `build` 目录。
- 签名证书。

### 30. 日常推送

```powershell
git status
git add .
git commit -m "Describe the change"
git push
```

GitHub Actions 会自动执行格式检查、分析、测试和 Windows Release 构建。

红色叉号表示检查失败，不要忽略后继续发布。

## 第八部分：安装包

### 31. Release 构建

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

输出：

```text
build\windows\x64\runner\Release
```

不能只发送 EXE，Flutter 运行还需要同目录 DLL 和 data 文件夹。

### 32. Inno Setup

安装 Inno Setup 后，用 `installer/silhouette.iss` 把整个 Release 目录封装成安装包。

正式公开发布前必须：

- 修改默认图标。
- 设置产品版本。
- 测试安装、升级和卸载。
- 在全新 Windows 用户中测试。
- 给 EXE 和安装包做代码签名。

## 最重要的原则

1. 一次只做一个功能。
2. 每一步都运行和测试。
3. 不懂的代码不要直接删。
4. 不把密钥和密码提交到 GitHub。
5. UI 不直接控制网络。
6. WebSocket 不传聊天内容。
7. 解密失败就拒绝数据。
8. `main` 分支永远保持可编译。

## 现在应该做什么

当前只做以下五件事：

1. 安装 VS Code Flutter 扩展。
2. 打开 `C:\dev\Silhouette.code-workspace`。
3. 按 F5 运行示例程序。
4. 确认窗口可以正常打开。
5. 阅读本教程第 1 至 17 节。

不要立即开始 WebRTC。下一项开发任务是建立 `feature/app-shell` 分支，然后把计数器示例替换为 Silhouette 原生应用外壳。
