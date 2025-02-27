import 'package:flutter/material.dart';
import 'package:skynet/screens/home/scheduler_creation_screen.dart';
import 'package:skynet/utils/firebase/db_service.dart';
import 'package:skynet/utils/shared_preferences/shared_preferences_service.dart';

class SchedulerFragment extends StatefulWidget {
  const SchedulerFragment({super.key});

  @override
  State<SchedulerFragment> createState() => _SchedulerFragmentState();
}

class _SchedulerFragmentState extends State<SchedulerFragment> {
  final DbService _dbService = DbService();
  List<Map<String, dynamic>> _schedulers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedulers();
  }

  Future<void> _fetchSchedulers() async {
    final prefsService = SharedPreferencesService();
    String? userId = await prefsService.getUserId();

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    List<Map<String, dynamic>> schedulers = await _dbService.getUserSchedulers(userId);

    setState(() {
      _schedulers = schedulers;
      _isLoading = false;
    });
  }

  Future<void> _deleteScheduler(String schedulerId) async {
    await _dbService.deleteScheduler(schedulerId);
    _fetchSchedulers();
  }

  Future<void> _toggleSchedulerStatus(String schedulerId, bool newStatus) async {
    await _dbService.updateSchedulerStatus(schedulerId, newStatus);
    _fetchSchedulers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedulers", style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 6, 26, 94),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SchedulerCreationScreen()),
              ).then((_) => _fetchSchedulers()); // Refresh after returning
            },
          ),
        ],
        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedulers.isEmpty
          ? const Center(child: Text("No schedulers found."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _schedulers.length,
        itemBuilder: (context, index) {
          final scheduler = _schedulers[index];
          return _buildSchedulerCard(scheduler);
        },
      ),
    );
  }

  Widget _buildSchedulerCard(Map<String, dynamic> scheduler) {
    bool isSchedulerActive = scheduler["status"] ?? false;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left side: Scheduler Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheduler['name'] ?? "No Name",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Turns on at: ${scheduler['turnOnTime']}",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  Text(
                    "Turns off at: ${scheduler['turnOffTime']}",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            // Right side: Switch & Menu Button
            Row(
              children: [
                // Switch to toggle scheduler status
                Switch(
                  value: isSchedulerActive,
                  onChanged: (newValue) {
                    _toggleSchedulerStatus(scheduler['id'], newValue);
                  },
                  activeColor: Colors.blueAccent,
                ),
                // Three dots menu button
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      // TODO: Implement edit functionality
                    } else if (value == 'delete') {
                      _deleteScheduler(scheduler['id']);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        // leading: Icon(Icons.edit, color: Colors.blue),
                        title: Text("Edit"),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        // leading: Icon(Icons.delete, color: Colors.red),
                        title: Text("Delete"),
                      ),
                    ),
                  ],
                  child: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
