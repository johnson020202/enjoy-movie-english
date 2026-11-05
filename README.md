# Enjoy Movie English

用影视和音频练英语的安卓 App。**本地优先、无需账号**：打开自己的视频/音频，或粘贴 YouTube 链接，逐句跟读、录音打分、听写、查词、复习生词。

本项目是 [baizhiheizi/enjoy_player](https://github.com/baizhiheizi/enjoy_player) 的安卓分支（fork），遵循上游 **AGPL-3.0** 许可，改动说明见下方[与上游的差异](#与上游的差异)。

---

## 功能

**三种练习模式**（每句字幕都可切换，停在哪句就从哪句继续）

- **听**：交互字幕与媒体逐句同步，点句跳转，单句循环，可减速，按需显示译文和音标。
- **跟读**：以句为单位循环，句末自动暂停并回退重播；每次录音都保留，可回放对比、看音高曲线、选输入麦克风。
- **听写**：字幕变成色块，先纯听，再长按某句偷看。

**发音与语音**

- Azure 发音评估：总分、准确度、完整度、流利度、韵律五个维度，细到每个单词，把你的音高曲线叠在原声上对比。
- FFmpeg 音高分析（YIN），eSpeak-NG 强制对齐。

**字幕**

- `.srt` / `.vtt` 导入导出、YouTube 字幕抓取、AI 转写并逐句对齐。
- 字幕编辑器、逐句翻译、密度调节、划词查义。

**媒体库与播放器**

- 本地音视频导入（后台 isolate 计算指纹，不卡界面），内容语言标记，自动截帧生成封面，无封面时用哈希生成几何封面。
- 搜索、重命名、删除、音频/视频分栏、「继续上次练习」、今日目标。
- media_kit 单播放引擎；YouTube 走独立 WebView 引擎。
- 把当前循环区间精确导出为 MP4 / M4A 片段。

**查词与生词本**

- 语境查词：翻译、词典释义，以及 AI 解释短语在当前场景中的含义。
- 生词本：SM-2 间隔重复、三键闪卡、一个词绑定多个上下文、按状态筛选、导出 Anki CSV。

**Craft 创作**

- 用母语说出或写下想说的话，改写成地道目标语、朗读合成，存进媒体库跟读。

**其他**

- 练习海报：把一次跟读生成 9:16 海报（封面帧、台词、分数）分享。
- 键盘快捷键自定义、诊断日志导出、网络代理设置（跟随系统 / 手动 / 直连）。
- **应用内更新**：启动时检查版本清单，发现新版提示，下载后调用系统安装器覆盖安装。

---

## 与上游的差异

本分支面向「自用、无账号」场景，主要改动：

1. **拆掉登录闸门**：上游未登录只能停在登录页；本分支启动即以本地档案运行，首页、媒体库、播放器、设置全部可直接使用。
2. **AI 全部走 BYOK**：上游默认调用 Enjoy 的闭源 worker；本分支默认「自带密钥」，在 **设置 → AI providers** 填入自己的 OpenAI 兼容端点与密钥（LLM / 翻译 / 词典 / ASR / TTS / 发音评估分别配置）。密钥只存本机系统密钥库（Keychain / Keystore），不进代码、不进仓库。
3. **无云端依赖**：本地模式下不做云同步、不拉社区/订阅/额度接口，避免反复请求不可用的服务。
4. **更新通道自建**：版本清单指向本仓库的 `latest.json`，APK 发布在本仓库 Releases。
5. **品牌与包名**：应用名 `Enjoy Movie English`，包名 `com.johnson020202.enjoymovieenglish`，与上游可共存安装。

**不包含**：Enjoy 账号登录、跨设备云同步、社区活跃榜、订阅/积分、Discover 的 YouTube 频道订阅（这些依赖上游闭源服务端）。

---

## 安装

从 [Releases](https://github.com/johnson020202/enjoy-movie-english/releases/latest) 下载最新 APK（arm64-v8a），在手机上允许「安装未知来源应用」后安装。

要求：Android 8.0 及以上；arm64 设备。

## 使用 AI 功能

1. 打开 **设置 → AI providers**。
2. 每个能力卡片（LLM / ASR / TTS / Assessment）切到 **BYOK**。
3. 填 base URL、模型名和 API key。LLM 兼容 OpenAI / Anthropic / Google 协议；ASR、TTS 支持 OpenAI 兼容或 Azure Speech；发音评估需要 Azure Speech 订阅。

未配置密钥时，对应功能会给出「provider not configured」提示，其余本地功能不受影响。

## 更新机制

应用启动时读取仓库根目录的 `latest.json`：

```json
{
  "version": "1.0.1",
  "build": 2,
  "minSupportedVersion": "1.0.0",
  "notes": "更新说明",
  "assets": {
    "android_arm64_v8a": {
      "url": "https://github.com/johnson020202/enjoy-movie-english/releases/download/v1.0.1/app-arm64-v8a.apk",
      "sha256": "…",
      "file": "app-arm64-v8a.apk"
    }
  }
}
```

发现更高版本时提示更新，可选「稍后」（24 小时内不再打扰）；下载后校验 SHA-256，再交给系统安装器覆盖安装。**签名必须一致**：已装版本与新版必须用同一密钥签名，否则系统会拒绝覆盖。

## 从源码构建

```bash
flutter pub get
dart run build_runner build     # 改动 Drift / Riverpod 注解后需要
flutter build apk --release --flavor direct --target-platform android-arm64
```

环境：Flutter 3.47+ / Dart 3.13+、JDK 21、Android SDK（NDK 28.2）。首次构建前建议先跑项目自带的预取脚本，避免从 Google / GitHub 反复拉大文件：

```bash
bash tool/prefetch_flutter_engine_android_libs.sh release
bash tool/prefetch_media_kit_android_libs.sh
bash tool/prefetch_sqlite3_libs.sh
```

签名：在 `android/key.properties` 填 `storeFile` / `storePassword` / `keyAlias` / `keyPassword`（该文件已被 gitignore；未提供时回落到 debug 签名）。

## 许可

本项目沿用上游的 **GNU Affero General Public License v3.0**，完整条款见 [LICENSE](LICENSE)。原始版权归上游作者；本分支的修改同样以 AGPL-3.0 发布，任何人通过网络提供本软件服务时须同时提供对应源代码。

上游项目：<https://github.com/baizhiheizi/enjoy_player>
