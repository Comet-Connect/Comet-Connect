// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final _searchController = TextEditingController();
  bool _isListView = true;
  int _selectedItemCount = 5;

  // late mongo.Db _db; // Database

  // @override
  // void initState() {
  //   //super.initState();
  //   //_db = mongo.Db('mongodb+srv://admin:bNGtOFxi3UTcv81W@cometconnect.cuwtjrg.mongodb.net/user_info');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Groups'),
        ),
        body: Padding(
          // Padding around all edges
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nav bar row for groups page
              Row(
                children: [
                  // List or Grid View toggle button
                  ToggleButtons(
                    isSelected: [_isListView, !_isListView],
                    onPressed: (int index) {
                      setState(() {
                        _isListView = index == 0 ? true : false;
                      });
                    },
                    children: const [
                      Icon(Icons.list),
                      Icon(Icons.grid_view),
                    ],
                  ),

                  // Search Bar
                  Expanded(
                    flex: 2,
                    child: Padding(
                      //padding: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Spacer(),

                  // Display Item Count
                  DropdownButton<int>(
                    value: _selectedItemCount,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedItemCount = value!;
                      });
                    },
                    items: [5, 10, 15, 20, 25]
                        .map((itemCount) => DropdownMenuItem<int>(
                              value: itemCount,
                              child: Text('$itemCount'),
                            ))
                        .toList(),
                  ),
                  const Text("  items per page")
                ],
              ), // End of Nav Bar Row
              Expanded(
                child: AnimationLimiter(
                  child: _isListView ? _buildListView() : _buildGridView(),
                ),
              ),
            ],
          ),
        ));
  }

  // Widget to Build List View
  Widget _buildListView() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 500),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.group),
                  title: Text('Group ${index + 1}'),
                  subtitle: Text('Description of Group ${index + 1}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget to Build Grid View
  Widget _buildGridView() {
    return GridView.builder(
      itemCount: 10,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // change this to view how many items in a row
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (BuildContext context, int index) {
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 500),
          columnCount: 2,
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group),
                    const SizedBox(height: 8),
                    Text(
                      'Group ${index + 1}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Description of Group ${index + 1}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
