import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, String>> _services = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('services') ?? '[]';
    final List list = jsonDecode(data);
    setState(() {
      _services = list.map((e) => Map<String, String>.from(e)).toList();
      // Sort by date (newest first)
      _services.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
    });
  }

  // Calculate total cost
  double get _totalCost {
    double total = 0;
    for (var s in _services) {
      total += double.tryParse(s['cost'] ?? '0') ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _services.isEmpty
          ? const Center(
              child: Text(
                'No service history yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                // Total cost card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Maintenance Cost',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Service list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _services.length,
                    itemBuilder: (ctx, i) {
                      final s = _services[i];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.build, color: Colors.teal),
                          title: Text(
                            s['type'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${s['car']}  •  ${s['date']}'),
                          trailing: Text(
                            '\$${s['cost']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
