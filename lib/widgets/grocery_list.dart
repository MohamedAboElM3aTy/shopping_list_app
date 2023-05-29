import 'package:flutter/material.dart';

import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _newGroceryItem = [];

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(
      () {
        _newGroceryItem.add(newItem);
      },
    );
  }

  void _removeItem(GroceryItem item) {
    setState(
      () {
        _newGroceryItem.remove(item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _newGroceryItem.isEmpty
          ? const Center(
              child: Text('No Items added Yet'),
            )
          : ListView.builder(
              itemCount: _newGroceryItem.length,
              itemBuilder: (ctx, index) => Dismissible(
                key: ValueKey(_newGroceryItem[index].id),
                onDismissed: (direction) {
                  _removeItem(
                    _newGroceryItem[index],
                  );
                },
                child: ListTile(
                  title: Text(_newGroceryItem[index].name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: _newGroceryItem[index].category.color,
                  ),
                  trailing: Text(
                    _newGroceryItem[index].quantity.toString(),
                  ),
                ),
              ),
            ),
    );
  }
}
