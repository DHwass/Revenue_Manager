import 'package:flutter/material.dart';
import 'package:money_app/SQL_helper.dart';

class Objectives extends StatefulWidget {
  final double userTotal;
  const Objectives({super.key, required this.userTotal});

  @override
  State<Objectives> createState() => _ObjectivesState();
}

class _ObjectivesState extends State<Objectives> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<Map<String, dynamic>> _items = [];

  // ******************************************* Necessary functions **************************************************

  void refreshItems() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _items = data;
    });
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _nameController.text, double.parse(_priceController.text));
    refreshItems();
    debugPrint('Total number of items :${_items.length}');
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _nameController.text, double.parse(_priceController.text));
    refreshItems();
  }

  Future<void> _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    refreshItems();
  }

  @override
  void initState() {
    super.initState();
    refreshItems();
    debugPrint(_items.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objectives'),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) =>

// ******************************************* Objective Card **************************************************
            Card(
          color: const Color.fromARGB(255, 238, 203, 114),
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(_items[index]['name']),
            subtitle: Text('${_items[index]['price'].toString()}' ' \$'),
            trailing: SizedBox(
              width: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 90,
                    child: LinearProgressIndicator(
                      value: (widget.userTotal / _items[index]['price']),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        _displayTextInputDialog(_items[index]['id']);
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () {
                        _deleteItem(_items[index]['id']);
                      },
                      icon: const Icon(Icons.delete))
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _displayTextInputDialog(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

// ******************************************* Item Form **************************************************

  Future<void> _displayTextInputDialog(int? id) async {
    if (id != null) {
      final existingItems = _items.firstWhere((element) => element['id'] == id);
      _nameController.text = existingItems['name'];
      _priceController.text = existingItems['price'].toString();
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('New Objective'),
            content: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: "Item name"),
                  autofocus: false,
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(hintText: "Item price"),
                  autofocus: false,
                )
              ],
            ),
            actions: [
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                onPressed: () async {
                  if (id == null) {
                    await _addItem();
                  }
                  if (id != null) {
                    await _updateItem(id);
                  }
                  Navigator.of(context).pop();

                  _nameController.text = '';
                  _priceController.text = '';
                },
                child: Text((id == null) ? 'Add' : 'Update'),
              )
            ],
          );
        });
  }
}

// submit(){
//   Navigator.of(context).pop()
// }
