## 目标
- 增强 AI 的可配置性与健壮性，同时保证“同一次评估仅保留一个 AI 报告”。
- 不引入报告历史对比功能；维持现有按钮显示逻辑：有报告则隐藏按钮。

## 范围与基线
- 显示/隐藏逻辑：基于 `assessment.aiAnalysisContent` 判断（lib/widgets/ai_analysis_section.dart:191–193）。
- 模型与 Prompt 来源：`SettingsProvider`（lib/providers/settings_provider.dart:7–12, 58–71, 74–92）。
- 服务层：`EnhancedAiService`（lib/services/enhanced_ai_service.dart:27–41, 185–247, 249–255, 291–315）。
- 存储与缓存：`AiReportStorageService`（lib/services/ai_report_storage_service.dart:34–66, 72–90, 92–149, 151–166, 221–260）。
- 报告模型：`AiReport`（lib/models/ai_report.dart:8–29, 49–56, 94–113, 137–163, 209–221）。

## 实施项
### 1) 模型选择与参数面板（设置页）
- 新增偏好字段：`temperature`、`max_tokens`（默认 `0.7/2048`），支持恢复默认。
- 模型预设列表 + 自定义输入（字符串校验）。
- UI：设置页新增“AI 模型与参数”分区（选择器 + 数字输入）。
- 服务读取：`EnhancedAiService._getApiParameters()` 改为读取 `SettingsProvider` 参数，移除硬编码（lib/services/enhanced_ai_service.dart:249–255）。

### 2) 单报告策略（同一次评估仅保留一个）
- 在保存最终报告前：`AiReportStorageService` 先删除该 `assessmentId` 的其他报告，仅保留新报告（lib/services/ai_report_storage_service.dart:72–79, 151–166）。
- 缓存命中时直接返回；强制刷新（`forceRefresh`）则覆盖旧报告。

### 3) 健壮性与容错（流式调用增强）
- 超时与重试：为 `_generateReportContent` 增加指数退避重试（最多 N 次），网络异常统一提示（lib/services/enhanced_ai_service.dart:185–247）。
- 取消控制：在 `AiAnalysisSection` 为生成过程增加“取消”按钮，中断请求但不写入最终报告。
- 失败回退：内容验证失败（`AiReportValidator`）时提供重试按钮；保留部分内容。
- 可选：提供非流式一次性响应开关（设置页）。

### 4) 缓存 TTL 配置与统计
- 缓存 TTL 可配置（默认 30 天，设置页增加范围 7–90 天）。
- 统计仪表：总数、状态分布、平均生成时间、缓存命中率（`getStats`，lib/services/ai_report_storage_service.dart:172–219）。

### 5) Prompt 模板管理
- 设置页提供模板库：默认模板（lib/providers/settings_provider.dart:10–56）+ 用户自定义多模板（命名 + 内容，偏好 JSON 列表）。
- 支持一键切换与预览。

### 6) 安全与观测
- 日志级别：生产降至 `warning`（lib/services/logger_service.dart:24–37）。
- Key 校验与遮盖显示；严禁打印 Key 到日志。

### 7) 交互体验
- 流式进度与字数统计；完成后展示摘要（`_generateSummary`，lib/services/enhanced_ai_service.dart:291–315）。
- 评估结果页与首页保留单报告视图与重试入口，按钮显示逻辑不变。

## 里程碑
1. 设置页参数面板与偏好读写；服务读取改造。
2. 单报告保存策略实现与验证。
3. 流式容错（重试/取消/失败回退）。
4. 缓存 TTL 配置与统计卡片。
5. Prompt 模板管理与切换。

## 交付物
- 设置页“AI 模型与参数/模板”分区与偏好存储。
- 单报告策略生效（同评估仅保留最新报告）。
- 增强的流式容错与取消控制。
- 统计仪表与安全策略调整。

## 验收标准
- 有报告时不显示生成按钮；强制刷新后仅保留一条最新报告。
- 参数修改即时生效；网络异常有重试与取消；日志不泄露 Key。
- 缓存 TTL 与统计面板工作正常。