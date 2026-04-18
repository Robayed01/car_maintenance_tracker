import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  List<Map<String, String>> _cars = [];

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  // Load cars from SharedPreferences
  Future<void> _loadCars() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cars') ?? '[]';
    final List list = jsonDecode(data);
    setState(() {
      _cars = list.map((e) => Map<String, String>.from(e)).toList();
    });
  }

  // Save cars to SharedPreferences
  Future<void> _saveCars() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cars', jsonEncode(_cars));
  }

  // Show dialog to add or edit a car
  void _showCarDialog({int? index}) {
    final makeCtrl = TextEditingController(
      text: index != null ? _cars[index]['make'] : '',
    );
    final modelCtrl = TextEditingController(
      text: index != null ? _cars[index]['model'] : '',
    );
    final yearCtrl = TextEditingController(
      text: index != null ? _cars[index]['year'] : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(index != null ? 'Edit Car' : 'Add Car'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: makeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Make (e.g. Toyota)',
                ),
              ),
              TextField(
                controller: modelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Model (e.g. Corolla)',
                ),
              ),
              TextField(
                controller: yearCtrl,
                decoration: const InputDecoration(
                  labelText: 'Year (e.g. 2020)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              if (makeCtrl.text.isEmpty || modelCtrl.text.isEmpty) return;
              final car = {
                'make': makeCtrl.text.trim(),
                'model': modelCtrl.text.trim(),
                'year': yearCtrl.text.trim(),
              };
              setState(() {
                if (index != null) {
                  _cars[index] = car;
                } else {
                  _cars.add(car);
                }
              });
              _saveCars();
              Navigator.pop(ctx);
            },
            child: Text(index != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  // Delete a car
  void _deleteCar(int index) {
    setState(() => _cars.removeAt(index));
    _saveCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cars.isEmpty
          ? const Center(
              child: Text(
                'No cars added yet.\nTap + to add a car.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _cars.length,
              itemBuilder: (ctx, i) {
                final car = _cars[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.directions_car,
                      color: Colors.teal,
                      size: 32,
                    ),
                    title: Text(
                      '${car['make']} ${car['model']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Year: ${car['year']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.teal),
                          onPressed: () => _showCarDialog(index: i),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCar(i),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCarDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
