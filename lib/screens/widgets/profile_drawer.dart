import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../dashboard_screen.dart';
import '../volunteer_board_screen.dart';
import '../home_screen.dart';
import '../edit_profile_screen.dart';
import '../login_screen.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: user == null
          ? Center(child: Text("Not logged in"))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                String occupation = 'Unknown';
                String experience = 'Unknown';
                String email = user.email ?? 'Unknown Email';

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  occupation = data['occupation'] ?? 'Unknown';
                  experience = data['experience'] ?? 'Unknown';
                }

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple, Colors.blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      accountName: Text(
                        occupation,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      accountEmail: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(email),
                          SizedBox(height: 4),
                          Text("Exp: $experience", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.dashboard, color: Colors.deepPurple),
                      title: Text('Dashboard'),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => DashboardScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.volunteer_activism, color: Colors.orange),
                      title: Text('Volunteer Board'),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const VolunteerBoardScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.document_scanner, color: Colors.blue),
                      title: Text('Scan Survey'),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.edit, color: Colors.teal),
                      title: Text('Edit Profile'),
                      onTap: () {
                        Navigator.pop(context); // close drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('Logout', style: TextStyle(color: Colors.red)),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
}

