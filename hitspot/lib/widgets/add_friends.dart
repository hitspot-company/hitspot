import 'package:flutter/material.dart';

class HSChooseUsers extends StatelessWidget {
  const HSChooseUsers({super.key, this.maxUsers = 5});

  final int maxUsers;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({super.key});

  @override
  _AddFriendsPageState createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _selectedFriends = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friends'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFriendsInput(),
            const SizedBox(height: 20),
            _buildFriendsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsInput() {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        hintText: 'Type friend\'s name',
        border: OutlineInputBorder(),
      ),
      onSubmitted: (text) {
        setState(() {
          _selectedFriends.add(text);
          _controller.clear();
        });
      },
    );
  }

  Widget _buildSelectedFriends() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        spacing: 4.0,
        runSpacing: 4.0,
        children:
            _selectedFriends.map((friend) => _buildFriendChip(friend)).toList(),
      ),
    );
  }

  Widget _buildFriendChip(String friend) {
    return Chip(
      avatar: CircleAvatar(
        child: Text(
            friend[0]), // Just an example. Use the actual friend's avatar here.
      ),
      label: Text(friend),
      onDeleted: () {
        setState(() {
          _selectedFriends.remove(friend);
        });
      },
    );
  }

  Widget _buildFriendsList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _selectedFriends.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Text(_selectedFriends[index]
                  [0]), // Use actual friend's avatar here.
            ),
            title: Text(_selectedFriends[index]),
          );
        },
      ),
    );
  }
}
