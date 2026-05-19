import 'package:flutter/foundation.dart';
import 'package:ultimate_wheel/config/l10n.dart';

enum AiProviderId {
  glmFree,
  siliconflow,
  deepseek,
  kimi,
  glm,
  aliyun,
  openai,
  gemini,
}

class AiProviderOption {
  final AiProviderId id;
  final String label;
  final String description;
  final String defaultBaseUrl;
  final String defaultModel;
  final String endpointPath;

  const AiProviderOption({
    required this.id,
    required this.label,
    required this.description,
    required this.defaultBaseUrl,
    required this.defaultModel,
    required this.endpointPath,
  });
}

const List<AiProviderOption> aiProviderOptions = [
  AiProviderOption(
    id: AiProviderId.glmFree,
    label: '智谱 GLM (免费内置通道)',
    description: '无需填写 API Key，开箱即用，由 GLM-4.7-Flash 强力驱动。',
    defaultBaseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    defaultModel: 'glm-4.7-flash', 
    endpointPath: '/chat/completions',
  ),
  AiProviderOption(
    id: AiProviderId.siliconflow,
    label: '硅基流动',
    description: '推荐默认选项，聚合模型多，国内访问友好。',
    defaultBaseUrl: 'https://api.siliconflow.cn/v1',
    defaultModel: 'deepseek-ai/DeepSeek-V3', 
    endpointPath: '/chat/completions',
  ),
  AiProviderOption(
    id: AiProviderId.deepseek,
    label: 'DeepSeek',
    description: 'DeepSeek 官方接口，deepseek-chat 模型。',
    defaultBaseUrl: 'https://api.deepseek.com/v1',
    defaultModel: 'deepseek-chat', 
    endpointPath: '/chat/completions',
  ),
  AiProviderOption(
    id: AiProviderId.kimi,
    label: 'Kimi',
    description: 'Moonshot 官方接口，支持kimi-k2.6、kimi-k2.5、moonshot-v1-8k、moonshot-v1-32k、moonshot-v1-128k。',
    defaultBaseUrl: 'https://api.moonshot.cn/v1',
    defaultModel: 'moonshot-v1-32k',
    endpointPath: '/chat/completions',
  ),
  AiProviderOption(
    id: AiProviderId.glm,
    label: '智谱 GLM',
    description: '智谱 AI 官方接口，国内顶尖大模型。',
    defaultBaseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    defaultModel: 'GLM-4', 
    endpointPath: '/chat/completions',
  ),
  AiProviderOption(
    id: AiProviderId.aliyun,
    label: '阿里云百炼',
    description: '阿里云官方接口，调用通义千问大模型，推荐qwen-plus、qwen-turbo。',
    defaultBaseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
    defaultModel: 'qwen-plus', 
    endpointPath: '/chat/completions',
  ),
  AiProviderOption(
    id: AiProviderId.openai,
    label: 'OpenAI',
    description: 'OpenAI 官方接口。',
    defaultBaseUrl: 'https://api.openai.com/v1',
    defaultModel: 'gpt-4o', 
    endpointPath: '/chat/completions',
  ),
  AiProviderOption(
    id: AiProviderId.gemini,
    label: 'Google Gemini',
    description: 'Google 官方接口 (使用 OpenAI 兼容层)。',
    defaultBaseUrl: 'https://generativelanguage.googleapis.com/v1beta/openai',
    defaultModel: 'gemini-1.5-pro', 
    endpointPath: '/chat/completions',
  ),
];

AiProviderOption getProviderOption(AiProviderId id) {
  return aiProviderOptions.firstWhere((element) => element.id == id);
}
