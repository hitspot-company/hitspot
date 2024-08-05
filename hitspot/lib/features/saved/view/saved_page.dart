import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Your Boards'),
              Tab(text: 'Saved Boards'),
              Tab(text: 'Saved Spots'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildYourBoardsTab(),
            _buildSavedBoardsTab(),
            _buildSavedSpotsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildYourBoardsTab() {
    return ListView.builder(
      itemCount: 10, // Replace with actual data length
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Your Board ${index + 1}'),
          subtitle: Text('Description of board ${index + 1}'),
          leading: CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          onTap: () {
            // Handle board tap
          },
        );
      },
    );
  }

  Widget _buildSavedBoardsTab() {
    return ListView.builder(
      itemCount: 10, // Replace with actual data length
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Saved Board ${index + 1}'),
          subtitle: Text('Description of saved board ${index + 1}'),
          leading: CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          onTap: () {
            // Handle saved board tap
          },
        );
      },
    );
  }

  Widget _buildSavedSpotsTab() {
    return Center(
      child: Text('Saved Spots Tab Content'),
    );
  }
}
