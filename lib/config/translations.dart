class AppLanguage {
  static String currentLanguage = 'zh';
}

const Map<String, Map<String, String>> appTranslations = {
  'en': {
    '评估中心': 'Assessment Hub',
    '评估结果': 'Assessment Result',
    '未找到评估记录': 'No assessment records found',
    '查看历史': 'View History',
    '回到首页': 'Back to Home',
    '选择雷达主题：\${_selectedTheme.name}': 'Select Radar Theme: \${_selectedTheme.name}',
    '显示AI教练总体评价': 'Show AI Coach Overall Feedback',
    '显示分区得分': 'Show Section Scores',
    '显示总分': 'Show Total Score',
    '保存图片到本地': 'Save Image to Device',
    '直接分享': 'Share Directly',
    '未选择目录或平台不支持目录选择': 'No directory selected or platform not supported',
    '选择目录失败：\$e': 'Failed to select directory: \$e',
    '选择雷达主题': 'Select Radar Theme',
    '确认': 'Confirm',
    '开始评估': 'Start Assessment',
    '提示': 'Notice',
    '还有未评分的项目，确定要继续吗？': 'There are unrated items. Are you sure you want to continue?',
    '取消': 'Cancel',
    '继续': 'Continue',
    '目标设定': 'Goal Setting',
    '确认恢复': 'Confirm Restore',
    '确定要恢复所有设定为默认值吗？': 'Are you sure you want to restore all settings to default?',
    '确定': 'OK',
    '已恢复为默认设定': 'Restored to default settings',
    '恢复失败：\$e': 'Restore failed: \$e',
    '保存成功': 'Saved successfully',
    '保存失败：\$e': 'Save failed: \$e',
    '恢复默认': 'Restore Defaults',
    '保存': 'Save',
    '快速评估': 'Quick Assessment',
    '完成评估': 'Complete Assessment',
    '评估对比': 'Assessment Comparison',
    '请选择一条历史记录': 'Please select a history record',
    '历史记录': 'History Records',
    '与历史对比': 'Compare with History',
    '趋势分析': 'Trend Analysis',
    '请至少选择一个能力项': 'Please select at least one ability',
    '请至少选择一个类别': 'Please select at least one category',
    '首页': 'Home',
    '评估': 'Assess',
    '历史': 'History',
    '设置': 'Settings',
    '雷达图主题': 'Radar Chart Theme',
    '创建自定义主题': 'Create Custom Theme',
    '删除主题': 'Delete Theme',
    '确定要删除「\${theme.name}」吗？此操作不可撤销。': 'Are you sure you want to delete \'\${theme.name}\'? This action cannot be undone.',
    '删除': 'Delete',
    '创建': 'Create',
    '选择\$label颜色': 'Select \$label Color',
    '请输入主题名称': 'Please enter a theme name',
    '主题「\$name」创建成功': 'Theme \'\$name\' created successfully',
    '备份与恢复': 'Backup & Restore',
    '导出或导入 JSON 格式的所有数据': 'Export or import all data in JSON format',
    '您可以将所有数据导出为 JSON 文件进行备份，或者从之前备份的 JSON 文件中恢复数据。': 'You can export all data to a JSON file for backup, or restore data from a previously backed-up JSON file.',
    '导入数据': 'Import Data',
    '导出数据': 'Export Data',
    '导入成功，数据已刷新': 'Import successful, data refreshed',
    '导入取消或失败（请检查文件格式是否正确）': 'Import canceled or failed (Please check file format)',
    '语言 (Language)': 'Language',
    '中文': 'Chinese',
    'English': 'English',
    '主题模式': 'Theme Mode',
    '跟随系统': 'System',
    '浅色模式': 'Light',
    '深色模式': 'Dark',
    '选择主题模式': 'Select Theme Mode',
    '雷达图样式': 'Radar Chart Style',
    '当前：\$radarStyle': 'Current: \$radarStyle',
    '默认样式': 'Default Style',
    '当前：\$themeName': 'Current: \$themeName',
    '模型名称已恢复默认': 'Model name restored to default',
    'Base URL 已恢复默认': 'Base URL restored to default',
    'Endpoint Path 已恢复默认': 'Endpoint Path restored to default',
    '如何获取免费 API Key？': 'How to get a free API Key?',
    'AI 教练提示词': 'AI Coach Prompts',
    '自定义 AI 教练的系统指令': 'Customize AI coach system instructions',
    '编辑 AI 教练提示词': 'Edit AI Coach Prompts',
    '提示词已恢复为默认设置': 'Prompts restored to default settings',
    '提示词已保存': 'Prompts saved',
    'AI 参数已恢复默认': 'AI parameters restored to default',
    '恢复默认参数': 'Restore Default Parameters',
    'AI 模型已恢复为默认设置': 'AI model restored to default settings',
    '恢复默认模型': 'Restore Default Model',
    '自定义各项能力的分数描述': 'Customize score descriptions for abilities',
    '清空所有评估记录': 'Clear All Assessment Records',
    '当前有': 'Currently',
    '条记录': 'records',
    '清空所有数据': 'Clear All Data',
    '确定要清空所有评估记录吗？此操作不可恢复！': 'Are you sure you want to clear all assessment records? This action cannot be recovered!',
    '已清空所有记录': 'All records cleared',
    '关于 Ultimate Wheel': 'About Ultimate Wheel',
    '飞盘之轮 - 与理想中的自己对话': 'Ultimate Wheel - Talk with your inner self',
    '飞盘之轮是一个帮助极限飞盘玩家进行自我评估的工具。': 'Ultimate Wheel is a tool to help ultimate frisbee players self-assess.',
    '核心理念：与理想中的自己对话，而非与他人比较。': 'Core philosophy: A conversation with your inner self, not a comparison with others.',
    '使用指南': 'User Guide',
    '跳过': 'Skip',
    '跳过引导': 'Skip Guide',
    '保存更新': 'Save Update',
    '深度评估(重新校准)': 'Deep Assessment (Recalibration)',
    '发起深度重新校准': 'Initiate Deep Recalibration',
    '生成 AI 分析失败: \$e': 'Failed to generate AI analysis: \$e',
    '获取 AI 智能分析': 'Get AI Analysis',
    '如何获取免费 API Key': 'How to get a free API Key',
    '关闭': 'Close',
    '前往硅基流动': 'Go to SiliconFlow',
    '数据管理': 'Data Management',
    '常规设置': 'General Settings',
    // --- Settings Section Headers ---
    '外观': 'Appearance',
    'AI 设置': 'AI Settings',
    '评估设置': 'Assessment Settings',
    '关于': 'About',
    
    // --- AI Settings Card ---
    'AI 服务配置': 'AI Service Configuration',
    'AI 模型服务商': 'AI Model Provider',
    '请输入您的 API Key': 'Please enter your API Key',
    'AI 模型名称': 'AI Model Name',
    'AI 参数': 'AI Parameters',
    'Temperature（创造性）': 'Temperature (Creativity)',
    'Max Tokens（输出长度上限）': 'Max Tokens (Output Limit)',
    '例如 2048': 'e.g. 2048',
    '缓存有效期（天）': 'Cache Validity (Days)',
    '恢复默认 URL': 'Restore Default URL',
    '恢复默认路径': 'Restore Default Path',
    'AI 模型设置': 'AI Model Settings',
    '当前模型为 SiliconFlow 提供的免费模型。目前仅支持 SiliconFlow 兼容接口。': 'The current model is a free model provided by SiliconFlow. Currently, only SiliconFlow-compatible interfaces are supported.',

    // --- Home Screen ---
    '飞盘之轮': 'Ultimate Wheel',
    '什么是飞盘之轮?': 'What is Ultimate Wheel?',
    '准备好开始\n第一次深度评估了吗？': 'Ready to start\nyour first deep assessment?',
    '还没有评估记录': 'No assessment records yet',
    '完成第一次评估后，这里会显示你的成长轨迹': 'After completing your first assessment, your growth trajectory will be displayed here',
    '整体均衡度': 'Overall Balance',
    '总评得分': 'Total Score',
    
    // --- Quick Assessment ---
    '用 5 分钟快速更新你的能力状态。根据你对当前状态的满意度进行评分。': 'Quickly update your ability status in 5 minutes. Rate based on your satisfaction with your current state.',

    // --- Categories & Abilities ---
    '身体': 'Athleticism',
    '技术': 'Technique',
    '意识': 'Awareness',
    '心灵': 'Mind',
    '跑跳': 'Running & Jumping',
    '灵敏': 'Agility',
    '体力': 'Endurance',
    '空间感': 'Spatial Awareness',
    '时机感': 'Timing',
    '明智': 'Game IQ',
    '传盘': 'Throwing',
    '接盘/读盘': 'Catching/Reading',
    '盯防': 'Marking',
    '跟防': 'Defending',
    '团队': 'Teamwork',
    '心态': 'Mentality',

    '绝对速度、爆发力、弹跳高度': 'Absolute speed, explosiveness, vertical jump',
    '变向、急停、身体控制和协调能力': 'Change of direction, sudden stops, body control and coordination',
    '场上续航、恢复速度、多场次作战能力': 'On-field endurance, recovery speed, multi-game capability',
    '场上位置感，观察和利用空间的能力': 'Positional awareness, ability to observe and utilize space',
    '对盘的飞行、人的跑动时间的预判能力': 'Anticipation of disc flight and player movement timing',
    '战术理解、场上决策能力': 'Tactical understanding, on-field decision-making',
    '各式传盘的精准度、力度和旋转控制': 'Accuracy, power, and spin control of various throws',
    '阅读飞行轨迹、稳定接盘、极限接盘的能力': 'Reading flight paths, stable catching, ultimate catch ability',
    '限制对手传盘的能力，包括站位、脚步、反应速度和有效的干扰': 'Ability to limit opponent throws, including positioning, footwork, reaction speed, and effective marking',
    '通过跑位、预判、起跳或飞扑（Layout）来获得防守得分（Block）的能力': 'Ability to get defensive blocks through positioning, anticipation, jumping, or layouts',
    '沟通、鼓励、融入体系、化学反应': 'Communication, encouragement, system integration, team chemistry',
    '专注度、抗压能力、情绪控制、飞盘精神': 'Focus, pressure resistance, emotional control, Spirit of the Game',

    // --- AI Providers ---
    '硅基流动': 'SiliconFlow',
    '智谱 GLM': 'Zhipu GLM',
    '阿里云百炼': 'Alibaba Cloud Bailian',
    '推荐默认选项，聚合模型多，国内访问友好。': 'Recommended default. Aggregates many models, friendly access in China.',
    'DeepSeek 官方接口，deepseek-chat 模型。': 'DeepSeek official API, deepseek-chat model.',
    'Moonshot 官方接口，支持kimi-k2.6、kimi-k2.5、moonshot-v1-8k、moonshot-v1-32k、moonshot-v1-128k。': 'Moonshot official API, supports kimi-k2.6, kimi-k2.5, moonshot-v1-8k/32k/128k.',
    '智谱 AI 官方接口，国内顶尖大模型。': 'Zhipu AI official API, top domestic large model.',
    '阿里云官方接口，调用通义千问大模型，推荐qwen-plus、qwen-turbo。': 'Alibaba Cloud official API, calls Tongyi Qianwen large model, recommends qwen-plus/qwen-turbo.',
    'OpenAI 官方接口。': 'OpenAI official API.',
    'Google 官方接口 (使用 OpenAI 兼容层)。': 'Google official API (using OpenAI compatibility layer).',
    
    // --- More assessment titles ---
    '定义你的巅峰：描绘你心中10分的样子': 'Define your peak: Picture your 10/10 self',
    '深度评估': 'Deep Assessment',
    '沉浸式体验：一次与自己对话的完整仪式': 'Immersive experience: A complete ritual  of conversation with yourself',
    '快速更新：用5分钟追踪你的即时状态': 'Quick update: Track your real-time status in 5 minutes',

    // --- AI Analysis ---
    'AI 智能分析': 'AI Analysis',
    'AI 教练分析中...可能需要几分钟，请耐心等待，不要切换到其它页面': 'AI Coach is analyzing... This may take a few minutes, please be patient and do not switch to other pages.',
    '点击展开查看详细分析': 'Tap to expand and view detailed analysis',
    '点击下方按钮，获取 AI 教练为您生成的专业分析报告': 'Tap the button below to get a professional analysis report generated by the AI Coach.',
    '暂无总体评价': 'No overall evaluation yet',
    '整体评价：': 'Overall Evaluation:',
    'Ultimate Wheel 评估分享': 'Ultimate Wheel Assessment Share',
    '请先在设置中配置 API Key': 'Please configure your API Key in Settings first',
    '生成 AI 分析时发生未知错误': 'An unknown error occurred while generating AI analysis',
    '我的Ultimate Wheel评估结果': 'My Ultimate Wheel Assessment Result',
    '评估时间：': 'Assessment Time: ',
    '总分：': 'Total Score: ',
    '进步了': 'Improved by ',
    '下降了': 'Declined by ',
    '分': ' points',
    '保持稳定': 'Remained stable',
    '我的Ultimate Wheel成长对比': 'My Ultimate Wheel Growth Comparison',
    '最新：': 'Latest: ',
    '历史：': 'History: ',
    '总分变化：': 'Score Change: ',
    
    // --- AI Provider ---
    '无权限创建报告': 'No permission to create report',
    '报告内容验证失败': 'Report content validation failed',
    '生成报告时发生未知错误': 'An unknown error occurred while generating the report',
    'API 请求失败': 'API request failed',
    '无法解析流中的数据行': 'Failed to parse data line in stream',
    '报告内容过短，可能生成不完整': 'Report content is too short, may be incomplete',
    '报告缺少必要章节': 'Report is missing necessary sections',
    '总体评价': 'Overall Evaluation',
    '分项评价': 'Itemized Evaluation',
    '行动计划': 'Action Plan',
    '当前评估数据': 'Current Assessment Data',
    '评估时间': 'Assessment Time',
    '评估类型': 'Assessment Type',
    '总分': 'Total Score',
    '各能力项得分': 'Scores by Ability',
    '备注': 'Note',
    '用户个人目标': 'User Personal Goals',
    '分目标': '-Point Goal',
    '用户整体感受': 'User Overall Feelings',
    
    // --- Share Service ---
    '已保存到本地': 'Saved to local',
    '保存失败': 'Save failed',
    '分享失败': 'Share failed',
    'Web暂不支持直接保存图片，请使用分享或浏览器另存': 'Direct image saving is not supported on Web, please use share or save as in browser',
    '截图失败，捕获的图片数据为空': 'Screenshot failed, captured image data is empty',
    '正在生成分享图片...': 'Generating share image...',

    // --- Tutorial ---
    """
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
""": """
### Step 1: Register and Login

Visit the [SiliconFlow official website](https://cloud.siliconflow.cn/i/oGFUsgLG), click the "Register" button, and use your email or phone number to complete the registration.

### Step 2: Enter the API Key Management Page

After successful login, click "API Keys" under "Account Management" on the left side of the page.

<!-- Click "API Keys" -->
<img src="assets/images/api_key.png" width="300"/>

### Step 3: Create a New API Key

On the API Key management page, click the "New API Key" button.
<!-- New API Key -->
<img src="assets/images/click_creat_apikey.png" width="300"/>
A popup will appear where you can type any description, then click the "Create Key" button.
<!-- New API Key Popup -->
<img src="assets/images/newapikey.png" width="300"/>

### Step 4: Copy Your API Key
The system will generate a new API Key. Click the copy button on the right side of the key to copy it to the clipboard.
<!-- Copy API Key Screenshot -->
<img src="assets/images/apikeycopy.png" width="300"/>

### Step 5: Paste the API Key into the App

Return to the "Settings" page of this app, paste the copied API Key into the input box of the "API Key Settings" card, and then click "Save API Key".

---

### Frequently Asked Questions (FAQ)

**Q1: Is this API Key free?**

A: For this project, yes. Because this project uses the free AI model provided by SiliconFlow: deepseek-ai/DeepSeek-R1-0528-Qwen3-8B.
So the call is free. And if you register for SiliconFlow using the link on this page, SiliconFlow will provide new registered users with free API call credits, enough for individual developers and light users. (It will also give me a little reward) Thank you~

**Q2: What if I forget my API Key?**

A: If you forget or lose your API Key, you can return to SiliconFlow's API Key management page to view and copy it.

**Q3: Why is my API Key invalid after saving?**

A: Please check whether you have copied the complete API Key, make sure there are no missing characters and no extra spaces.
""",
  }
};
