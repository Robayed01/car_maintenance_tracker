import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpcomingScreen extends StatefulWidget {
  const UpcomingScreen({super.key});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
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
      // Sort by upcoming date (earliest first)
      _services.sort(
        (a, b) => (a['upcomingDate'] ?? a['date'] ?? '').compareTo(
          b['upcomingDate'] ?? b['date'] ?? '',
        ),
      );
    });
  }

  // Calculate days difference from today
  String _daysLabel(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = dateOnly.difference(todayOnly).inDays;
    if (diff < 0) return '${diff.abs()} days overdue';
    if (diff == 0) return 'Due today';
    return '$diff days left';
  }

  // Get icon for status
  IconData _statusIcon(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return Icons.schedule;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = dateOnly.difference(todayOnly).inDays;
    if (diff < 0) return Icons.warning;
    if (diff <= 7) return Icons.access_time;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _services.isEmpty
          ? const Center(
              child: Text(
                'No upcoming services.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _services.length,
              itemBuilder: (ctx, i) {
                final s = _services[i];
                final dateStr = s['upcomingDate'] ?? s['date'] ?? '';
                return Card(
                  child: ListTile(
                    leading: Icon(_statusIcon(dateStr), size: 28),
                    title: Text(
                      s['type'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${s['car']}  •  Upcoming: $dateStr'),
                    trailing: Text(
                      _daysLabel(dateStr),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
