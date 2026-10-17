# Dragon Codex Boot Custom

这是一个基于 [dragon-codex-boot](https://github.com/yushua0808-cpu/dragon-codex-boot) 的个人定制版本：启动 Codex 时先播放白紫色龙娘动画，等待客户端准备完成，再把真实 Codex 窗口平滑接入动画。

## 当前版本

- Windows 10/11 x64
- 启动器：`.NET Framework 4.8` WPF 程序
- 视频：`DragonCodexBoot-0.2.0/media/startup.mp4`
- 视频规格：1280×720、24 fps、约 15.04 秒
- 交接停留点：11.3 秒
- 交接开始：12.3 秒
- 交接完成：14.7 秒
- 快捷方式图标：`DragonCodexBoot-0.2.0/media/dragon-codex.ico`

## 运行

进入 `DragonCodexBoot-0.2.0`，双击 `DragonCodexBoot.exe`。程序会播放本地启动动画，等待 Codex 客户端出现，并在动画结尾把真实窗口接入。

如果要使用自己的动画，可以替换 `media/startup.mp4`，然后根据视频重新调整 `launcher.json` 中的 `HoldAt`、`TransitionStart`、`TransitionEnd` 和 `ScreenFrames`。视频最好使用 16:9 的 MP4，编码建议为 H.264 视频和 AAC 音频。

## 快捷方式

项目使用可恢复的 `.lnk` 快捷方式入口。移动或删除启动器目录前，请先运行 `Restore-Original-Entrypoints.cmd`。如果不希望自动处理快捷方式，可在 `launcher.json` 中将 `AutoReplaceEntrypoints` 改为 `false`。

## 项目文件

```text
PROJECT_JOURNEY.md                         本次定制过程记录
DragonCodexBoot-0.2.0/DragonCodexBoot.exe 启动器
DragonCodexBoot-0.2.0/launcher.json        启动和交接配置
DragonCodexBoot-0.2.0/media/startup.mp4   白紫龙娘开屏动画
DragonCodexBoot-0.2.0/media/dragon-codex.ico 快捷方式图标
DragonCodexBoot-0.2.0/scripts/             导入动画和快捷方式脚本
```

## 授权说明

启动器代码沿用原项目的许可证和说明。当前视频、角色图和自定义图标是本次定制素材，公开分发前请确认拥有相应的使用和传播权。
