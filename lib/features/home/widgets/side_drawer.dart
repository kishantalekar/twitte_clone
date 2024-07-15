import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/common/loading_page.dart';
import 'package:twitte_clone/features/auth/controller/auth_controller.dart';
import 'package:twitte_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitte_clone/features/user_profile/view/user_profile_view.dart';
import 'package:twitte_clone/theme/pallete.dart';

class SideDrawer extends ConsumerWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailProvider).value;
    return currentUser == null
        ? const Loader()
        : SafeArea(
            child: Drawer(
              backgroundColor: Pallete.backgroundColor,
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  ListTile(
                    onTap: () => Navigator.of(context)
                        .push(UserProfileView.route(currentUser)),
                    leading: const Icon(
                      Icons.person,
                      size: 30,
                    ),
                    title: const Text(
                      'My Profile',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.payment,
                      size: 30,
                    ),
                    title: const Text(
                      'Twitter Blue',
                      style: TextStyle(fontSize: 22),
                    ),
                    onTap: () {
                      ref
                          .read(userProfileControllerProvider.notifier)
                          .updateUserProfile(
                              userModel:
                                  currentUser.copyWith(isTwitterBlue: true),
                              context: context,
                              bannerFile: null,
                              profileFile: null);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      size: 30,
                    ),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                    onTap: () {
                      ref.read(authControllerProvider.notifier).logout(context);
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
