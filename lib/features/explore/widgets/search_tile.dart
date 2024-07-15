import 'package:flutter/material.dart';

import 'package:twitte_clone/features/user_profile/view/user_profile_view.dart';
import 'package:twitte_clone/models/user_model.dart';
import 'package:twitte_clone/theme/pallete.dart';

class SearchTile extends StatelessWidget {
  const SearchTile({required this.user, super.key});
  final UserModel user;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).push(UserProfileView.route(user)),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.profilePic),
        radius: 30,
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@${user.name}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            user.bio,
            style: const TextStyle(color: Pallete.whiteColor),
          )
        ],
      ),
    );
  }
}
