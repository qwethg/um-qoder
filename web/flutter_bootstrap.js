{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // 使用阿里 npmmirror 提供的 canvaskit-wasm CDN
    // 版本号 0.39.1 对应 Flutter 3.24
    canvasKitBaseUrl: "https://registry.npmmirror.com/canvaskit-wasm/0.39.1/files/bin/"
  },
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}}
  }
});