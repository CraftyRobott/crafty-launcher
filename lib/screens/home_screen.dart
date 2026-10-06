import 'package:flutter/material.dart';

import '../widgets/menu_list.dart';
import 'favorites_screen.dart';
import 'games_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 60,
            top: 60,
          ),
          child: MenuList(
            items: const [
              'GAMES',
              'FAVORITES',
              'APPS',
              'SETTINGS',
            ],
            onSelected: (index) {
              switch (index) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GamesScreen(),
                    ),
                  );
                  break;

                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FavoritesScreen(),
                    ),
                  );
                  break;

                case 2:
                  debugPrint('APPS selected');
                  break;

                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}