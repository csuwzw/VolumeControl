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
^!Right::OpenMixer()

; -------------------- 托盘右键菜单 --------------------

; 清空 AutoHotkey 自带的英文菜单项（Open / Help / Window Spy /
; Edit This Script 等对最终用户没有意义），换成统一的中文菜单
A_TrayMenu.Delete()

; “打开音量合成器”菜单项
A_TrayMenu.Add("打开音量合成器", OpenMixer)

; “开机自动启动”菜单项：点击后在启动文件夹创建/删除快捷方式
A_TrayMenu.Add("开机自动启动", ToggleAutoStart)

; “暂停快捷键”菜单项：临时关闭全局热键（例如热键与当前软件冲突时）
A_TrayMenu.Add("暂停快捷键", ToggleSuspend)

; 若已配置开机自启，菜单项前面打勾
if (IsAutoStart())
    A_TrayMenu.Check("开机自动启动")

; 分隔线
A_TrayMenu.Add()

; “关于”菜单项
A_TrayMenu.Add("关于 VolumeControl", ShowAbout)

; “退出”菜单项
A_TrayMenu.Add("退出", (*) => ExitApp())

; 双击托盘图标时执行“打开音量合成器”
A_TrayMenu.Default := "打开音量合成器"

; -------------------- 功能函数 --------------------

; 返回开机自启快捷方式的完整路径
; （A_Startup 为当前用户的“启动”文件夹，登录时自动运行其中的快捷方式）
AutoStartShortcutPath() {
    return A_Startup "\VolumeControl.lnk"
}

; 判断是否已配置开机自启
; 仅“快捷方式存在”还不够：如果用户之后移动或重命名了 exe，
; 旧快捷方式会指向一个不存在的路径，此时应视为未启用（点击后会重建）
IsAutoStart() {
    link := AutoStartShortcutPath()
    if !FileExist(link)
        return false

    try
        FileGetShortcut(link, &target)
    catch
        return false    ; 快捷方式损坏或无法读取

    return target = A_ScriptFullPath
}

; “开机自动启动”菜单回调
; 注意：菜单回调会收到 3 个参数（菜单项名称、位置、所属 Menu 对象），
; 第一个参数是字符串而不是菜单对象，所以勾选状态要通过 A_TrayMenu 设置
ToggleAutoStart(ItemName, ItemPos, *) {
    if IsAutoStart() {
        ; 已启用 -> 删除快捷方式，取消勾选并气泡提示
        try
            FileDelete AutoStartShortcutPath()
        catch as e {
            MsgBox "无法取消开机自动启动：`n" e.Message, "VolumeControl", "Iconx"
            return
        }
        A_TrayMenu.Uncheck(ItemName)
        TrayTip "已取消开机自动启动", "VolumeControl", 1
    } else {
        ; 未启用 -> 创建快捷方式，打勾并气泡提示
        try
            CreateStartupShortcut()
        catch as e {
            MsgBox "无法设置开机自动启动：`n" e.Message, "VolumeControl", "Iconx"
            return
        }
        A_TrayMenu.Check(ItemName)
        TrayTip "已设置开机自动启动", "VolumeControl", 1
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

; “暂停快捷键”菜单回调：关闭 / 恢复全部全局热键（托盘菜单本身不受影响）
ToggleSuspend(ItemName, ItemPos, *) {
    Suspend -1                     ; -1 表示在启用 / 暂停之间切换
    if A_IsSuspended {
        A_TrayMenu.Check(ItemName)
        TrayTip "快捷键已暂停，再次点击可恢复", "VolumeControl", 1
    } else {
        A_TrayMenu.Uncheck(ItemName)
        TrayTip "快捷键已恢复", "VolumeControl", 1
    }
}

; 打开系统音量合成器
; 绝大多数系统自带 sndvol.exe；个别精简系统没有时退回系统设置中的音量合成器页面
OpenMixer(*) {
    try
        Run "sndvol.exe"
    catch {
        try
            Run "ms-settings:appsvolume"
        catch as e
            MsgBox "无法打开音量合成器：`n" e.Message, "VolumeControl", "Iconx"
    }
}

; “关于”菜单回调：弹出说明窗口
ShowAbout(ItemName, ItemPos, *) {
    MsgBox(
    (
    "VolumeControl v1.0.1`n`n"
    "Ctrl+Alt+↑  音量增大`n"
    "Ctrl+Alt+↓  音量减小`n"
    "Ctrl+Alt+←  静音切换`n"
    "Ctrl+Alt+→  音量合成器`n`n"
    "MIT License`ngithub.com/csuwzw/VolumeControl"
    ), "关于 VolumeControl", "Iconi")
}
