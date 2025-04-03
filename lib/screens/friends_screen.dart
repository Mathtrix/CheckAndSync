import 'package:flutter/material.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _friendUsernameController = TextEditingController();
  final List<String> _friends = ['shopper123', 'grocerybuddy'];

  void _addFriend() {
    final username = _friendUsernameController.text.trim();
    if (username.isNotEmpty && !_friends.contains(username)) {
      setState(() {
        _friends.add(username);
        _friendUsernameController.clear();
      });
    }
  }

  void _removeFriend(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: const Text('Are you sure you want to remove this friend?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _friends.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _shareListWithFriend(String friend) {
    // TODO: Implement sharing logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing list with $friend (feature pending)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _friendUsernameController,
              decoration: InputDecoration(
                labelText: 'Friend Username',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: _addFriend,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Friends:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _friends.isEmpty
                  ? const Center(child: Text('No friends added yet.'))
                  : ListView.builder(
                      itemCount: _friends.length,
                      itemBuilder: (context, index) {
                        final friend = _friends[index];
                        return Card(
                          child: ListTile(
                            title: Text(friend),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'share') _shareListWithFriend(friend);
                                if (value == 'remove') _removeFriend(index);
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'share', child: Text('Share List')),
                                const PopupMenuItem(value: 'remove', child: Text('Remove Friend')),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
