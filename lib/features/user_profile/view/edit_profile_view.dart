import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/common/loading_page.dart';
import 'package:twitte_clone/core/utils.dart';
import 'package:twitte_clone/features/auth/controller/auth_controller.dart';
import 'package:twitte_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitte_clone/theme/pallete.dart';

class EditProfileView extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const EditProfileView());
  const EditProfileView({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  late final TextEditingController nameController;
  late final TextEditingController bioController;

  File? bannerFile;
  File? profileFile;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserDetailProvider).value!;

    nameController = TextEditingController(text: user.name);
    bioController = TextEditingController(text: user.bio);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    bioController.dispose();
  }

  void selectBannerImage() async {
    final banner = await pickImage();
    if (banner != null) {
      setState(() {
        bannerFile = banner;
      });
    }
  }

  void selectProfileImage() async {
    final profileImage = await pickImage();
    if (profileImage != null) {
      setState(() {
        profileFile = profileImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = ref.watch(currentUserDetailProvider).value;
    final isLoading = ref.watch(userProfileControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: false,
        actions: [
          TextButton(
              onPressed: () {
                ref
                    .read(userProfileControllerProvider.notifier)
                    .updateUserProfile(
                        userModel: user!.copyWith(
                            name: nameController.text, bio: bioController.text),
                        context: context,
                        bannerFile: bannerFile,
                        profileFile: profileFile);
              },
              child: const Text('save'))
        ],
      ),
      body: isLoading || user == null
          ? const Loader()
          : Column(children: [
              SizedBox(
                height: 200,
                child: Stack(children: [
                  GestureDetector(
                    onTap: selectBannerImage,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: bannerFile != null
                          ? Image.file(
                              bannerFile!,
                              fit: BoxFit.fitWidth,
                            )
                          : user.bannerPic.isEmpty
                              ? Container(
                                  color: Pallete.blueColor,
                                )
                              : Image.network(
                                  user.bannerPic,
                                  fit: BoxFit.fitWidth,
                                ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: GestureDetector(
                      onTap: selectProfileImage,
                      child: profileFile != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(profileFile!),
                              radius: 40,
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(
                                user.profilePic,
                              ),
                              radius: 40,
                            ),
                    ),
                  ),
                ]),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Name",
                  contentPadding: EdgeInsets.all(18),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Bio",
                  contentPadding: EdgeInsets.all(18),
                ),
              ),
            ]),
    );
  }
}
