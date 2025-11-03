import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// 分享服务 - 处理截图和分享逻辑
class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  /// 创建截图控制器
  ScreenshotController createScreenshotController() {
    return ScreenshotController();
  }

  /// 分享雷达图（评估结果）
  Future<void> shareAssessment({
    required BuildContext context,
    required ScreenshotController screenshotController,
    required String assessmentDate,
    required double totalScore,
  }) async {
    try {
      // 显示加载提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('正在生成分享图片...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // 捕获截图
      final Uint8List? imageBytes = await screenshotController.capture(
        pixelRatio: 3.0, // 高清截图
      );

      if (imageBytes == null) {
        throw Exception('截图失败');
      }

      final String shareText = '我的Ultimate Wheel评估结果\n评估时间：$assessmentDate\n总分：${totalScore.toStringAsFixed(1)}\n\n#极限飞盘 #UltimateWheel';

      // Web环境处理
      if (kIsWeb) {
        // Web环境下直接分享图片数据，不保存到文件系统
        final XFile xFile = XFile.fromData(
          imageBytes,
          name: 'ultimate_wheel_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png',
          mimeType: 'image/png',
        );
        
        await Share.shareXFiles(
          [xFile],
          text: shareText,
        );
      } else {
        // 移动端/桌面端：保存到临时目录
        final Directory tempDir = await getTemporaryDirectory();
        final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final String fileName = 'ultimate_wheel_$timestamp.png';
        final File file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(imageBytes);

        // 分享文件
        final XFile xFile = XFile(file.path);
        await Share.shareXFiles(
          [xFile],
          text: shareText,
        );

        // 分享完成后删除临时文件（延迟删除，确保分享完成）
        Future.delayed(const Duration(seconds: 5), () {
          if (file.existsSync()) {
            file.delete();
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 分享对比图
  Future<void> shareComparison({
    required BuildContext context,
    required ScreenshotController screenshotController,
    required String latestDate,
    required String historicalDate,
    required double scoreDifference,
  }) async {
    try {
      // 显示加载提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('正在生成分享图片...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // 捕获截图
      final Uint8List? imageBytes = await screenshotController.capture(
        pixelRatio: 3.0,
      );

      if (imageBytes == null) {
        throw Exception('截图失败');
      }

      // 生成分享文本
      final String changeText = scoreDifference > 0 
          ? '进步了${scoreDifference.toStringAsFixed(1)}分' 
          : scoreDifference < 0
              ? '下降了${(-scoreDifference).toStringAsFixed(1)}分'
              : '保持稳定';

      final String shareText = '我的Ultimate Wheel成长对比\n最新：$latestDate\n历史：$historicalDate\n总分变化：$changeText\n\n#极限飞盘 #UltimateWheel #成长记录';

      // Web环境处理
      if (kIsWeb) {
        // Web环境下直接分享图片数据，不保存到文件系统
        final XFile xFile = XFile.fromData(
          imageBytes,
          name: 'ultimate_wheel_comparison_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png',
          mimeType: 'image/png',
        );
        
        await Share.shareXFiles(
          [xFile],
          text: shareText,
        );
      } else {
        // 移动端/桌面端：保存到临时目录
        final Directory tempDir = await getTemporaryDirectory();
        final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final String fileName = 'ultimate_wheel_comparison_$timestamp.png';
        final File file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(imageBytes);

        // 分享文件
        final XFile xFile = XFile(file.path);
        await Share.shareXFiles(
          [xFile],
          text: shareText,
        );

        // 分享完成后删除临时文件
        Future.delayed(const Duration(seconds: 5), () {
          if (file.existsSync()) {
            file.delete();
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 分享纯文本（备用方案）
  Future<void> shareText({
    required BuildContext context,
    required String text,
  }) async {
    try {
      await Share.share(text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 从GlobalKey捕获截图（备用方案）
  Future<Uint8List?> captureFromKey(GlobalKey key) async {
    try {
      RenderRepaintBoundary? boundary = 
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) return null;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('截图失败: $e');
      return null;
    }
  }
}
