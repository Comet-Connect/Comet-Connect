import 'package:flutter/material.dart';
import 'menu.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Home Page',
      home: Scaffold(
        appBar: AppBar(
        title: const Text('Home Page'),
        
        ),
        drawer: const HamburgerMenu(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text(
                'Welcome back, Comet!',
                style: TextStyle(fontSize: 24.0),
              ),
              SizedBox(height: 16.0),
              Text(
                'This is your home page.',
                style: TextStyle(fontSize: 18.0),
              ),
              // const SizedBox(height: 16.0),
              // ElevatedButton(
              //   onPressed: () {
              //     // TODO: Implement button action
                  
              //   },
              //   child: const Text('Learn more'),
              //),
            ],
          ),
        ),
      ),
    );
  }
}



class HomePage2 extends StatelessWidget {
  const HomePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Page')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Page')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Page')),
    );
  }
}