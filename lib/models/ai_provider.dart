import 'package:flutter/foundation.dart';
import 'package:ultimate_wheel/config/l10n.dart';

enum AiProviderId {
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
    id: AiProviderId.siliconflow,
    label: '硅基流动'.tr,
    description: '推荐默认选项，聚合模型多，国内访问友好。'.tr,
    defaultBaseUrl: 'https://api.siliconflow.cn/v1',
    defaultModel: 'deepseek-ai/DeepSeek-V4-Flash', 
    endpointPath: '/chat/completions',
  ),
  AiProviderOption(
    id: AiProviderId.deepseek,
    label: 'DeepSeek',
    description: 'DeepSeek 官方接口，deepseek-v4-flash以及deepseek-v4-pro模型。'.tr,
    defaultBaseUrl: 'https://api.deepseek.com/v1',
    defaultModel: 'deepseek-v4-flash', // deepseek-v4-flash以及deepseek-v4-pro
    endpointPath: '.tr/chat/completions',
  ),
  AiProviderOption(
    id: AiProviderId.kimi,
    label: 'Kimi',
    description: 'Moonshot 官方接口，支持kimi-k2.6、kimi-k2.5、moonshot-v1-8k、moonshot-v1-32k、moonshot-v1-128k。'.tr,
    defaultBaseUrl: 'https://api.moonshot.cn/v1',
    defaultModel: 'moonshot-v1-32k', // Kimi 的通用长文本模型，API 官方名称目前仍以 moonshot-v1 开头
    endpointPath: '.tr/chat/completions',
  ),
  AiProviderOption(
    id: AiProviderId.glm,
    label: '智谱 GLM'.tr,
    description: '智谱 AI 官方接口，国内顶尖大模型。支持众多模型，且有免费模型（GLM-4.7-Flash），建议自行查阅。'.tr,
    defaultBaseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    defaultModel: 'GLM-5-Turbo', // 智谱目前的旗舰文本模型
    endpointPath: '.tr/chat/completions',
  ),
  AiProviderOption(
    id: AiProviderId.aliyun,
    label: '阿里云百炼'.tr,
    description: '阿里云官方接口，调用通义千问大模型，推荐qwen3.6-Plus、qwen3.6-flash。'.tr,
    defaultBaseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
    defaultModel: 'qwen3.6-Plus', // 通义千问千亿级别旗舰模型
    endpointPath: '.tr/chat/completions',
  ),
  AiProviderOption(
    id: AiProviderId.openai,
    label: 'OpenAI',
    description: 'OpenAI 官方接口。'.tr,
    defaultBaseUrl: 'https://api.openai.com/v1',
    defaultModel: 'gpt-5.5-instant', // 
    endpointPath: '/chat/completions',
  ),
  AiProviderOption(
    id: AiProviderId.gemini,
    label: 'Google Gemini',
    description: 'Google 官方接口 (使用 OpenAI 兼容层)。'.tr,
    defaultBaseUrl: 'https://generativelanguage.googleapis.com/v1beta/openai',
    defaultModel: 'gemini-3.1-pro', // Google Gemini 最新的 Pro 模型
    endpointPath: '.tr/chat/completions',
  ),
];

AiProviderOption getProviderOption(AiProviderId id) {
  return aiProviderOptions.firstWhere((element) => element.id == id);
}
