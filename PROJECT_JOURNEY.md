# Dragon Codex Boot：龙娘开屏动画项目历程

这是基于 `dragon-codex-boot` 的个人定制版本，用启动动画包装 Codex 客户端：先播放本地 MP4，等待客户端准备完成，再把真实客户端窗口平滑接入动画，最后把操作权交给 Codex。

## 我们完成的工作

1. 阅读并分析了原项目的启动流程、`launcher.json` 配置和屏幕交接机制。
2. 抽帧学习了项目自带的 1080p 龙娘演示视频，确认它的镜头结构：点击启动、角色出现、紫色数据流、软件界面展开、紫色圆环交接。
3. 使用白紫色龙娘开屏视频替换了默认 `media/startup.mp4`。
4. 校准了新视频的启动参数：
   - 视频：1280×720，24 fps，约 15.04 秒
   - `HoldAt`：11.3 秒
   - `TransitionStart`：12.3 秒
   - `TransitionEnd`：14.7 秒
   - `ScreenFrames`：从中间界面逐步扩大到全屏
5. 修复了桌面和开始菜单中的 `ChatGPT.lnk`：目标路径指向本项目启动器，图标改为自定义白紫龙娘图标。
6. 添加了 `media/dragon-codex.ico`，用于快捷方式图标，并验证了视频哈希、解码和交接时间参数。

## 项目使用

直接运行 `DragonCodexBoot-0.2.0/DragonCodexBoot.exe`，或使用已经修复的 ChatGPT 快捷方式。启动器会播放 `media/startup.mp4`，等待 Codex 客户端出现，然后完成窗口交接。

如果不想让启动器自动处理快捷方式，请在运行前把 `launcher.json` 中的 `AutoReplaceEntrypoints` 设为 `false`。移动或删除启动器目录前，应先恢复原始快捷方式。

## 当前文件

- `DragonCodexBoot-0.2.0/media/startup.mp4`：当前白紫龙娘开屏动画
- `DragonCodexBoot-0.2.0/media/dragon-codex.ico`：快捷方式图标
- `DragonCodexBoot-0.2.0/launcher.json`：启动、等待和屏幕交接配置
- `DragonCodexBoot-0.2.0/README.md`：原项目使用说明

## 说明

原项目源码与随附演示媒体的授权范围不同。当前视频、角色图和图标是本次定制使用的素材；公开发布前请确认自己拥有这些素材的分发权，并按原项目许可证和媒体说明保留必要声明。
