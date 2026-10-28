<#
    VolumeControl 构建脚本
    ------------------------------------------------------------
    功能：
      1. 生成多尺寸音量喇叭图标 assets\icon.ico
      2. 准备 Ahk2Exe 编译器（tools\Ahk2Exe，缺失时自动下载）
      3. 编译 32 位通用版与 64 位版单文件 exe
    用法：在项目根目录执行
          powershell -ExecutionPolicy Bypass -File .\build.ps1
    说明：编译出的 exe 已内置 AutoHotkey 运行时，
          最终用户无需安装任何软件，双击即可运行。
#>

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

# 切换到脚本所在目录（项目根目录）
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

# ============================================================
# 第一步：生成图标
# ============================================================

# 在 256x256 画布上绘制蓝色圆角方块 + 白色喇叭与声波
function New-IconMaster {
    $S = 256
    $bmp = New-Object System.Drawing.Bitmap($S, $S)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode   = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    # 圆角方块背景（蓝色渐变）
    $r = 56
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc(0, 0, $r*2, $r*2, 180, 90)
    $path.AddArc($S-1-$r*2, 0, $r*2, $r*2, 270, 90)
    $path.AddArc($S-1-$r*2, $S-1-$r*2, $r*2, $r*2, 0, 90)
    $path.AddArc(0, $S-1-$r*2, $r*2, $r*2, 90, 90)
    $path.CloseFigure()
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point(0, 0)),
        (New-Object System.Drawing.Point($S, $S)),
        [System.Drawing.ColorTranslator]::FromHtml("#3E8EFE"),
        [System.Drawing.ColorTranslator]::FromHtml("#1B5FD8"))
    $g.FillPath($bgBrush, $path)

    # 白色喇叭
    $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    # 音箱手柄（小矩形，略微圆角）
    $handlePath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $hr = 8
    $hx, $hy, $hw, $hh = 48, 106, 44, 44
    $handlePath.AddArc($hx, $hy, $hr*2, $hr*2, 180, 90)
    $handlePath.AddArc($hx+$hw-$hr*2, $hy, $hr*2, $hr*2, 270, 90)
    $handlePath.AddArc($hx+$hw-$hr*2, $hy+$hh-$hr*2, $hr*2, $hr*2, 0, 90)
    $handlePath.AddArc($hx, $hy+$hh-$hr*2, $hr*2, $hr*2, 90, 90)
    $handlePath.CloseFigure()
    $g.FillPath($white, $handlePath)
    # 喇叭口（多边形）
    $cone = New-Object System.Drawing.Drawing2D.GraphicsPath
    $cone.AddPolygon(@(
        (New-Object System.Drawing.PointF(92, 106)),
        (New-Object System.Drawing.PointF(158, 58)),
        (New-Object System.Drawing.PointF(158, 198)),
        New-Object System.Drawing.PointF(92, 150)
    ))
    $g.FillPath($white, $cone)

    # 两条声波弧线
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 13)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
    $cx, $cy = 150, 128
    $g.DrawArc($pen, ($cx-30), ($cy-30), 60, 60, -50, 100)
    $g.DrawArc($pen, ($cx-56), ($cy-56), 112, 112, -50, 100)

    $g.Dispose()
    return $bmp
}

# 把 256 主图高质量缩放为指定尺寸
function Resize-Bitmap($src, $size) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode   = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($src, 0, 0, $size, $size)
    $g.Dispose()
    return $bmp
}

# 将多张位图打包为单个 ICO（PNG 压缩，Windows Vista 及以上支持）
function Save-Icon($bitmaps, $outPath) {
    $pngList = @()
    foreach ($b in $bitmaps) {
        $ms = New-Object System.IO.MemoryStream
        $b.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
        $pngList += ,$ms
    }
    $fs = [System.IO.File]::Create($outPath)
    $bw = New-Object System.IO.BinaryWriter($fs)
    $bw.Write([UInt16]0)
    $bw.Write([UInt16]1)
    $bw.Write([UInt16]$bitmaps.Count)
    $offset = 6 + 16 * $bitmaps.Count
    for ($i = 0; $i -lt $bitmaps.Count; $i++) {
        $w = $bitmaps[$i].Width
        $h = $bitmaps[$i].Height
        $bw.Write([Byte]($(if ($w -ge 256) { 0 } else { $w })))
        $bw.Write([Byte]($(if ($h -ge 256) { 0 } else { $h })))
        $bw.Write([Byte]0)
        $bw.Write([Byte]0)
        $bw.Write([UInt16]1)
        $bw.Write([UInt16]32)
        $bw.Write([UInt32]$pngList[$i].Length)
        $bw.Write([UInt32]$offset)
        $offset += $pngList[$i].Length
    }
    foreach ($ms in $pngList) {
        $bw.Write($ms.ToArray())
        $ms.Dispose()
    }
    $bw.Close()
    $fs.Close()
}

