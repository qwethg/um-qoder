import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/ai_provider.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storageService;

  static const String _providerIdKey = 'ai_provider_id';
  static const String _apiKeyKey = 'ai_api_key';
  static const String _baseUrlKey = 'ai_base_url';
  static const String _endpointPathKey = 'ai_endpoint_path';
  
  static const String _modelNameKey = 'ai_model_name';
  static const String _promptKey = 'ai_prompt';
  static const String _temperatureKey = 'ai_temperature';
  static const String _maxTokensKey = 'ai_max_tokens';
  static const String _cacheTtlDaysKey = 'ai_cache_ttl_days';

  static const String _defaultModelName = 'deepseek-ai/DeepSeek-R1-0528-Qwen3-8B';
  static const String _defaultPrompt = '''
你是一名顶级的极限飞盘教练、运动生理学家、运动心理学家。你的任务是基于用户提供的自我评估数据，给出专业、鼓励性且可执行的分析和建议。

请按照以下结构输出你的分析（使用 Markdown 格式）：

## 📊 总体评价
- 对用户当前整体能力水平的综合评价（2-3句话）
- 指出最突出的优势领域，
- 识别并重点分析用户的 1-2 项核心优势，说明这些优势在比赛中的价值，并给出如何进一步发挥这些优势的建议。
- 点明需要重点关注的薄弱环节
- 识别并重点分析用户的 1-2 项核心短板，说明这些短板对比赛表现的负面影响，并提供一套循序渐进的、结构化的改进计划。

## 🎯 分项评价与建议

### 💪 身体 (Athleticism)
- 当前水平总结
- 具体建议（至少2-3条可执行的训练建议）

### 🧠 意识 (Awareness)
- 当前水平总结
- 具体建议（至少2-3条可执行的训练建议）

### 🎨 技术 (Technique)
- 当前水平总结
- 具体建议（至少2-3条可执行的训练建议）

### 🌟 心灵 (Mind)
- 当前水平总结
- 具体建议（至少2-3条可执行的训练建议）

## 💡 下一步行动计划
**训练建议**：根据前面的分析，为用户量身定制一套综合性的训练方案，包括但不限于：
    *   **短期（1-2周）**：可以快速见效的练习。
    *   **中期（1-3月）**：需要持续投入才能看到效果的系统性训练。
    *   **长期（3个月以上）**：关于比赛策略、意识培养等方面的宏观建议。

注意事项：
1. 语气要专业但温暖，充满鼓励
2. 建议要具体可执行，避免空泛的鼓励话语
3. 如果有历史对比数据，报告内容必须紧密结合用户的个人数据，避免宽泛、模板化的套话。要指出进步或退步的地方
4. 考虑用户设定的个人目标
5. 使用飞盘领域的专业术语，分析要深入、有理有据。
5. 使用合适的 emoji 让内容更生动

请根据以下用户数据，生成分析报告：
''';

  static const double _defaultTemperature = 0.7;
  static const int _defaultMaxTokens = 2048;
  static const int _defaultCacheTtlDays = 30;

  AiProviderId _providerId = AiProviderId.siliconflow;
  String _apiKey = '';
  String _baseUrl = 'https://api.siliconflow.cn/v1';
  String _endpointPath = '/chat/completions';

  String _modelName = _defaultModelName;
  String _prompt = _defaultPrompt;
  double _temperature = _defaultTemperature;
  int _maxTokens = _defaultMaxTokens;
  int _cacheTtlDays = _defaultCacheTtlDays;

  AiProviderId get providerId => _providerId;
  String get apiKey => _apiKey;
  String get baseUrl => _baseUrl;
  String get endpointPath => _endpointPath;

  String get modelName => _modelName;
  String get prompt => _prompt;
  double get temperature => _temperature;
  int get maxTokens => _maxTokens;
  int get cacheTtlDays => _cacheTtlDays;

  SettingsProvider(this._storageService) {
    _loadSettings();
  }

  String _getProviderKey(String baseKey) => '${baseKey}_${_providerId.name}';

  Future<void> _loadProviderSpecificSettings({bool isInitializing = false}) async {
    final option = getProviderOption(_providerId);
    
    // Check if we have provider-specific keys. If not, try to migrate from old global keys.
    final providerApiKey = _storageService.get(_getProviderKey(_apiKeyKey));
    if (providerApiKey == null) {
      // Only migrate old global data on startup
      if (isInitializing) {
        _apiKey = _storageService.get(_apiKeyKey, defaultValue: '') as String;
        _baseUrl = _storageService.get(_baseUrlKey, defaultValue: option.defaultBaseUrl) as String;
        _endpointPath = _storageService.get(_endpointPathKey, defaultValue: option.endpointPath) as String;
        _modelName = _storageService.get(_modelNameKey, defaultValue: option.defaultModel) as String;
      } else {
        _apiKey = '';
        _baseUrl = option.defaultBaseUrl;
        _endpointPath = option.endpointPath;
        _modelName = option.defaultModel;
      }
      
      // Save to new keys
      await _storageService.put(_getProviderKey(_apiKeyKey), _apiKey);
      await _storageService.put(_getProviderKey(_baseUrlKey), _baseUrl);
      await _storageService.put(_getProviderKey(_endpointPathKey), _endpointPath);
      await _storageService.put(_getProviderKey(_modelNameKey), _modelName);
    } else {
      // Load provider-specific settings
      _apiKey = providerApiKey as String;
      _baseUrl = _storageService.get(_getProviderKey(_baseUrlKey), defaultValue: option.defaultBaseUrl) as String;
      _endpointPath = _storageService.get(_getProviderKey(_endpointPathKey), defaultValue: option.endpointPath) as String;
      _modelName = _storageService.get(_getProviderKey(_modelNameKey), defaultValue: option.defaultModel) as String;
    }
  }

  Future<void> _loadSettings() async {
    final providerIdString = await _storageService.get(_providerIdKey, defaultValue: AiProviderId.siliconflow.name);
    _providerId = AiProviderId.values.firstWhere((e) => e.name == providerIdString, orElse: () => AiProviderId.siliconflow);
    
    await _loadProviderSpecificSettings(isInitializing: true);

    _prompt = await _storageService.get(_promptKey, defaultValue: _defaultPrompt);
    _temperature = await _storageService.get(_temperatureKey, defaultValue: _defaultTemperature);
    _maxTokens = await _storageService.get(_maxTokensKey, defaultValue: _defaultMaxTokens);
    _cacheTtlDays = await _storageService.get(_cacheTtlDaysKey, defaultValue: _defaultCacheTtlDays);
    notifyListeners();
  }

  Future<void> setProvider(AiProviderId newProvider) async {
    if (_providerId == newProvider) return;

    _providerId = newProvider;
    await _storageService.put(_providerIdKey, newProvider.name);

    await _loadProviderSpecificSettings(isInitializing: false);

    notifyListeners();
  }

  Future<void> setApiKey(String newKey) async {
    _apiKey = newKey;
    await _storageService.put(_getProviderKey(_apiKeyKey), newKey);
    notifyListeners();
  }

  Future<void> setBaseUrl(String newUrl) async {
    _baseUrl = newUrl;
    await _storageService.put(_getProviderKey(_baseUrlKey), newUrl);
    notifyListeners();
  }

  Future<void> setEndpointPath(String newPath) async {
    _endpointPath = newPath;
    await _storageService.put(_getProviderKey(_endpointPathKey), newPath);
    notifyListeners();
  }

  Future<void> setModelName(String newName) async {
    _modelName = newName;
    await _storageService.put(_getProviderKey(_modelNameKey), newName);
    notifyListeners();
  }

  Future<void> setPrompt(String newPrompt) async {
    _prompt = newPrompt;
    await _storageService.put(_promptKey, newPrompt);
    notifyListeners();
  }

  Future<void> setTemperature(double newValue) async {
    _temperature = newValue;
    await _storageService.put(_temperatureKey, newValue);
    notifyListeners();
  }

  Future<void> setMaxTokens(int newValue) async {
    _maxTokens = newValue;
    await _storageService.put(_maxTokensKey, newValue);
    notifyListeners();
  }

  Future<void> setCacheTtlDays(int newValue) async {
    _cacheTtlDays = newValue;
    await _storageService.setCacheTtlDays(newValue);
    notifyListeners();
  }

  Future<void> restoreDefaultModelName() async {
    final option = getProviderOption(_providerId);
    await setModelName(option.defaultModel);
  }

  Future<void> restoreDefaultBaseUrl() async {
    final option = getProviderOption(_providerId);
    await setBaseUrl(option.defaultBaseUrl);
  }

  Future<void> restoreDefaultEndpointPath() async {
    final option = getProviderOption(_providerId);
    await setEndpointPath(option.endpointPath);
  }

  Future<void> restoreDefaultPrompt() async {
    await setPrompt(_defaultPrompt);
  }

  Future<void> restoreDefaultTemperature() async {
    await setTemperature(_defaultTemperature);
  }

  Future<void> restoreDefaultMaxTokens() async {
    await setMaxTokens(_defaultMaxTokens);
  }

  Future<void> restoreDefaultCacheTtlDays() async {
    await setCacheTtlDays(_defaultCacheTtlDays);
  }
}