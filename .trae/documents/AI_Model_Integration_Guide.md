# AI 多模型架构与配置集成指南（最佳实践）

本文档总结了本项目中关于 AI 多模型供应商（Kimi、GLM、阿里云百炼、硅基流动等）的接入配置代码和最佳实践，供其他项目复用。

## 1. 核心模型配置与目录定义

为方便扩展和统一管理，应定义一套标准的供应商接口配置字典。支持用户切换并提供开箱即用的默认参数。

```typescript
// types.ts
export type AiProviderId = 'siliconflow' | 'kimi' | 'glm' | 'aliyun';

export interface AiProviderOption {
  id: AiProviderId;
  label: string;
  description: string;
  defaultBaseUrl: string;
  defaultModel: string;
  endpointPath: string;
  experimental?: boolean;
}

export interface AiSettings {
  provider: AiProviderId;
  apiKey: string;
  baseUrl: string;
  model: string;
  endpointPath: string;
  timeoutMs: number;
  apiKeys?: Partial<Record<AiProviderId, string>>; // 独立保存每个供应商的 API Key
}

// catalog.ts
export const AI_PROVIDER_OPTIONS: AiProviderOption[] = [
  {
    id: 'siliconflow',
    label: '硅基流动',
    description: '推荐默认选项，聚合模型多，国内访问友好。',
    defaultBaseUrl: 'https://api.siliconflow.cn/v1',
    defaultModel: 'Qwen/Qwen2.5-VL-72B-Instruct',
    endpointPath: '/chat/completions',
  },
  {
    id: 'kimi',
    label: 'Kimi',
    description: 'Moonshot 官方接口，支持 OpenAI 兼容多模态调用。',
    defaultBaseUrl: 'https://api.moonshot.cn/v1',
    defaultModel: 'kimi-k2.6',
    endpointPath: '/chat/completions',
  },
  {
    id: 'glm',
    label: '智谱 GLM',
    description: '智谱 AI 官方接口，国内顶尖多模态大模型。',
    defaultBaseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    defaultModel: 'glm-5v-turbo', // GLM 默认视觉模型
    endpointPath: '/chat/completions',
  },
  {
    id: 'aliyun',
    label: '阿里云百炼 (Qwen-VL)',
    description: '阿里云官方接口，调用通义千问视觉大模型。',
    defaultBaseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
    defaultModel: 'qwen-vl-plus', // 或 qwen3.6-flash
    endpointPath: '/chat/completions',
  },
];
```

## 2. 前端密钥独立管理

为了避免用户在切换不同模型供应商时需要重新输入 API Key，推荐在前端的 `localStorage` 中通过一个 Map (`apiKeys`) 来分渠道存储凭据。

```typescript
// settingsStorage.ts 关键片段
export function migrateSettings(rawValue: unknown): AiSettings {
  // ... 省略常规校验 ...
  const source = candidate.settings;
  const defaults = createDefaultSettings(source.provider);

  return {
    provider: source.provider,
    apiKey: source.apiKey ?? '',
    baseUrl: source.baseUrl || defaults.baseUrl,
    model: source.model || defaults.model,
    endpointPath: source.endpointPath || defaults.endpointPath,
    timeoutMs: source.timeoutMs || defaults.timeoutMs,
    // 【核心】将当前 apiKey 备份到对应 provider 下
    apiKeys: source.apiKeys || { [source.provider]: source.apiKey ?? '' },
  };
}

// 在 React 组件中切换供应商时的处理逻辑
const handleProviderChange = (provider: AiProviderId) => {
  const option = getProviderOption(provider);
  setSettings((current) => {
    const savedApiKey = current.apiKeys?.[provider] || ''; // 取出之前保存的 Key
    return {
      ...current,
      provider,
      apiKey: savedApiKey,
      baseUrl: option.defaultBaseUrl,
      model: option.defaultModel,
      endpointPath: option.endpointPath,
    };
  });
};
```

