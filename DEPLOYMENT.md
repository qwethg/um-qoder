# 🚀 Ultimate Wheel Web部署指南

## 📋 部署前准备

### 1. 确保构建成功
```bash
flutter clean
flutter pub get
flutter build web --release
```

### 2. 测试本地Web版本
```bash
flutter run -d chrome --release
```

---

## 🌟 方案一：Vercel部署（推荐）

### 步骤：
1. **注册Vercel账号**：访问 [vercel.com](https://vercel.com)
2. **连接GitHub**：授权Vercel访问您的GitHub仓库
3. **导入项目**：
   - 点击"New Project"
   - 选择您的GitHub仓库
   - 框架预设选择"Other"
4. **配置构建设置**：
   - Build Command: `flutter build web --release`
   - Output Directory: `build/web`
   - Install Command: `flutter pub get`
5. **部署**：点击"Deploy"按钮

### 环境变量设置：
- `FLUTTER_VERSION`: `3.24.5`

---

## 🔥 方案二：Netlify部署

### 步骤：
1. **注册Netlify账号**：访问 [netlify.com](https://netlify.com)
2. **连接GitHub**：授权Netlify访问您的仓库
3. **新建站点**：
   - 点击"New site from Git"
   - 选择GitHub仓库
4. **构建设置**：
   - Build command: `flutter build web --release`
   - Publish directory: `build/web`
5. **部署**：点击"Deploy site"

---

## 📱 方案三：GitHub Pages部署

### 步骤：
1. **启用GitHub Pages**：
   - 进入仓库Settings
   - 找到Pages选项
   - Source选择"GitHub Actions"
2. **推送代码**：GitHub Actions会自动构建和部署
3. **访问网站**：`https://yourusername.github.io/UW-qoder/`

---

## 🔧 方案四：Firebase Hosting

### 步骤：
1. **安装Firebase CLI**：
   ```bash
   npm install -g firebase-tools
   ```
2. **登录Firebase**：
   ```bash
   firebase login
   ```
3. **初始化项目**：
   ```bash
   firebase init hosting
   ```
4. **配置firebase.json**：
   ```json
   {
     "hosting": {
       "public": "build/web",
       "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
       "rewrites": [
         {
           "source": "**",
           "destination": "/index.html"
         }
       ]
     }
   }
   ```
5. **部署**：
   ```bash
   flutter build web --release
   firebase deploy
   ```

---

## 🎯 自定义域名配置

### Vercel：
1. 进入项目设置
2. 点击"Domains"
3. 添加您的域名
4. 配置DNS记录

### Netlify：
1. 进入站点设置
2. 点击"Domain management"
3. 添加自定义域名
4. 更新DNS设置

---

## 📊 性能优化建议

### 1. 启用Gzip压缩
大多数平台默认启用，确保静态资源被压缩

### 2. CDN加速
- Vercel和Netlify自带全球CDN
- 可考虑使用Cloudflare进一步优化

### 3. 缓存策略
- 静态资源设置长期缓存
- HTML文件设置短期缓存

### 4. 图片优化
- 使用WebP格式
- 实现懒加载

---

## 🔍 监控和分析

### 1. Google Analytics
在`web/index.html`中添加GA代码

### 2. 性能监控
- 使用Lighthouse检测性能
- 监控Core Web Vitals

### 3. 错误追踪
- 集成Sentry或类似服务
- 监控用户体验问题

---

## 🚨 常见问题解决

### 1. 路由问题
确保服务器配置了SPA重写规则

### 2. 字体加载问题
检查字体文件路径和CORS设置

### 3. 构建失败
- 检查Flutter版本兼容性
- 清理缓存重新构建

---

## 📞 技术支持

如遇到部署问题，请检查：
1. Flutter版本是否匹配
2. 依赖包是否支持Web
3. 构建日志中的错误信息
4. 网络连接是否正常