<p align="center">
  <img src="assets/icon-v2.png" width="96" height="96" alt="VolumeControl">
</p>

<h1 align="center">VolumeControl</h1>

<p align="center">
  <b>简体中文</b> | <a href="README_EN.md">English</a>
</p>

<p align="center">
  给没有音量键的台式键盘，补上一组全局音量快捷键。<br>
  单个 exe，双击即跑，无需安装任何软件。
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Windows%207%20%7C%208%20%7C%208.1%20%7C%2010%20%7C%2011-blue" alt="platform">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="license">
</p>

---

## 这是什么

很多台式机键盘没有音量调节键，每次调音量都要伸手去点右下角的喇叭图标。

**VolumeControl** 用 `Ctrl + Alt + 方向键` 给你一组全局快捷键：在游戏、播放器、文档等大多数程序中都能直接调音量，并弹出系统自带的音量浮窗——和按下键盘上的实体音量键效果完全一样。

## 快捷键

| 快捷键 | 功能 |
| :--- | :--- |
| `Ctrl + Alt + ↑` | 音量增大（弹出系统音量浮窗） |
| `Ctrl + Alt + ↓` | 音量减小（弹出系统音量浮窗） |
| `Ctrl + Alt + ←` | 静音 / 取消静音（弹出系统音量浮窗） |
| `Ctrl + Alt + →` | 打开系统音量合成器（可分别调节各程序音量） |

## 快速开始

1. 到 [**Releases 页面**](https://github.com/csuwzw/VolumeControl/releases) 下载最新版本：
   - **`VolumeControl.exe`** —— 32 位版本，**可在 32 位和 64 位 Windows 上运行，通用性最好**，绝大多数用户下载这个即可。
   - **`VolumeControl-x64.exe`** —— 64 位原生版本，仅用于 64 位 Windows。
2. 双击运行，任务栏右下角会出现一个蓝色喇叭图标。
3. 按下 `Ctrl + Alt + 方向键` 即可调节音量。

> 程序只在后台运行，没有主窗口。想关闭或设置时，**右键点击任务栏右下角的喇叭图标**即可。

## 开机自动启动

两种方式任选：

- **方式一（推荐）**：右键任务栏喇叭图标 → 点击「**开机自动启动**」，菜单项前出现勾选即设置成功。程序会在系统启动文件夹中创建一个指向自己的快捷方式；再次点击可取消。
- **方式二**：按 `Win + R`，输入 `shell:startup` 回车，把 `VolumeControl.exe` 的快捷方式放进打开的文件夹中。

> 快捷方式记录的是 exe 的绝对路径。如果之后移动或重命名了 exe，重新点一次「开机自动启动」即可重建（菜单会自动识别失效的旧快捷方式）。

## 托盘菜单

右键任务栏右下角的喇叭图标可以打开菜单：

| 菜单项 | 说明 |
| :--- | :--- |
| 打开音量合成器 | 等同于 `Ctrl + Alt + →` |
| 开机自动启动 | 创建 / 删除启动文件夹中的快捷方式，已启用时前面有勾选 |
| 暂停快捷键 | 临时关闭全部全局热键（例如与其他软件的快捷键冲突时），再次点击恢复 |
| 关于 VolumeControl | 查看版本与快捷键说明 |
| 退出 | 退出程序 |

双击托盘图标等同于「打开音量合成器」。

## 工作原理

程序只做一件事：在你按下组合键时，向系统发送 **Windows 标准的多媒体音量键**（`VK_VOLUME_UP` / `VK_VOLUME_DOWN` / `VK_VOLUME_MUTE`），后续的音量调节、浮窗显示全部由 Windows 自己完成。

因此它：

- 不依赖任何特定声卡或驱动；
- 不直接读写音频参数，音量变化完全交给系统处理，行为与实体音量键一致；
- 编译后的 exe 已内置运行时，**最终用户无需安装 AutoHotkey 或其他任何软件**。

## 系统要求

- Windows 7 / 8 / 8.1 / 10 / 11（32 位或 64 位）。
- 32 位 exe 同时兼容 32 位与 64 位系统；64 位 exe 仅在 64 位系统上运行。

## 常见问题

**Q：按下 `Ctrl + Alt + 方向键` 没有反应？**

这组快捷键可能已被其他软件占用：

- **显卡的屏幕旋转快捷键**（常见于 Intel 核显）：打开「Intel 显卡控制中心 / 图形属性 → 选项与支持（或快捷键）」，关闭或修改「屏幕旋转」快捷键；或在显卡控制面板中禁用 `Ctrl + Alt + 方向键`，之后重新运行本程序。
- **编辑器 / IDE**：VS Code、IntelliJ IDEA 等默认用 `Ctrl + Alt + ↑/↓` 向上 / 向下添加光标。本程序注册的是全局热键，会优先占用这组组合键；需要临时使用时，右键托盘图标 → 「暂停快捷键」，用完再点一次恢复。

**Q：首次运行时被 SmartScreen 拦截（提示“Windows 已保护你的电脑”）？**

程序没有购买代码签名证书。确认 exe 来自本仓库的 Releases 页面后，点击「更多信息 → 仍要运行」即可。

**Q：双击 exe 后看不到窗口？**

这是正常的，程序设计为后台常驻，只在任务栏右下角显示一个蓝色喇叭图标。

**Q：如何彻底退出？**

右键任务栏喇叭图标 → 「退出」。

**Q：设置过开机自动启动，后来移动了 exe 的位置？**

快捷方式记录的是 exe 的绝对路径，移动后旧快捷方式会失效。重新点一次「开机自动启动」即可重建；菜单能识别失效的旧快捷方式，不会误显示为已启用。

## 从源码构建

源码是一个 AutoHotkey v2 脚本，位于 `src/VolumeHotkey.ahk`。安装 [AutoHotkey v2](https://www.autohotkey.com/) 后，在项目根目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
```

脚本会自动生成图标、按需下载 Ahk2Exe 编译器，并把 32 位与 64 位 exe 输出到 `dist/` 目录。

## 项目结构

```
VolumeControl/
├── src/
│   └── VolumeHotkey.ahk   # 源码（AutoHotkey v2）
├── assets/
│   ├── icon.ico           # 程序图标
│   └── icon-v2.png        # 图标（README 用）
├── tools/                 # 构建工具（Ahk2Exe 自动下载到此）
├── dist/                  # 编译输出（不进 git）
├── build.ps1              # 一键构建脚本
├── README.md              # 中文说明
├── README_EN.md           # English
├── LICENSE                # MIT
├── .gitignore
└── .gitattributes
```

## 安全与隐私

- 程序不收集任何数据，不联网，不写注册表，不安装服务。
- 「开机自动启动」仅在当前用户的启动文件夹中创建一个普通快捷方式。
- 卸载：右键图标「退出」，删除 exe 即可；若设置了开机启动，先在菜单中取消，或删除启动文件夹中的快捷方式。

## 许可证

[MIT](LICENSE) © csuwzw
