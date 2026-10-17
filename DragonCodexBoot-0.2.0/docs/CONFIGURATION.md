# 配置说明

运行目录中的 `launcher.json` 是实际配置；`config/launcher.example.json` 是公开模板。

| 字段 | 含义 |
| --- | --- |
| `DisplayName` | 播放窗口的显示名 |
| `Video` | 本地 MP4，相对路径以可执行文件目录为基准，也可写绝对路径 |
| `AppLaunch` | 已安装客户端的 `shell:AppsFolder\包族名!应用ID` |
| `ProcessNames` | 客户端进程名列表，不带 `.exe` |
| `ProcessPathContains` | 可执行文件路径中必须出现的字符串，用来区分同名进程 |
| `HoldAt` | 客户端未就绪时暂停视频的位置，单位秒 |
| `TransitionStart` / `TransitionEnd` | 真实界面淡入与填满窗口的起止秒数 |
| `MaxWaitSeconds` | 等待预算；当前实现达到 `MaxWaitSeconds + 20` 秒总墙钟时间后结束 |
| `Volume` | 0–1 音量 |
| `PlayerWidth` / `PlayerHeight` | 固定播放窗口的物理像素尺寸 |
| `MatchClientToPlayer` | 是否将真实客户端客户区对齐到播放窗口 |
| `AutoReplaceEntrypoints` | 首次运行自动替换可识别的启动快捷方式，默认 `true`；启动前设为 `false` 可关闭 |
| `ScanAllLocalDrives` | 除桌面、开始菜单和快速启动目录外，也扫描本地固定磁盘，默认 `true`；设为 `false` 仅扫描这些常用目录 |
| `ScreenFrames` | 视频中屏幕区域的矩形关键帧 |

## 找到本机客户端标识

```powershell
Get-StartApps | Where-Object { $_.Name -match 'ChatGPT|Codex' }
```

示例配置使用 `OpenAI.Codex_2p2nqsd0c76g0!App`。这来自项目开发机，不保证每个发行渠道都相同；用本机实际结果更新 `AppLaunch`。进程名和路径过滤也要与实际安装匹配。

## 校准视频中的屏幕

`ScreenFrames` 使用画面归一化坐标，不是显示器坐标：

```json
{"Time":12.65,"X":0.123,"Y":0.094,"Width":0.736,"Height":0.725}
```

对于 1920×1080 的帧，左上角约为 `(236, 102)`，屏幕大小约为 `(1413, 783)`。

1. 在过渡开始附近截取视频帧，测量应替换为真实界面的内屏幕边界。
2. 用 `X = 左边像素/视频宽度`、`Y = 顶边像素/视频高度`，宽高同样归一化。
3. 随着屏幕放大，增加时间递增的关键帧。
4. 最后一个关键帧应覆盖画面：`X=0, Y=0, Width=1, Height=1`。

坐标不能为负，矩形不能超出画面；时间必须严格递增。仅支持轴对齐矩形，不能透视贴合倾斜的四边形。中间矩形线性插值，整体淡入和最终填满采用平滑曲线。

## 调整时间

必须满足 `0 < HoldAt < TransitionStart < TransitionEnd`。视频应长于 `TransitionEnd`，并在等待节点留一个适合停住的动作。默认节点为闭眼阶段。

用自己的视频必须同时重新测量时间与矩形。短视频沿用 14 秒模板，可能在真正过渡开始前就播放结束。

## 小屏幕

例如 1366×768 显示器可改为：

```json
"PlayerWidth": 1280,
"PlayerHeight": 720
```

物理像素大小不随 Windows 缩放比例变化。首版有意保留固定尺寸行为，不自动缩小超出显示器的播放器。
