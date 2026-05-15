# Ultimate Wheel (飞盘之轮)

**Ultimate Wheel** 是一款为极限飞盘（Ultimate Frisbee）玩家设计的个人能力评估与成长追踪工具。

其核心理念是 **“与理想的自己对话，而非与他人比较”**。它引导用户通过自我评估，发现个人能力的优势与不足，并通过独特的可视化方式，激励玩家成为更“完整”的自己。

---

## ✨ 核心功能

- **双评估模式**: 提供仪式感的 **深度评估** 和快捷的 **快速评估** 两种模式。
- **个性化目标设定**: 用户可以为 12 项核心能力自定义 3/5/7/10 分的达成标准，让评估更具个人意义。
- **花瓣式雷达图**: 独特美观的十二边形花瓣式雷达图，直观展示能力分布，支持在花瓣内显示分数。
- **历史追踪与对比**:
  - 以时间轴形式清晰记录每一次评估。
  - 支持任意两次评估记录进行 **雷达图叠加对比**，精准分析变化。
  - 提供总分、四大类别及十二项能力的 **趋势折线图**，追踪长期成长轨迹。
- **AI 智能分析**:
  - 用户可使用自己的 API Key，调用 **DeepSeek** 大语言模型进行智能分析。
  - AI 将扮演顶级教练和运动心理学家的角色，结合用户的个人目标与历史数据，生成结构化的分析报告，包含总体评价、分项建议和下一步行动计划。
- **截图分享**: 一键生成评估结果或对比分析的精美图片，方便分享与复盘。
- **完善的用户体验**:
  - 支持浅色/深色主题模式。
  - 内置本地化字体与统一图标，无需联网即可获得流畅体验。
  - 所有数据均存储在本地，保护用户隐私。

## 🚀 技术栈

- **框架**: Flutter
- **语言**: Dart
- **状态管理**: Provider
- **本地存储**: Hive
- **图表**: fl_chart
- **AI 集成**: http (调用 SiliconFlow API)

## 🎯 项目状态

项目已完成所有核心功能的开发，包括数据层、评估流程、雷达图绘制、历史分析、AI 报告和分享功能。目前项目功能完备，体验流畅。

详细的开发历程请参考 [log.md](log.md)。

## 📘 运行与构建指南

- 安装依赖：`flutter pub get`
- 本地运行（Web）：`flutter run -d chrome`
- 释放构建（Web）：`flutter build web --release`
- 清理重构建：`flutter clean && flutter pub get && flutter build web --release`

提示：如使用 GitHub Pages，请在构建时设置基础路径：`flutter build web --release --base-href "/UW-qoder/"`（其中 `UW-qoder` 为仓库名）。

## 🛠️ 部署说明（统一）

- GitHub Pages（通过 CI 构建发布）
  - 构建命令：`flutter build web --release --base-href "/UW-qoder/"`
  - 发布目录：`build/web`
  - 访问路径示例：`https://<your-username>.github.io/UW-qoder/`
- Netlify（`netlify.toml` 已配置）
  - 构建命令：`flutter build web --release`
  - 发布目录：`build/web`
  - SPA 路由重写：`/* → /index.html`（状态 200）
  - 统一安全头：`X-Frame-Options=DENY`、`X-XSS-Protection=1; mode=block`、`X-Content-Type-Options=nosniff`、`Referrer-Policy=strict-origin-when-cross-origin`
  - 静态资源缓存：`*.js|*.css|*.woff2` 长缓存（immutable）
- Vercel（`vercel.json` 已配置）
  - 输出目录：`build/web`
  - 路由重写：`/(.*) → /index.html`
  - 统一安全头：同上，并追加 `Referrer-Policy=strict-origin-when-cross-origin`
  - 静态资源缓存：`js|css|woff|woff2|ttf|eot|ico|png|jpg|jpeg|gif|svg` 长缓存（immutable）

建议：为 SPA 提高更新即时性，可为 `/index.html` 设置短缓存（例如 `Cache-Control: public, max-age=0, must-revalidate`）。

## 🔐 AI 设置与 Key 说明

- 模式：用户自备 SiliconFlow API Key（无需后端，Key 本地存储）。
- 设置入口：应用内 `设置 → AI 设置`，输入并保存 Key。
- 校验与提示：
  - 未配置时，评估结果页与首页的 AI 分析卡片会提示“去设置”。
  - 保存后即可触发分析，结果以 Markdown 展示。
- 安全建议：
  - 避免在公共设备保存 Key。
  - 如需更换 Key，先清空后再保存新值。
  - 生产环境建议将日志级别调整为 `warning`，避免 Key 相关信息在日志中暴露。
