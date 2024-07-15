import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/common/error_page.dart';
import 'package:twitte_clone/common/loading_page.dart';
import 'package:twitte_clone/features/auth/controller/auth_controller.dart';

import 'package:twitte_clone/features/auth/view/signup_view.dart';
import 'package:twitte_clone/features/home/view/home_view.dart';
import 'package:twitte_clone/theme/theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLogin = ref.watch(currentUserAccountProvider);

    return MaterialApp(
      title: 'Twitter clone',
      theme: AppTheme.theme,
      home: isLogin.when(
          data: (user) {
            if (user != null) {
              return const HomeView();
            }
            return const SignUpView();
          },
          error: (error, st) => ErrorPage(error: error.toString()),
          loading: () => const LoadingPage()),
    );
  }
}
