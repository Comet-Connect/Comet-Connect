import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login.dart';

class HamburgerMenu extends StatelessWidget {
  const HamburgerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[300],
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                // TODO: Link with backend
                UserAccountsDrawerHeader(
                  accountName: const Text("Welcome,"), // fetch user
                  accountEmail: Text(current_loggedin_user!), // Need to fetch email
                  
                  // currentAccountPicture: const CircleAvatar(
                  //   backgroundImage: NetworkImage(''),
                  // ),
                  // otherAccountsPictures: [
                  //   GestureDetector(
                  //     onTap: () async {
                  //       // Show a file picker dialog to let the user choose an image file
                  //       final pickedFile = await ImagePicker()
                  //           .getImage(source: ImageSource.gallery, imageQuality: 50);
                  //       // If the user picked an image file, update the profile picture
                  //       //if (pickedFile != null) {
                  //       // Upload the image file to your server and get the image URL
                  //       // final imageUrl =
                  //       //     await uploadProfilePicture(pickedFile as XFile);
                  //       // Update the profile picture
                  //       // if (imageUrl != null) {
                  //       //   final drawerState = Scaffold.of(context).openDrawer();
                  //       //   drawerState.then((_) {
                  //       //     setState(() {
                  //       //       _profilePictureUrl = imageUrl;
                  //       //     });
                  //       //   });
                  //       // }
                  //       //}
                  //     },
                  //     // child: const CircleAvatar(
                  //     //   child: Icon(Icons.camera_alt),
                  //     // ),
                  //   ),
                  // ],
                ),
                // List of Menu Items
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('H O M E'),
                  onTap: () {
                    Navigator.of(context).pushNamed("/home");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('C A L E N D A R'),
                  onTap: () =>
                      Navigator.of(context).pushNamed('/view-calendar'),
                ),
                ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('G R O U P S'),
                  onTap: () => Navigator.of(context).pushNamed('/groups'),
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('H E L P'),
                  onTap: () => Navigator.of(context).pushNamed('/help'),
                ),
              ],
            ),
          ),
          const Divider(),
          // Logout button
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('L O G O U T'),
            onTap: () {
              SharedPreferences.getInstance().then((prefs) {
                prefs.setBool('loggedin', false);
                Navigator.of(context).pushNamed('/signout');
              });
            },
          ),
        ],
      ),
    );
  }

  // Image Uploader
  Future<String?> uploadProfilePicture(XFile imageFile) async {
    // Upload the image file to your server and get the image URL
    // Replace this with your own code to upload the image file
    return '';
  }
}
