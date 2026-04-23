import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/profile_drawer.dart';

class VolunteerBoardScreen extends StatelessWidget {
  const VolunteerBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ProfileDrawer(),
      appBar: AppBar(
        title: Text("Volunteer Board"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('surveys')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error fetching data."));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volunteer_activism, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      "No urgent needs reported yet.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            final docs = snapshot.data!.docs;

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                return TaskCard(
                  taskId: docs[index].id,
                  data: docs[index].data() as Map<String, dynamic>,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class TaskCard extends StatefulWidget {
  final String taskId;
  final Map<String, dynamic> data;

  const TaskCard({super.key, required this.taskId, required this.data});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  void _acceptTask() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('surveys').doc(widget.taskId).update({
      'status': 'in_progress',
      'assigneeId': user.uid,
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Task accepted!"), backgroundColor: Colors.green),
      );
    }
  }

  void _updateProgress(double value) async {
    int progress = value.toInt();
    String status = progress == 100 ? 'completed' : 'in_progress';
    
    await FirebaseFirestore.instance.collection('surveys').doc(widget.taskId).update({
      'progress': progress,
      'status': status,
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String location = widget.data['location'] ?? 'Unknown Location';
    final String urgency = widget.data['urgency'] ?? 'Normal';
    final String need = widget.data['need'] ?? 'No description provided';
    final String status = widget.data['status'] ?? 'open';
    final int progress = (widget.data['progress'] ?? 0) is int
        ? widget.data['progress'] ?? 0
        : (widget.data['progress'] as num?)?.toInt() ?? 0;
    final String? assigneeId = widget.data['assigneeId'];

    // Don't show tasks accepted by others (unless completed, maybe hide entirely)
    if (status != 'open' && assigneeId != user?.uid) {
      return SizedBox.shrink(); // Hide
    }

    Color urgencyColor = Colors.green;
    if (urgency.toString().toLowerCase() == 'high') urgencyColor = Colors.red;
    if (urgency.toString().toLowerCase() == 'medium') urgencyColor = Colors.orange;

    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.deepPurple[800]),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: urgencyColor, width: 1.5),
                  ),
                  child: Text(
                    urgency.toString().toUpperCase(),
                    style: TextStyle(color: urgencyColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                )
              ],
            ),
            SizedBox(height: 12),
            Text(
              "Task Description",
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[700], fontSize: 14),
            ),
            SizedBox(height: 6),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                need,
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
            ),
            SizedBox(height: 20),
            
            if (status == 'open')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _acceptTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(Icons.handshake),
                  label: Text("Volunteer for this Task", style: TextStyle(fontSize: 16)),
                ),
              )
            else if (status == 'in_progress' && assigneeId == user?.uid)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Update Progress: $progress%", style: TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: progress.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 10,
                    activeColor: Colors.deepPurple,
                    onChanged: (val) {
                      _updateProgress(val);
                    },
                  ),
                ],
              )
            else if (status == 'completed' && assigneeId == user?.uid)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text("Task Completed", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
