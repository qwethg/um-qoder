import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ultimate_wheel/screens/welcome/welcome_screen.dart';
import 'package:ultimate_wheel/screens/home/home_screen.dart';
import 'package:ultimate_wheel/screens/assessment/assessment_hub_screen.dart';
import 'package:ultimate_wheel/screens/assessment/goal_setting_screen.dart';
import 'package:ultimate_wheel/screens/assessment/deep_assessment_screen.dart';
import 'package:ultimate_wheel/screens/assessment/quick_assessment_screen.dart';
import 'package:ultimate_wheel/screens/assessment/assessment_result_screen.dart';
import 'package:ultimate_wheel/screens/history/history_screen.dart';
import 'package:ultimate_wheel/screens/settings/settings_screen.dart';
import 'package:ultimate_wheel/screens/main_navigation.dart';

/// 应用路由配置
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/welcome',
    routes: [
      // 欢迎页
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
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

          // 评估中心
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
              // 深度评估
              GoRoute(
                path: 'deep',
                name: 'deep-assessment',
                builder: (context, state) => const DeepAssessmentScreen(),
              ),
              // 快速评估
              GoRoute(
                path: 'quick',
                name: 'quick-assessment',
                builder: (context, state) => const QuickAssessmentScreen(),
              ),
            ],
          ),

          // 历史记录
          GoRoute(
            path: '/history',
            name: 'history',
            builder: (context, state) => const HistoryScreen(),
          ),

          // 设置
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
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
    ],
  );
}
