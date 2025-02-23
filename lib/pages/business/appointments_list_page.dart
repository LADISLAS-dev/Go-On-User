import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentsListPage extends StatelessWidget {
  const AppointmentsListPage({
    super.key,
    required this.businessId,
  });

  final String businessId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Appointments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Confirmed'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AppointmentsList(status: 'pending', businessId: businessId),
            AppointmentsList(status: 'confirmed', businessId: businessId),
            AppointmentsList(status: 'completed', businessId: businessId),
          ],
        ),
      ),
    );
  }
}

class AppointmentsList extends StatefulWidget {
  const AppointmentsList({
    super.key,
    required this.status,
    required this.businessId,
  });

  final String businessId;
  final String status;

  @override
  _AppointmentsListState createState() => _AppointmentsListState();
}

class _AppointmentsListState extends State<AppointmentsList> {
  final Map<String, bool> _expandedStates = {};

  // Function to launch email
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      if (await canLaunch(emailUri.toString())) {
        await launch(emailUri.toString());
      } else {
        throw 'Unable to open email.';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Function to launch phone call
  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    try {
      if (await canLaunch(phoneUri.toString())) {
        await launch(phoneUri.toString());
      } else {
        throw 'Unable to open phone number.';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No appointments to display.'),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Text('Error: $error'),
    );
  }

  void _toggleText(String appointmentId) {
    setState(() {
      _expandedStates[appointmentId] =
          !(_expandedStates[appointmentId] ?? false);
    });
  }

  Widget _buildStatusActions(BuildContext context, String appointmentId) {
    if (appointmentId.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (widget.status) {
      case 'pending':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () =>
                  _updateStatus(context, appointmentId, 'confirmed'),
              tooltip: 'Confirm',
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () => _showCancelDialog(context, appointmentId),
              tooltip: 'Cancel',
            ),
          ],
        );
      case 'confirmed':
        return IconButton(
          icon: const Icon(Icons.done_all, color: Colors.blue),
          onPressed: () => _updateStatus(context, appointmentId, 'completed'),
          tooltip: 'Mark as completed',
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    String appointmentId,
    String newStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': newStatus});

      // Send a notification
      await _sendNotification(appointmentId, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'confirmed'
                  ? 'Appointment confirmed'
                  : 'Appointment completed',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendNotification(String appointmentId, String newStatus) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      final fcmToken = userDoc.data()?['fcmToken'];

      if (fcmToken == null) return;

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=YOUR_FCM_SERVER_KEY',
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'Your appointment has been $newStatus',
            'title': 'Appointment status updated',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'appointmentId': appointmentId,
          },
          'to': fcmToken,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error sending notification');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context, String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content:
              const Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                _updateStatus(context, appointmentId, 'cancelled');
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentTile(Map<String, dynamic> appointment,
      String appointmentId, Map<String, dynamic> userData) {
    final date = (appointment['date'] as Timestamp?)?.toDate();
    if (date == null) {
      return const ListTile(
        title: Text('Invalid Date'),
        subtitle: Text('The appointment does not have a valid date.'),
      );
    }

    // Retrieve start time and end time
    final startTime = appointment['startTime'] as String? ?? 'Unknown time';
    final endTime = appointment['endTime'] as String? ?? 'Unknown time';

    final message = appointment['message'] ?? 'No message';
    final userName = userData['name'] ?? 'Unknown name';
    final userEmail = userData['email'] ?? 'Unknown email';
    final userContact = userData['contact'] ?? 'Unknown contact';
    final userProfileImage = userData['profileImage'] ?? '';

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: userProfileImage.isNotEmpty
            ? NetworkImage(userProfileImage)
            : const AssetImage('assets/default_profile.png') as ImageProvider,
        onBackgroundImageError: (exception, stackTrace) {
          print("Error loading image: $exception");
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: () => _launchEmail(userEmail),
            child: Text(
              userEmail,
              style: const TextStyle(color: Colors.blue),
            ),
          ),
          InkWell(
            onTap: () => _launchPhone(userContact),
            child: Text(
              userContact,
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('dd/MM/yyyy').format(date),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            'From $startTime to $endTime', // Display start time and end time
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            _expandedStates[appointmentId] ?? false
                ? message
                : (message.length > 100
                    ? '${message.substring(0, 100)}...'
                    : message),
            style: const TextStyle(fontSize: 16),
            maxLines: _expandedStates[appointmentId] ?? false ? null : 2,
            overflow: _expandedStates[appointmentId] ?? false
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
          ),
          if (message.length > 100)
            TextButton(
              onPressed: () => _toggleText(appointmentId),
              child: Text(
                (_expandedStates[appointmentId] ?? false)
                    ? 'Read less'
                    : 'Read more',
                style: const TextStyle(color: Color(0xFF9C27B0)),
              ),
            ),
        ],
      ),
      trailing: _buildStatusActions(context, appointmentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const Center(child: Text('User not logged in.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('businessId', isEqualTo: widget.businessId)
          .where('status', isEqualTo: widget.status)
          .where('userId', isEqualTo: currentUserId)
          .orderBy('date', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final appointments = snapshot.data?.docs ?? [];
        if (appointments.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment =
                appointments[index].data() as Map<String, dynamic>;
            final appointmentId = appointments[index].id;
            final userId = appointment['userId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return _buildErrorState(userSnapshot.error.toString());
                }

                if (!userSnapshot.hasData ||
                    userSnapshot.data?.data() == null) {
                  return const Center(child: Text('User not found.'));
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;

                return Dismissible(
                  key: ValueKey(appointmentId),
                  onDismissed: (direction) async {
                    await FirebaseFirestore.instance
                        .collection('appointments')
                        .doc(appointmentId)
                        .delete();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Appointment deleted')),
                      );
                    }
                  },
                  background: Container(color: Colors.red),
                  child: Card(
                    child: _buildAppointmentTile(
                        appointment, appointmentId, userData),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
