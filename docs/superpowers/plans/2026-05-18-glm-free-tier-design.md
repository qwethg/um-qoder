# GLM Free Tier Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate Zhipu GLM-4.7-Flash as the default, zero-configuration AI provider using a deeply obfuscated built-in API key, with graceful degradation to guide users to use their own key if the built-in one hits limits.

**Architecture:** 
1. `ApiKeyDecoder` uses XOR obfuscation to hide the built-in API key from static analysis.
2. `SettingsProvider` and `AiProviderOption` are updated to include the `glmFree` option as the default.
3. The Settings UI dynamically hides the API key input when the free tier is selected, and provides a guide link for users to apply for their own keys.
4. `AiAnalysisSection` and `EnhancedAiService` are updated to handle the `BuiltInKeyLimitException` with a friendly dialog instead of a generic error, and to correctly use `SettingsProvider` instead of the legacy `PreferencesProvider` for the API key.

**Tech Stack:** Dart, Flutter, Provider

---

### Task 1: Create API Key Decoder

**Files:**
- Create: `lib/utils/api_key_decoder.dart`

- [ ] **Step 1: Create the obfuscation utility**

```dart
// lib/utils/api_key_decoder.dart
class ApiKeyDecoder {
  // These values will be replaced with the actual generated salt and array during implementation.
  // For now, use placeholders.
  static const int _salt = 42; 
  static const List<int> _encoded = [1, 2, 3];

  static String getGlmFreeKey() {
    if (_encoded.isEmpty || _encoded.length < 5) return '';
    return String.fromCharCodes(_encoded.map((e) => e ^ _salt));
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/utils/api_key_decoder.dart
git commit -m "feat: add ApiKeyDecoder for obfuscated built-in key"
```

### Task 2: Update AI Provider Definitions

**Files:**
- Modify: `lib/models/ai_provider.dart`

- [ ] **Step 1: Add `glmFree` to `AiProviderId` enum**

Update the enum to include `glmFree`:
```dart
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
```

- [ ] **Step 2: Add `glmFree` to `aiProviderOptions`**

Insert as the first item in the list:
```dart
  AiProviderOption(
    id: AiProviderId.glmFree,
    label: '智谱 GLM (免费内置通道)',
    description: '无需填写 API Key，开箱即用，由 GLM-4.7-Flash 强力驱动。',
    defaultBaseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    defaultModel: 'glm-4.7-flash', 
    endpointPath: '/chat/completions',
  ),
```

- [ ] **Step 3: Commit**

```bash
git add lib/models/ai_provider.dart
git commit -m "feat: add glmFree to AI provider options"
```

### Task 3: Update Settings Provider

**Files:**
- Modify: `lib/providers/settings_provider.dart`

- [ ] **Step 1: Import `ApiKeyDecoder`**

```dart
import '../utils/api_key_decoder.dart';
```

- [ ] **Step 2: Update default provider**

Change the default `_providerId`:
```dart
  AiProviderId _providerId = AiProviderId.glmFree;
```
And update the default value in `_loadSettings`:
```dart
  Future<void> _loadSettings() async {
    final providerIdString = await _storageService.get(_providerIdKey, defaultValue: AiProviderId.glmFree.name);
    _providerId = AiProviderId.values.firstWhere((e) => e.name == providerIdString, orElse: () => AiProviderId.glmFree);
```

- [ ] **Step 3: Add `effectiveApiKey` getter**

```dart
  String get effectiveApiKey {
    if (_providerId == AiProviderId.glmFree) {
      return ApiKeyDecoder.getGlmFreeKey();
    }
    return _apiKey;
  }
```

- [ ] **Step 4: Commit**

```bash
git add lib/providers/settings_provider.dart
git commit -m "feat: set glmFree as default and add effectiveApiKey"
```

### Task 4: Update Settings UI

**Files:**
- Modify: `lib/screens/settings/settings_screen.dart`

- [ ] **Step 1: Import url_launcher (if needed) or update UI**

```dart
import 'package:url_launcher/url_launcher.dart';
```

- [ ] **Step 2: Update `_AiProviderSettingsCardState.build` to handle `glmFree` UI**

