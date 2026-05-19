import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ultimate_wheel/screens/welcome/welcome_screen.dart';
import 'package:ultimate_wheel/screens/home/home_screen.dart';
import 'package:ultimate_wheel/screens/assessment/assessment_entry_screen.dart';
import 'package:ultimate_wheel/screens/assessment/deep_assessment_screen.dart';
import 'package:ultimate_wheel/screens/assessment/unified_assessment_screen.dart';
import 'package:ultimate_wheel/screens/assessment/assessment_hub_screen.dart';
import 'package:ultimate_wheel/screens/assessment/goal_setting_screen.dart';
import 'package:ultimate_wheel/screens/assessment/assessment_result_screen.dart';
import 'package:ultimate_wheel/screens/assessment/unified_assessment_result_screen.dart';
import 'package:ultimate_wheel/screens/history/history_screen.dart';
import 'package:ultimate_wheel/screens/history/comparison_screen.dart';
import 'package:ultimate_wheel/screens/history/trend_screen.dart';
import 'package:ultimate_wheel/screens/settings/settings_screen.dart';
import 'package:ultimate_wheel/screens/settings/radar_theme_manager_screen.dart';
import 'package:ultimate_wheel/screens/settings/guide_screen.dart';
import 'package:ultimate_wheel/screens/main_navigation.dart';

/// 应用路由配置
class AppRouter {
  static GoRouter createRouter(bool isFirstLaunch) {
    return GoRouter(
      initialLocation: isFirstLaunch ? '/welcome' : '/home',
      routes: [
        // 欢迎页
        GoRoute(
          path: '/welcome',
          name: 'welcome',
          builder: (context, state) => const WelcomeScreen(),
          routes: [
            // 从欢迎页进入的使用指南 (不带底部导航栏)
            GoRoute(
              path: 'guide',
              name: 'welcome-guide',
              builder: (context, state) => const GuideScreen(fromWelcome: true),
            ),
          ],
        ),

        // 主导航框架 (包含底部导航栏)
        ShellRoute(
          builder: (context, state, child) => MainNavigation(child: child),
          routes: [
            // 首页
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),

            // 评估 (03)
            GoRoute(
              path: '/assessment',
              name: 'assessment',
              builder: (context, state) => const AssessmentHubScreen(),
              routes: [
                // 目标设定
                GoRoute(
                  path: 'goal-setting',
                  name: 'goal-setting',
                  builder: (context, state) => const GoalSettingScreen(),
                ),
                // 深度评估 (直接入口，用于设置里的发起)
                GoRoute(
                  path: 'deep',
                  name: 'deep-assessment',
                  builder: (context, state) => const DeepAssessmentScreen(),
                ),
                // 统一评估入口 (包装器)
                GoRoute(
                  path: 'entry',
                  name: 'assessment-entry',
                  builder: (context, state) => const AssessmentEntryScreen(),
                ),
                // 统一评估单页 (用于跳过深度评估时跳转)
                GoRoute(
                  path: 'quick',
                  name: 'quick-assessment',
                  builder: (context, state) => const UnifiedAssessmentScreen(),
                ),
              ],
            ),

            // 历史记录
            GoRoute(
              path: '/history',
              name: 'history',
              builder: (context, state) => const HistoryScreen(),
              routes: [
                // 趋势分析
                GoRoute(
                  path: 'trend',
                  name: 'trend',
                  builder: (context, state) => const TrendScreen(),
                ),
                // 评估对比
                GoRoute(
                  path: 'comparison/:latestId',
                  name: 'comparison',
                  builder: (context, state) {
                    final latestId = state.pathParameters['latestId']!;
                    final selectedId = state.uri.queryParameters['selectedId'];
                    return ComparisonScreen(
                      latestAssessmentId: latestId,
                      selectedAssessmentId: selectedId,
                    );
                  },
                ),
              ],
            ),

            // 设置
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                // 雷达图主题管理
                GoRoute(
                  path: 'radar-theme',
                  name: 'radar-theme',
                  builder: (context, state) => const RadarThemeManagerScreen(),
                ),
                // 使用指南
                GoRoute(
                  path: 'guide',
                  name: 'guide',
                  builder: (context, state) {
                    final fromWelcome = state.uri.queryParameters['fromWelcome'] == 'true';
                    return GuideScreen(fromWelcome: fromWelcome);
                  },
                ),
              ],
            ),
          ],
        ),

        // 评估结果页 (独立页面，不在主导航框架内)
        GoRoute(
          path: '/assessment/result/:id',
          name: 'assessment-result',
          builder: (context, state) {
            final assessmentId = state.pathParameters['id']!;
            return AssessmentResultScreen(assessmentId: assessmentId);
          },
        ),
        // 统一评估结果页 (Zen 风格)
        GoRoute(
          path: '/assessment/unified-result/:id',
          name: 'unified-assessment-result',
          builder: (context, state) {
            final assessmentId = state.pathParameters['id']!;
            return UnifiedAssessmentResultScreen(assessmentId: assessmentId);
          },
        ),
      ],
    );
  }
}
