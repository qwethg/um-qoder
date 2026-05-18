import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/radar_theme.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/config/l10n.dart';
import 'package:ultimate_wheel/config/theme.dart';
import 'package:ultimate_wheel/widgets/ultimate_wheel_radar_chart.dart';

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

  Future<Uint8List> generateAssessmentImageBytes({
    required Assessment assessment,
    required RadarTheme theme,
    bool includeSummary = true,
    bool includeCategoryScores = false,
    bool includeTotalScore = true,
    double imageWidth = 1080,
    double safeMargin = 60,
    double radarSize = 600,
    double pixelRatio = 3.0,
  }) async {
    final controller = ScreenshotController();
    final dateText = DateFormat('yyyy-MM-dd HH:mm').format(assessment.createdAt);
    final totalText = assessment.totalScore.toStringAsFixed(1);
    final themeData = AppTheme.lightTheme;
    final cs = themeData.colorScheme;
    final tt = themeData.textTheme;

    double _measureTextHeight(String text, TextStyle style, double maxWidth) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: ui.TextDirection.ltr,
        maxLines: null,
      );
      tp.layout(maxWidth: maxWidth);
      return tp.height;
    }
    final categoryWidgets = AbilityCategory.values.map((category) {
      final abilityIds = AbilityConstants.getAbilitiesByCategory(category).map((a) => a.id).toList();
      final catScore = assessment.getCategoryScore(abilityIds).toStringAsFixed(1);
      final color = theme.getCategoryColor(category.colorIndex);
      return Row(
        children: [
          Expanded(
            child: Text(
              category.name,
              style: tt.bodyMedium,
            ),
          ),
          SizedBox(
            width: 64,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                catScore,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ),
        ],
      );
    }).toList();

    final contentWidth = imageWidth - safeMargin * 2;
    final clampedRadar = radarSize.clamp(240.0, contentWidth * 0.72);
    final titleH = _measureTextHeight('Ultimate Wheel 评估分享', tt.titleLarge!.copyWith(fontWeight: FontWeight.bold), contentWidth);
    final dateH = _measureTextHeight(dateText, tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant), contentWidth);
    final totalCardH = includeTotalScore ? 48.0 : 0.0;
    final ringsH = includeCategoryScores ? (12 + 2 * 128 + 12 + 12) : 0.0; // padding + two rows + spacing + border padding
    final summaryText = assessment.aiAnalysisSummary?.trim().isNotEmpty == true
        ? assessment.aiAnalysisSummary!.trim()
        : '暂无总体评价'.tr;
    final evalTitleH = includeSummary ? _measureTextHeight('整体评价：'.tr, tt.titleMedium!.copyWith(fontWeight: FontWeight.w600), contentWidth - 32) : 0.0;
    final evalTextH = includeSummary ? _measureTextHeight(summaryText, tt.bodyMedium!.copyWith(height: 1.6), contentWidth - 32) : 0.0;
    final evalCardH = includeSummary ? (16 + evalTitleH + 8 + evalTextH + 16) : 0.0; // padding + title + spacing + text + padding
    final tagH = _measureTextHeight('#极限飞盘 #UltimateWheel', tt.bodySmall!.copyWith(color: cs.onSurfaceVariant), contentWidth);
    final totalHeight = safeMargin + titleH + 6 + dateH + 12 + totalCardH + 12 + clampedRadar + 12 + ringsH + 12 + evalCardH + 8 + tagH + safeMargin;

    final widget = Theme(
      data: themeData,
      child: MediaQuery(
        data: MediaQueryData(size: Size(imageWidth, totalHeight)),
        child: Material(
          color: cs.surface,
          child: SizedBox(
            width: imageWidth,
            height: totalHeight,
            child: Padding(
              padding: EdgeInsets.all(safeMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Ultimate Wheel 评估分享'.tr, style: tt.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(dateText, style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                  if (includeTotalScore) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outline, width: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('总分'.tr, style: tt.titleMedium),
                          const SizedBox(width: 8),
                          Text(totalText, style: tt.headlineMedium!.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  UltimateWheelRadarChart(
                    scores: assessment.scores,
                    size: clampedRadar,
                    radarTheme: theme,
                    showGrid: true,
                    showLabels: true,
                    showStroke: false,
                  ),
                  if (includeCategoryScores) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outline, width: 0.5),
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: AbilityCategory.values.map((category) {
                          final ids = AbilityConstants.getAbilitiesByCategory(category).map((a) => a.id).toList();
                          final catScore = assessment.getCategoryScore(ids);
                          final color = theme.getCategoryColor(category.colorIndex);
                          return CategoryRingScore(label: category.name, value: catScore, color: color, size: 128);
                        }).toList(),
                      ),
                    ),
                  ],
                  if (includeSummary) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outline, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('整体评价：'.tr, style: tt.titleMedium!.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(
                            summaryText,
                            style: tt.bodyMedium!.copyWith(height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text('#极限飞盘 #UltimateWheel', style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final bytes = await controller.captureFromWidget(widget, pixelRatio: pixelRatio);
    return bytes;
  }

  Future<String?> saveImageToLocal({
    required BuildContext context,
    required Uint8List imageBytes,
    required String fileNamePrefix,
    String? customDirPath,
  }) async {
    try {
      if (kIsWeb) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Web暂不支持直接保存图片，请使用分享或浏览器另存'.tr)),
          );
        }
        return null;
      }
      Directory targetDir;
      if (customDirPath != null && customDirPath.trim().isNotEmpty) {
        targetDir = Directory(customDirPath.trim());
      } else {
        if (Platform.isAndroid) {
          final Directory? ext = await getExternalStorageDirectory();
          targetDir = Directory('${ext?.path ?? (await getTemporaryDirectory()).path}/UltimateWheel');
        } else if (Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
          targetDir = await getApplicationDocumentsDirectory();
        } else {
          targetDir = await getTemporaryDirectory();
        }
      }
      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String fileName = '${fileNamePrefix}_$timestamp.png';
      final File file = File('${targetDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);
      logger.info('图片已保存到本地: ${file.path}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'已保存到本地'.tr}: ${file.path}')),
        );
      }
      return file.path;
    } catch (e, s) {
      logger.error('保存图片失败', e, s);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'保存失败'.tr}：$e'), backgroundColor: Colors.red),
        );
      }
      return null;
    }
  }

  Future<void> shareImageBytes({
    required BuildContext context,
    required Uint8List imageBytes,
    required String shareText,
    String? fileName,
  }) async {
    try {
      if (kIsWeb) {
        final XFile xFile = XFile.fromData(
          imageBytes,
          name: fileName ?? 'ultimate_wheel_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png',
          mimeType: 'image/png',
        );
        await Share.shareXFiles([xFile], text: shareText);
        return;
      }
      final Directory tempDir = await getTemporaryDirectory();
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String fName = fileName ?? 'ultimate_wheel_$timestamp.png';
      final File file = File('${tempDir.path}/$fName');
      await file.writeAsBytes(imageBytes);
      final XFile xFile = XFile(file.path);
      await Share.shareXFiles([xFile], text: shareText);
      Future.delayed(const Duration(seconds: 10), () {
        try {
          if (file.existsSync()) {
            file.deleteSync();
            logger.info('临时文件已删除: ${file.path}');
          }
        } catch (e, s) {
          logger.error('删除临时文件失败: ${file.path}', e, s);
        }
      });
    } catch (e, s) {
      logger.error('分享图片失败', e, s);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'分享失败'.tr}：$e'), backgroundColor: Colors.red),
        );
      }
    }
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
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text('正在生成分享图片...'.tr),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // 捕获截图
      final Uint8List? imageBytes = await screenshotController.capture(
        pixelRatio: 3.0, // 高清截图
      );

      if (imageBytes == null) {
        throw Exception('截图失败，捕获的图片数据为空'.tr);
      }
      logger.debug('截图成功，图片大小: ${imageBytes.lengthInBytes} bytes');

      final String shareText = '${'我的Ultimate Wheel评估结果'.tr}\n${'评估时间：'.tr}$assessmentDate\n${'总分：'.tr}${totalScore.toStringAsFixed(1)}\n\n#极限飞盘 #UltimateWheel';

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
            content: Text('${'分享失败'.tr}：$e'),
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
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text('正在生成分享图片...'.tr),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // 捕获截图
      final Uint8List? imageBytes = await screenshotController.capture(
        pixelRatio: 3.0,
      );

      if (imageBytes == null) {
        throw Exception('截图失败，捕获的图片数据为空'.tr);
      }
      logger.debug('对比图截图成功，图片大小: ${imageBytes.lengthInBytes} bytes');

      // 生成分享文本
      final String changeText = scoreDifference > 0 
          ? '${'进步了'.tr}${scoreDifference.toStringAsFixed(1)}${'分'.tr}' 
          : scoreDifference < 0
              ? '${'下降了'.tr}${(-scoreDifference).toStringAsFixed(1)}${'分'.tr}'
              : '保持稳定'.tr;

      final String shareText = '${'我的Ultimate Wheel成长对比'.tr}\n${'最新：'.tr}$latestDate\n${'历史：'.tr}$historicalDate\n${'总分变化：'.tr}$changeText\n\n#极限飞盘 #UltimateWheel #成长记录';

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
            content: Text('${'分享失败'.tr}：$e'),
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
            content: Text('${'分享失败'.tr}：$e'),
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

class CategoryRingScore extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double size;

  const CategoryRingScore({super.key, required this.label, required this.value, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0, 10) / 10).toDouble();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(progress: pct, color: color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value.toStringAsFixed(1), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 8;
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = color.withOpacity(0.15)
      ..strokeCap = StrokeCap.round;
    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = color
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);
    final start = -math.pi / 2;
    final sweep = progress * 2 * math.pi;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, start, sweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
