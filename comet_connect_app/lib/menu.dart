import 'package:flutter/material.dart';

class HamburgerMenu extends StatelessWidget {
  const HamburgerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget> [
          const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu'),
            ),
          
          ListTile(
            title: const Text('Home'),
            onTap: () => Navigator.of(context).pushNamed('/home'),
          ),
          ListTile(
            title: const Text('View Calendar'),
            onTap: () => Navigator.of(context).pushNamed('/view-calendar'),
          ),
          ListTile(
            title: const Text('View Groups'),
            onTap: () => Navigator.of(context).pushNamed('/groups'),
          ),
          ListTile(
            title: const Text('Help'),
            onTap: () => Navigator.of(context).pushNamed('/help'),
          ),
          ListTile(
            title: const Text('Sign Out'),
            onTap: () => Navigator.of(context).pushNamed('/signout'),
          ),
        ],
      ),
    );
  }
}
