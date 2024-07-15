import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/common/error_page.dart';
import 'package:twitte_clone/common/loading_page.dart';
import 'package:twitte_clone/features/explore/controller/explore_controller.dart';
import 'package:twitte_clone/features/explore/widgets/search_tile.dart';
import 'package:twitte_clone/theme/pallete.dart';

class ExploreView extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const ExploreView());
  const ExploreView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExploreViewState();
}

class _ExploreViewState extends ConsumerState<ExploreView> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  bool isShowUser = false;

  @override
  Widget build(BuildContext context) {
    final appBarTextFieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(color: Pallete.searchBarColor),
    );
    return Scaffold(
      appBar: AppBar(
          title: SizedBox(
        height: 50,
        child: TextField(
          onSubmitted: (value) {
            setState(() {
              isShowUser = true;
            });
          },
          controller: searchController,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10).copyWith(left: 20),
              fillColor: Pallete.searchBarColor,
              filled: true,
              enabledBorder: appBarTextFieldBorder,
              focusedBorder: appBarTextFieldBorder,
              hintText: "Search Twitter"),
        ),
      )),
      body: isShowUser
          ? ref.watch(searchUserProvider(searchController.text)).when(
              data: (users) {
                return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return SearchTile(
                        user: user,
                      );
                    });
              },
              error: (error, st) => ErrorText(error: error.toString()),
              loading: () => const Loader())
          : const SizedBox(),
    );
  }
}
