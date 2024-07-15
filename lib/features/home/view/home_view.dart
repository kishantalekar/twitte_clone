import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:twitte_clone/constants/constants.dart';
import 'package:twitte_clone/features/home/widgets/side_drawer.dart';
import 'package:twitte_clone/features/tweet/view/create_tweet_view.dart';
import 'package:twitte_clone/theme/theme.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  static route() => MaterialPageRoute(builder: (context) => const HomeView());

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final appbar = UIConstants.appBar();
  int _page = 0;
  void onPageChange(value) {
    setState(() {
      _page = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _page == 0 ? appbar : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(CreateTweetScreen.route());
        },
        child: const Icon(
          Icons.add,
          size: 28,
        ),
      ),
      drawer: const SideDrawer(),
      body: IndexedStack(
        index: _page,
        children: UIConstants.bottomTabBarPages,
      ),
      bottomNavigationBar: CupertinoTabBar(
        onTap: onPageChange,
        backgroundColor: Pallete.backgroundColor,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _page == 0
                  ? AssetsConstants.homeFilledIcon
                  : AssetsConstants.homeOutlinedIcon,
              colorFilter:
                  const ColorFilter.mode(Pallete.whiteColor, BlendMode.srcIn),
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AssetsConstants.searchIcon,
              colorFilter:
                  const ColorFilter.mode(Pallete.whiteColor, BlendMode.srcIn),
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _page == 2
                  ? AssetsConstants.notifFilledIcon
                  : AssetsConstants.notifOutlinedIcon,
              colorFilter:
                  const ColorFilter.mode(Pallete.whiteColor, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }
}