## 3. 图片压缩与动态超时机制

多模态大模型在处理高清原图时极易发生超时（TimeoutError）。必须在前端压缩图片，并根据 Base64 大小动态计算请求超时时间。

```typescript
// 图片压缩逻辑 (Canvas 方案，指定最大宽度)
export function compressImage(file: File, maxWidth: number = 1080): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        let width = img.width;
        let height = img.height;
        if (width > maxWidth) {
          height = Math.round((height * maxWidth) / width);
          width = maxWidth;
        }
        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        if (ctx) {
          ctx.fillStyle = '#FFFFFF'; // 解决透明 PNG 变黑问题
          ctx.fillRect(0, 0, width, height);
          ctx.drawImage(img, 0, 0, width, height);
        }
        resolve(canvas.toDataURL('image/jpeg', 0.8)); // 压缩为 JPEG
      };
      img.src = e.target?.result as string;
    };
    reader.readAsDataURL(file);
  });
}

// 动态计算超时时间
const imageBytes = Math.floor((base64.length * 3) / 4);
let expectedMs = currentSettings.timeoutMs;
if (currentSettings.timeoutMs === 120000) { // 如果是默认超时
  // 基础 60s，每 1MB 增加 45s，上限 300s
  const smartEst = 60000 + Math.ceil(imageBytes / 1024 / 1024) * 45000;
  expectedMs = Math.min(smartEst, 300000); 
}
```

## 4. 后端请求构造与差异化适配

不同供应商虽然都兼容了 OpenAI 的格式（`/v1/chat/completions`），但在某些参数校验上存在差异。例如 Kimi 严格要求 `temperature` 不为 0。

```typescript
// server/index.ts 构建请求体
function buildVisionRequestBody(settings: AiSettings, imageDataUrl: string, prompt: string) {
  return {
    model: settings.model,
    // 【差异化适配】：Kimi 的多模态或特定模型严格要求 temperature 必须为 1.0 左右
    temperature: settings.provider === 'kimi' ? 1.0 : 0.1, 
    response_format: { type: 'json_object' }, // 强制输出 JSON
    messages: [
      {
        role: 'user',
        content: [
          { type: 'text', text: prompt },
          {
            type: 'image_url',
            image_url: { url: imageDataUrl },
          },
        ],
      },
    ],
  };
}

// 执行上游请求
async function callUpstream(settings: AiSettings, body: Record<string, unknown>) {
  const endpoint = new URL(settings.endpointPath, settings.baseUrl).toString();
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${settings.apiKey}`,
    },
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(settings.timeoutMs), // 传入动态计算的超时时间
  });
  // ...
}
```

## 5. 错误信息转换与友好提示

将 HTTP 状态码转换为业务错误提示，提升用户体验。

```typescript
function parseErrorMessage(payload: any, status: number): string {
  const suffix = payload?.detail ? ` ${payload.detail}` : '';

  if (payload?.message) return `${payload.message}${suffix}`;
  
  if (status === 401 || status === 403) {
    return 'API Key 无效、已过期，或当前账户无权访问该模型。';
  }
  if (status === 429) {
    return `请求过于频繁，或账户额度不足，请稍后重试。${suffix}`.trim();
  }
  if (status >= 500) {
    return `模型服务暂时不可用，请稍后重试。${suffix}`.trim();
  }
  return `排班识别失败，请检查设置后重试。${suffix}`.trim();
}
```

## 6. 注意事项

1. **DeepSeek 视觉能力：** 目前 DeepSeek 官方暂未原生稳定支持视觉多模态，可通过硅基流动的 `DeepSeek-VL` 替代。
2. **隐私脱敏：** 所有的请求和响应日志在打印时，务必对 `apiKey` 进行正则脱敏（如 `sk-****`）。
3. **安全代理：** 浏览器端由于跨域限制，无法直接调用第三方接口。需要搭建同源代理服务（如 Express 或 Vercel Serverless Function）来转发请求。
