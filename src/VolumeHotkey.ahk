; ============================================================
;  VolumeControl —— Windows 全局音量快捷键
;  作者   : csuwzw
;  主页   : https://github.com/csuwzw/VolumeControl
;  许可证 : MIT
;
;  快捷键：
;    Ctrl + Alt + ↑   音量增大（同时弹出系统音量浮窗）
;    Ctrl + Alt + ↓   音量减小（同时弹出系统音量浮窗）
;    Ctrl + Alt + ←   静音 / 取消静音（同时弹出系统音量浮窗）
;    Ctrl + Alt + →   打开系统音量合成器（sndvol.exe）
;
;  原理：脚本只向系统发送 Windows 标准的多媒体音量键
;  （VK_VOLUME_UP / DOWN / MUTE），与键盘上的实体音量键
;  效果完全一致，因此不依赖任何特定声卡或驱动，
;  兼容 Windows 7 / 8 / 8.1 / 10 / 11。
; ============================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; -------------------- 基础设置 --------------------

; 使用 SendInput 方式发送按键，速度快、不易被其他窗口拦截
SendMode "Input"

; 鼠标悬停在托盘图标上时的提示文字（`n 表示换行）
A_IconTip := "VolumeControl`nCtrl+Alt+方向键 控制音量"

; -------------------- 快捷键 --------------------

; Ctrl+Alt+↑：发送系统“音量增大”多媒体键，系统会自动弹出音量浮窗
^!Up::Send "{Volume_Up}"

; Ctrl+Alt+↓：发送系统“音量减小”多媒体键
^!Down::Send "{Volume_Down}"

; Ctrl+Alt+←：发送系统“静音切换”多媒体键
^!Left::Send "{Volume_Mute}"

; Ctrl+Alt+→：打开系统自带的音量合成器（可分别调节各程序音量）
^!Right::Run "sndvol.exe"

; -------------------- 托盘右键菜单 --------------------

; “开机自动启动”菜单项：点击后在启动文件夹创建/删除快捷方式
A_TrayMenu.Add("开机自动启动", ToggleAutoStart)

; “打开音量合成器”菜单项
A_TrayMenu.Add("打开音量合成器", (*) => Run("sndvol.exe"))

; 分隔线
A_TrayMenu.Add()

; “关于”菜单项
A_TrayMenu.Add("关于 VolumeControl", ShowAbout)

; “退出”菜单项
A_TrayMenu.Add("退出", (*) => ExitApp())

; 若已配置开机自启，菜单项前面打勾
if (IsAutoStart())
    A_TrayMenu.Check("开机自动启动")

; 双击托盘图标时执行“打开音量合成器”
A_TrayMenu.Default := "打开音量合成器"

; -------------------- 功能函数 --------------------

; 返回开机自启快捷方式的完整路径
; （A_Startup 为当前用户的“启动”文件夹，登录时自动运行其中的快捷方式）
AutoStartShortcutPath() {
    return A_Startup "\VolumeControl.lnk"
}

; 判断是否已配置开机自启（快捷方式存在即视为已配置）
IsAutoStart() {
    return FileExist(AutoStartShortcutPath())
}

; “开机自动启动”菜单回调：在启用 / 禁用之间切换
; 参数 menuItem 为被点击的菜单项对象，用于更新前面的勾选标记
ToggleAutoStart(menuItem, info) {
    if (IsAutoStart()) {
        ; 已启用 -> 删除快捷方式，取消勾选并气泡提示
        try FileDelete(AutoStartShortcutPath())
        menuItem.Uncheck()
        TrayTip("VolumeControl", "已取消开机自动启动", 1)
    } else {
        ; 未启用 -> 创建快捷方式，打勾并气泡提示
        CreateStartupShortcut()
        menuItem.Check()
        TrayTip("VolumeControl", "已设置开机自动启动", 1)
    }
}

; 在当前用户的启动文件夹中创建指向本程序的快捷方式
; 说明：编译为 exe 后，A_ScriptFullPath 指向 exe 本身；
;       以源码形式运行时则指向 .ahk 脚本。
CreateStartupShortcut() {
    shortcutPath := AutoStartShortcutPath()
    shell := ComObject("WScript.Shell")        ; 创建 WScript.Shell COM 对象
    shortcut := shell.CreateShortcut(shortcutPath)
    shortcut.TargetPath := A_ScriptFullPath    ; 快捷方式目标 = 本程序
    SplitPath(A_ScriptFullPath, , &workingDir) ; 取出程序所在目录
    shortcut.WorkingDirectory := workingDir    ; 设置工作目录
    shortcut.Description := "VolumeControl 音量快捷键"
    shortcut.Save()                            ; 写入 .lnk 文件
}

; “关于”菜单回调：弹出说明窗口
ShowAbout(menuItem, info) {
    MsgBox(
    (
    "VolumeControl v1.0.0`n`n"
    "Ctrl+Alt+↑  音量增大`n"
    "Ctrl+Alt+↓  音量减小`n"
    "Ctrl+Alt+←  静音切换`n"
    "Ctrl+Alt+→  音量合成器`n`n"
    "MIT License`ngithub.com/csuwzw/VolumeControl"
    ), "关于 VolumeControl", "Iconi")
}
