## 目标
- 增强 AI 生成流程的健壮性（超时/重试/可选非流式）。
- 在设置页新增“AI 报告统计”面板，展示可观测性信息。

## 现状基线
- 参数与 TTL：SettingsProvider 已支持 `temperature/max_tokens/cacheTtlDays`；TTL 已应用到存储服务。
- 单评估唯一报告：保存逻辑已确保同评估仅保留最新报告。
- 生成过程取消：UI 支持在生成中取消订阅（停止本次分析）。

## 实施项
### 1) 流式健壮性
- 新增偏好：
  - `ai_stream_enabled`（bool，默认 true）：是否启用流式生成；关闭时使用一次性响应。
  - `ai_timeout_seconds`（int，默认 30）：请求超时时间。
  - `ai_retry_count`（int，默认 2）：失败重试次数（指数退避）。
- 服务修改：
  - 在 `EnhancedAiService._generateReportContent` 中：
    - 使用 `timeout(settings.timeout)`；对网络错误/非 200/解析错误进行可控重试。
    - 当 `stream_enabled=false` 时，移除 SSE 解析，直接走一次性 `http.post` 并解析完整 `content`。
  - 错误提示统一与内容验证失败的回退提示保持一致。

### 2) 设置页 UI 扩展
- 在“AI 设置”下增加参数卡片：
  - 开关：流式生成（Switch）
  - 输入：超时时间（5–120 秒）、重试次数（0–3 次）
  - 与现有 Temperature/Max Tokens/缓存有效期并列，支持恢复默认。

### 3) AI 报告统计面板
- 数据来源：`AiReportStorageService.getStats()`（总数、缓存数、过期数、平均生成时长、状态与标签计数）。
- 设置页新增“AI 报告统计”卡片：
  - 展示：总数、缓存命中率、过期占比、平均生成时长（ms → s）、状态分布（生成中/完成/失败）、标签 Top5。
  - 支持“清理过期缓存”按钮（调用 `cleanupExpiredCache`）。

## 交付物
- 新偏好键与 UI 控件（流式开关、超时、重试）。
- 服务层超时/重试/非流式实现与统一错误提示。
- 设置页 AI 报告统计卡片与清理操作。

## 验收标准
- 流式与非流式可切换；网络异常可重试/超时，取消时不写入最终报告。
- 统计信息正确显示；清理过期缓存后占比变化合理。
- 不引入报告历史对比功能；同评估保持唯一报告策略。