# Silhouette 桌面版第一步：登录功能说明

这次已经把默认 Flutter 计数器示例替换为可连接线上服务器的桌面登录程序。程序不是网页套壳，也没有使用 WebView；界面和网络逻辑都由 Flutter 原生桌面程序负责。

## 你现在可以看到什么

1. 启动程序后出现约 `460 x 650` 的小登录窗口。
2. 顶部 Silhouette Logo 会缓慢上下浮动，并带紫色柔光。
3. 右上角按钮可切换明暗主题，选择会保存在电脑上。
4. 可以用已有邮箱和密码登录，也可以切换到 `Sign up` 注册。
   注册现在分为资料和邮箱验证码两步，SMTP 配置方法见 `docs/EMAIL_VERIFICATION_SETUP.md`。
5. 点击“继续使用 Google”会打开系统默认浏览器。网页授权成功后回到软件，软件会自动完成登录。
6. 登录成功后窗口扩大到约 `1120 x 760`，进入聊天软件式主界面，并显示“登录成功，后续内容开发中”。
7. 登录令牌保存在 Windows 安全凭据存储中，下一次打开程序会自动恢复登录。

## 修改的客户端文件

### `lib/main.dart`

程序入口和总状态管理。它负责初始化 Windows 窗口、读取主题、恢复上次登录、在登录成功后扩大窗口，以及退出后恢复小窗口。

### `lib/services/auth_service.dart`

所有登录网络请求集中在这里：

- `emailAuth()` 调用服务器的邮箱登录或注册接口。
- `googleAuth()` 创建一次性授权请求，打开浏览器并等待结果。
- `restoreSession()` 使用安全存储中的令牌恢复登录。
- `logout()` 通知服务器注销并删除本机令牌。

以后修改服务器域名时，只需要改这里的 `_baseUrl`。

### `lib/ui/login_screen.dart`

登录小窗口的全部界面，包括动态 Logo、邮箱、密码、注册名称、Google 按钮、错误提示和明暗主题按钮。

### `lib/ui/main_shell.dart`

登录后的大窗口。左侧是正式聊天软件式导航和用户信息，右侧暂时显示开发中的占位内容。后续聊天室功能会在这个结构中继续开发。

### `lib/ui/theme.dart`

统一定义深紫色、黑色、浅色模式、输入框和主按钮样式。以后调整全软件视觉时应优先在这里修改。

### `assets/silhouette-mark.svg`

桌面客户端使用的矢量 Logo。矢量图放大不会模糊。

### `test/widget_test.dart`

第一条自动化测试，确认服务器返回的用户资料可以被程序正确解析。

## 服务器新增内容

网站服务器增加了这些接口：

- `POST /api/auth/profile`：网页用户修改显示名称并写入 `users.json`。
- `POST /api/desktop-auth/login`：桌面端邮箱登录。
- `POST /api/desktop-auth/signup`：桌面端注册。
- `POST /api/desktop-auth/start`：创建 Google 浏览器授权票据。
- `POST /api/desktop-auth/complete`：网页登录成功后确认票据。
- `GET /api/desktop-auth/poll`：桌面端等待并领取一次性令牌。

Google 密码和 Google 身份令牌不会进入桌面程序。软件只会获得 Silhouette 服务器签发的随机登录令牌。

## 在 VS Code 中运行

1. 打开 `C:\dev\Silhouette.code-workspace`。
2. 在 VS Code 顶部菜单选择“终端” -> “新建终端”。
3. 确认终端当前目录是 `C:\dev\silhouette_app`。
4. 输入：

```powershell
flutter pub get
flutter run -d windows
```

程序窗口出现后，可以直接测试登录。修改 Dart 文件并保存时，运行终端中按 `r` 可热重载。

## 检查和构建

开发过程中运行：

```powershell
dart format .
flutter analyze
flutter test
```

生成发布版：

```powershell
flutter build windows --release
```

构建结果位于：

```text
build\windows\x64\runner\Release\
```

当前阶段这个目录是可运行的发布程序，还不是单文件安装器。后续制作安装包时，会用 Inno Setup 把整个 Release 目录封装为 `.exe` 安装包。

## 安全说明

- 所有认证请求只连接 `https://chat.silh0uette.space`。
- 桌面令牌最长有效 30 天，退出时会在服务器撤销。
- Google 配对票据最长有效 10 分钟，只能成功领取一次。
- 本机令牌通过 `flutter_secure_storage` 保存，不写入普通配置文件。
- 本次只实现登录阶段，P2P 聊天和附件传输尚未加入桌面端。