Write-Host "==> [1/4] 生成图标 assets\icon.ico"
$master = New-IconMaster
$sizes = 16, 24, 32, 48, 64, 128, 256
$bitmaps = @()
foreach ($z in $sizes) {
    if ($z -eq 256) { $bitmaps += ,$master }
    else { $bitmaps += ,(Resize-Bitmap $master $z) }
}
Save-Icon $bitmaps (Join-Path $root "assets\icon.ico")
$master.Dispose()
foreach ($b in $bitmaps) { $b.Dispose() }
$pngMaster = New-IconMaster
$pngMaster.Save((Join-Path $root "assets\icon.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$pngMaster.Dispose()

# ============================================================
# 第二步：准备 Ahk2Exe 编译器（缺失时自动下载）
# ============================================================

$ahk2exeDir = Join-Path $root "tools\Ahk2Exe"
$ahk2exe = Join-Path $ahk2exeDir "Ahk2Exe.exe"
if (-not (Test-Path $ahk2exe)) {
    Write-Host "==> [2/4] 下载 Ahk2Exe 编译器"
    New-Item -ItemType Directory -Force -Path $ahk2exeDir | Out-Null
    $url = "https://github.com/AutoHotkey/Ahk2Exe/releases/download/Ahk2Exe1.1.37.02a2/Ahk2Exe1.1.37.02a2.zip"
    $tmpZip = Join-Path $env:TEMP "Ahk2Exe.zip"
    Invoke-WebRequest $url -OutFile $tmpZip -UseBasicParsing
    Expand-Archive -Path $tmpZip -DestinationPath $ahk2exeDir -Force
    Remove-Item $tmpZip
} else {
    Write-Host "==> [2/4] Ahk2Exe 已存在，跳过下载"
}

# ============================================================
# 第三步：定位 AutoHotkey v2 的 base 运行时文件
# ============================================================

# 依次在常见安装位置查找 v2 的 32/64 位运行时
$candidates = @(
    "C:\Program Files\AutoHotkey\v2",
    "C:\Program Files (x86)\AutoHotkey\v2"
)
$v2dir = $null
foreach ($c in $candidates) { if (Test-Path (Join-Path $c "AutoHotkey32.exe")) { $v2dir = $c; break } }
if (-not $v2dir) { throw "未找到 AutoHotkey v2，无法编译。请先安装 AutoHotkey v2。" }
$base32 = Join-Path $v2dir "AutoHotkey32.exe"
$base64 = Join-Path $v2dir "AutoHotkey64.exe"
Write-Host "==> [3/4] 使用 v2 运行时：$v2dir"

# ============================================================
# 第四步：编译两个 exe
# ============================================================

$srcAhk = Join-Path $root "src\VolumeHotkey.ahk"
$icon   = Join-Path $root "assets\icon.ico"
$dist   = Join-Path $root "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null

Write-Host "==> [4/4] 编译 32 位通用版与 64 位版"
$p1 = Start-Process -FilePath $ahk2exe -PassThru -Wait -WindowStyle Hidden -ArgumentList @(
    '/silent', '/in', "`"$srcAhk`"",
    '/out', "`"$(Join-Path $dist 'VolumeControl.exe')`"",
    '/base', "`"$base32`"",
    '/icon', "`"$icon`"")
if ($p1.ExitCode -ne 0) { throw "32 位编译失败" }

$p2 = Start-Process -FilePath $ahk2exe -PassThru -Wait -WindowStyle Hidden -ArgumentList @(
    '/silent', '/in', "`"$srcAhk`"",
    '/out', "`"$(Join-Path $dist 'VolumeControl-x64.exe')`"",
    '/base', "`"$base64`"",
    '/icon', "`"$icon`"")
if ($p2.ExitCode -ne 0) { throw "64 位编译失败" }

Write-Host "==> 构建完成，产物："
Get-ChildItem $dist | Select-Object Name, @{N='Size(KB)';E={[math]::Round($_.Length/1KB)}}
