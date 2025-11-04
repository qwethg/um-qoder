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

import 'logger_service.dart';

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
      logger.info('开始分享评估结果...');
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
        throw Exception('截图失败，捕获的图片数据为空');
      }
      logger.debug('截图成功，图片大小: ${imageBytes.lengthInBytes} bytes');

      final String shareText = '我的Ultimate Wheel评估结果\n评估时间：$assessmentDate\n总分：${totalScore.toStringAsFixed(1)}\n\n#极限飞盘 #UltimateWheel';

      // Web环境处理
      if (kIsWeb) {
        logger.info('Web环境，直接分享图片数据');
        final XFile xFile = XFile.fromData(
          imageBytes,
          name: 'ultimate_wheel_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png',
          mimeType: 'image/png',
        );
        
        await Share.shareXFiles(
          [xFile],
          text: shareText,
        );
        logger.info('Web分享调用完成');
      } else {
        // 移动端/桌面端：保存到临时目录
        final Directory tempDir = await getTemporaryDirectory();
        final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final String fileName = 'ultimate_wheel_$timestamp.png';
        final File file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(imageBytes);
        logger.info('图片已保存到临时文件: ${file.path}');

        // 分享文件
        final XFile xFile = XFile(file.path);
        await Share.shareXFiles(
          [xFile],
          text: shareText,
        );
        logger.info('移动端分享调用完成');

        // 分享完成后删除临时文件（延迟删除，确保分享完成）
        Future.delayed(const Duration(seconds: 10), () {
          try {
            if (file.existsSync()) {
              file.deleteSync();
              logger.info('临时文件已删除: ${file.path}');
            } else {
              logger.warning('尝试删除临时文件但文件不存在: ${file.path}');
            }
          } catch (e, s) {
            logger.error('删除临时文件失败: ${file.path}', e, s);
          }
        });
      }
    } catch (e, s) {
      logger.error('分享评估结果失败', e, s);
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
      logger.info('开始分享对比图...');
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
        throw Exception('截图失败，捕获的图片数据为空');
      }
      logger.debug('对比图截图成功，图片大小: ${imageBytes.lengthInBytes} bytes');

      // 生成分享文本
      final String changeText = scoreDifference > 0 
          ? '进步了${scoreDifference.toStringAsFixed(1)}分' 
          : scoreDifference < 0
              ? '下降了${(-scoreDifference).toStringAsFixed(1)}分'
              : '保持稳定';

      final String shareText = '我的Ultimate Wheel成长对比\n最新：$latestDate\n历史：$historicalDate\n总分变化：$changeText\n\n#极限飞盘 #UltimateWheel #成长记录';

      // Web环境处理
      if (kIsWeb) {
        logger.info('Web环境，直接分享对比图数据');
        final XFile xFile = XFile.fromData(
          imageBytes,
          name: 'ultimate_wheel_comparison_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png',
          mimeType: 'image/png',
        );
        
        await Share.shareXFiles(
          [xFile],
          text: shareText,
        );
        logger.info('Web对比图分享调用完成');
      } else {
        // 移动端/桌面端：保存到临时目录
        final Directory tempDir = await getTemporaryDirectory();
        final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final String fileName = 'ultimate_wheel_comparison_$timestamp.png';
        final File file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(imageBytes);
        logger.info('对比图已保存到临时文件: ${file.path}');

        // 分享文件
        final XFile xFile = XFile(file.path);
        await Share.shareXFiles(
          [xFile],
          text: shareText,
        );
        logger.info('移动端对比图分享调用完成');

        // 分享完成后删除临时文件
        Future.delayed(const Duration(seconds: 10), () {
          try {
            if (file.existsSync()) {
              file.deleteSync();
              logger.info('临时文件已删除: ${file.path}');
            } else {
              logger.warning('尝试删除临时文件但文件不存在: ${file.path}');
            }
          } catch (e, s) {
            logger.error('删除临时文件失败: ${file.path}', e, s);
          }
        });
      }
    } catch (e, s) {
      logger.error('分享对比图失败', e, s);
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
      logger.info('开始分享纯文本: "$text"');
      await Share.share(text);
      logger.info('纯文本分享调用完成');
    } catch (e, s) {
      logger.error('分享纯文本失败', e, s);
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
      logger.info('开始从 GlobalKey 捕获截图');
      RenderRepaintBoundary? boundary = 
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        logger.warning('无法找到 RenderRepaintBoundary');
        return null;
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      logger.info('从 GlobalKey 捕获截图成功, 大小: ${bytes?.lengthInBytes ?? 0} bytes');
      return bytes;
    } catch (e, s) {
      logger.error('从 GlobalKey 捕获截图失败', e, s);
      return null;
    }
  }
}
