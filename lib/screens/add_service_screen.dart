import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  List<Map<String, String>> _cars = [];
  List<Map<String, String>> _services = [];
  String? _selectedCar;
  String _selectedType = 'Oil Change';
  final _costCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime _upcomingDate = DateTime.now().add(const Duration(days: 30));

  // Service types
  final List<String> _serviceTypes = [
    'Oil Change',
    'Tire Rotation',
    'Brake Inspection',
    'Battery Check',
    'Air Filter',
    'Coolant Flush',
    'General Checkup',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    // Load cars
    final carsData = prefs.getString('cars') ?? '[]';
    final List carsList = jsonDecode(carsData);
    // Load services
    final servData = prefs.getString('services') ?? '[]';
    final List servList = jsonDecode(servData);
    setState(() {
      _cars = carsList.map((e) => Map<String, String>.from(e)).toList();
      _services = servList.map((e) => Map<String, String>.from(e)).toList();
      if (_cars.isNotEmpty) {
        _selectedCar = '${_cars[0]['make']} ${_cars[0]['model']}';
      }
    });
  }

  Future<void> _saveService() async {
    if (_selectedCar == null) {
      _showMsg('Please add a car first from the Cars tab');
      return;
    }
    if (_costCtrl.text.isEmpty) {
      _showMsg('Please enter the cost');
      return;
    }
    final service = {
      'car': _selectedCar!,
      'type': _selectedType,
      'date': _selectedDate.toIso8601String().split('T')[0],
      'cost': _costCtrl.text.trim(),
      'upcomingDate': _upcomingDate.toIso8601String().split('T')[0],
    };
    _services.add(service);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('services', jsonEncode(_services));
    _costCtrl.clear();
    _showMsg('Service added!');
    setState(() {});
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickUpcomingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _upcomingDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _upcomingDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    // Build car name list for dropdown
    final carNames = _cars.map((c) => '${c['make']} ${c['model']}').toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Log a New Service',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Car dropdown
            DropdownButtonFormField<String>(
              initialValue: carNames.contains(_selectedCar)
                  ? _selectedCar
                  : null,
              decoration: InputDecoration(
                labelText: 'Select Car',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: carNames
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCar = val),
            ),
            const SizedBox(height: 16),

            // Service type dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: 'Service Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _serviceTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
            const SizedBox(height: 16),

            // Date picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: Colors.teal),
              title: Text(
                'Date: ${_selectedDate.toIso8601String().split('T')[0]}',
              ),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('Change'),
              ),
            ),
            const SizedBox(height: 8),

            // Upcoming service date picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule, color: Colors.deepOrange),
              title: Text(
                'Upcoming: ${_upcomingDate.toIso8601String().split('T')[0]}',
              ),
              trailing: TextButton(
                onPressed: _pickUpcomingDate,
                child: const Text('Change'),
              ),
            ),
            const SizedBox(height: 8),

            // Cost field
            TextField(
              controller: _costCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cost (\$)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveService,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Save Service',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
