import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';

import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _newGroceryItem = [];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https('shopping-list-learning-default-rtdb.firebaseio.com',
        'Shopping-List.json');

    try {
      final response = await http.get(url);

      if (response.body == 'null') {
        setState(
          () {
            _isLoading = false;
          },
        );
        return;
      }
      final Map<String, dynamic> listData = json.decode(response.body);

      final List<GroceryItem> loadedItems = [];

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(
        () {
          _newGroceryItem = loadedItems;
          _isLoading = false;
        },
      );
    } catch (e) {
      const Center(
        child: Text('SomeThing bad ...!ß'),
      );
      return null;
    }
  }

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

  void _removeItem(GroceryItem item) async {
    final index = _newGroceryItem
        .indexOf(item); // ! if there is an error with delete method
    setState(
      () {
        _newGroceryItem.remove(item);
      },
    );
    final url = Uri.https('shopping-list-learning-default-rtdb.firebaseio.com',
        'Shopping-List/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      // ! Undo the delete method
      setState(
        () {
          _newGroceryItem.insert(index, item);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet.'));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_newGroceryItem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _newGroceryItem.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_newGroceryItem[index]);
          },
          key: ValueKey(_newGroceryItem[index].id),
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
      );
    }
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
      body: content,
    );
  }
}
