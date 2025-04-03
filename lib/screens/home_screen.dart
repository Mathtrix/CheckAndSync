import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import 'list_entries_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _lists = [];
  late Box _box;
  bool _hasPendingSync = false;
  Timer? _syncRetryTimer;

  @override
  void initState() {
    super.initState();
    _box = Hive.box('lists');
    _loadLists();
  }

void _loadLists() {
  final data = _box.get('user_lists');
  if (data != null) {
    setState(() {
      _lists = List<Map<String, dynamic>>.from(
        (data as List).map((list) {
          final map = Map<String, dynamic>.from(list);
          map['entries'] = List<Map<String, dynamic>>.from(
            (map['entries'] as List).map((entry) => Map<String, dynamic>.from(entry)),
          );
          return map;
        }),
      );
    });
  }
}

  void _saveLists() {
    _box.put('user_lists', _lists);
  }

  void _addList() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('New List'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'List name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _lists.add({
                    'id': DateTime.now().toIso8601String(),
                    'title': controller.text.trim(),
                    'entries': [],
                  });
                });
                _saveLists();
                _syncToServer();
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editListTitle(int index) {
    final controller = TextEditingController(text: _lists[index]['title']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit List Title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'New list name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _lists[index]['title'] = controller.text.trim();
              });
              _saveLists();
              _syncToServer();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteList(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: const Text('Are you sure you want to delete this list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _lists.removeAt(index);
              });
              _saveLists();
              _syncToServer();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openList(String listId) async {
    final index = _lists.indexWhere((l) => l['id'] == listId);
    if (index == -1) return;

    final list = _lists[index];

    final updatedEntries = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListEntriesScreen(
          listId: listId,
          title: list['title'],
          initialEntries: List<Map<String, dynamic>>.from(list['entries'] ?? []),
        ),
      ),
    );

    if (updatedEntries != null) {
      setState(() {
        _lists[index]['entries'] = updatedEntries;
      });
      _saveLists();
      _syncToServer();
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _syncToServer();
              await AuthService.logout(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _syncToServer() async {
  final success = await AuthService.syncLists(_lists);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(success ? '✅ Synced to server' : '❌ Sync failed'),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncToServer,
          ),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: _lists.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = _lists.removeAt(oldIndex);
            _lists.insert(newIndex, item);
          });
          _saveLists();
          _syncToServer();
        },
        itemBuilder: (context, index) {
          final list = _lists[index];
          return Card(
            key: ValueKey(list['id']),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(list['title']),
              onTap: () => _openList(list['id']),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _editListTitle(index);
                  if (value == 'delete') _deleteList(index);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addList,
        child: const Icon(Icons.add),
      ),
    );
  }
}
