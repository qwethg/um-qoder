import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// 显示如何获取 SiliconFlow API Key 的教程弹窗
class ApiKeyTutorialDialog extends StatelessWidget {
  const ApiKeyTutorialDialog({super.key});

  // 定义教程内容
  final String _tutorialContent = """
### 步骤 1：注册并登录

访问 [硅基流动官方网站](https://cloud.siliconflow.cn/i/oGFUsgLG)，点击“注册”按钮，使用您的邮箱或手机号完成注册。

### 步骤 2：进入 API Key 管理页面

登录成功后，在页面左侧，“账户管理”下点击“API 密钥”。

<!-- 点击“API 密钥” -->
<img src="assets/images/api_key.png" width="300"/>


### 步骤 3：创建新的 API Key

在 API Key 管理页面，点击“新建API 密钥”按钮。
<!-- 新建API 密钥 -->
<img src="assets/images/click_creat_apikey.png" width="300"/>
然后会弹出以下弹窗，可以键入任意描述，然后点击“新建密钥”按钮。
<!-- 新建API 密钥弹窗 -->
<img src="assets/images/newapikey.png" width="300"/>

### 步骤 4：复制您的 API Key
系统会生成一个新的 API Key。点击key右侧的复制按钮，将 Key 复制到剪贴板。
<!-- 复制 API Key 截图 -->
<img src="assets/images/apikeycopy.png" width="300"/>

### 步骤 5：将 API Key 粘贴到应用中

回到本应用的“设置”页面，将复制的 API Key 粘贴到“API Key 设置”卡片的输入框中，然后点击“保存 API Key”。

---

### 常见问题 (FAQ)

**Q1: 这个 API Key 是免费的吗？**

A: 对于本项目来说，是的。因为本项目使用的是硅基流动免提供的免费的AI模型：deepseek-ai/DeepSeek-R1-0528-Qwen3-8B。
所以调用是免费的。并且，如果你使用本页面的链接注册硅基流动的话，硅基流动将会为新注册用户提供免费的 API 调用额度，足够个人开发者和轻度用户使用。（也会给我一点奖励）谢谢~

**Q2: 如果忘记了 API Key 怎么办？**

A: 如果您忘记或丢失了 API Key，可以回到硅基流动的 API Key 管理页面查看并复制。

**Q3: 为什么我的 API Key 保存后无效？**

A: 请检查您是否复制了完整的 API Key，确保没有遗漏任何字符，也没有包含多余的空格。
""";

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://cloud.siliconflow.cn/i/oGFUsgLG');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('如何获取免费 API Key'),
      content: SingleChildScrollView(
        child: MarkdownBody(
          data: _tutorialContent,
          onTapLink: (text, href, title) {
            if (href != null) {
              launchUrl(Uri.parse(href));
            }
          },
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(height: 1.5),
            h3: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 2.0),
            // 在此处为其他 Markdown 元素定义样式
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
        FilledButton.icon(
          onPressed: _launchURL,
          icon: const Icon(Icons.open_in_browser),
          label: const Text('前往硅基流动'),
        ),
      ],
    );
  }
}