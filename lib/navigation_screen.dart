import 'package:flutter/material.dart';
import 'package:messanger_app/Main%20Screens/other_users.dart';
import 'package:messanger_app/Main%20Screens/user_profile.dart';
import 'package:messanger_app/Main%20Screens/home.dart';

import 'Class Files/color.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({Key? key}) : super(key: key);

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AColor.backgroundColor,
      body: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          decoration: const BoxDecoration(
            gradient: AColor.buttonGradientShader,
            shape: BoxShape.circle,
          ),
          height: 70,
          width: 70,
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            child: const Icon(Icons.message_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UsersList(),
                ),
              );
            },
          ),
        ),
        body: _selectedIndex == 0 ? const HomeScreen() : const UserProfile(),
        bottomNavigationBar: cusBottomBar(),
        backgroundColor: AColor.backgroundColor,
      ),
    );
  }

  Widget cusBottomBar() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(50), topRight: Radius.circular(50)),
          child: SizedBox(
            height: 75,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              unselectedItemColor: Colors.grey,
              selectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_outlined,
                    size: 30,
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person_outline_rounded,
                    size: 30,
                  ),
                  label: '',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: (_) {
                setState(() {
                  _selectedIndex = _;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _pageController.animateToPage(index,
  //         duration: const Duration(milliseconds: 500), curve: Curves.linear);
  //   });
  // }
}