Find the `// API Key` section and update it:
```dart
            // API Key
            if (provider.providerId == AiProviderId.glmFree)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '已开启内置免费通道，无需填写 API Key'.tr,
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              )
            else
              TextField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: '请输入您的 API Key'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _apiKeyController.clear(),
                  ),
                ),
                obscureText: true,
                onChanged: (val) => provider.setApiKey(val),
              ),
```

- [ ] **Step 3: Update the guide link at the bottom of the card**

Change the tutorial link to point to the invite link:
```dart
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.card_giftcard, size: 16),
                onPressed: () async {
                  final url = Uri.parse('https://www.bigmodel.cn/invite?icode=AaUj%2FKaiWIwER%2BIPYkTRAlwpqjqOwPB5EXW6OL4DgqY%3D');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                label: Text('免费申请专属大模型 API Key'.tr),
              ),
            ),
```

- [ ] **Step 4: Commit**

```bash
git add lib/screens/settings/settings_screen.dart
git commit -m "feat: adapt settings UI for glmFree built-in key and add invite link"
```

### Task 5: Implement Graceful Degradation (Exceptions & Service)

**Files:**
- Modify: `lib/services/enhanced_ai_service.dart`
- Modify: `lib/services/ai_service.dart`
- Modify: `lib/widgets/ai_analysis_section.dart`

- [ ] **Step 1: Add Custom Exception**

In `lib/services/enhanced_ai_service.dart`, add:
```dart
class BuiltInKeyLimitException implements Exception {
  final String message;
  BuiltInKeyLimitException(this.message);
  @override
  String toString() => message;
}
```

- [ ] **Step 2: Pass `isBuiltInKey` flag down**

In `lib/services/enhanced_ai_service.dart`, update constructor:
```dart
  final bool isBuiltInKey;

  EnhancedAiService({
    required this.apiKey,
    required this.storageService,
    required this.modelName,
    this.prompt,
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.isBuiltInKey = false,
  });
```

In `lib/services/ai_service.dart`:
```dart
  AiService(this._storageService, this._settingsProvider, {required String apiKey, bool isBuiltInKey = false}) {
    _enhancedService = EnhancedAiService(
      apiKey: apiKey,
      storageService: _storageService,
      modelName: _settingsProvider.modelName,
      prompt: _settingsProvider.prompt,
      temperature: _settingsProvider.temperature,
      maxTokens: _settingsProvider.maxTokens,
      isBuiltInKey: isBuiltInKey,
    );
  }
```

- [ ] **Step 3: Catch 401/429 in EnhancedAiService**

In `lib/services/enhanced_ai_service.dart`, inside `_makeRequest` or where the HTTP response is checked:
```dart
      if (response.statusCode != 200) {
        if (isBuiltInKey && (response.statusCode == 401 || response.statusCode == 429)) {
          throw BuiltInKeyLimitException('免费通道暂时拥挤');
        }
        // existing error handling
```

- [ ] **Step 4: Update `AiAnalysisSection` to handle exception**

In `lib/widgets/ai_analysis_section.dart`:
```dart
      // Change from prefsProvider to settingsProvider
      if (settingsProvider.effectiveApiKey.isEmpty) {
        throw Exception('请先在设置中配置 API Key'.tr);
      }

      final isBuiltIn = settingsProvider.providerId == AiProviderId.glmFree;
      final aiService = AiService(
        storageService, 
        settingsProvider, 
        apiKey: settingsProvider.effectiveApiKey,
        isBuiltInKey: isBuiltIn,
      );
```

And in the `catch` block:
```dart
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        
        if (e is BuiltInKeyLimitException || e.toString().contains('免费通道暂时拥挤')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('免费通道暂时拥挤 🥺'.tr),
              content: Text('当前使用内置通道的小伙伴太多啦，或者该通道暂时不可用。\n\n您可以稍后再试，或者在设置中填入您自己的 API Key，获得更稳定、更私密的深度专属报告。'.tr),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('稍后再试'.tr),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to settings if using go_router
                    // context.push('/settings'); 
                  },
                  child: Text('去设置专属Key'.tr),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('生成 AI 分析失败: $e'.tr),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
```

- [ ] **Step 5: Commit**

```bash
git add lib/services/enhanced_ai_service.dart lib/services/ai_service.dart lib/widgets/ai_analysis_section.dart
git commit -m "feat: handle BuiltInKeyLimitException with graceful degradation dialog"
```
