import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  final String businessId;
  
  const ProfilePage({super.key, required this.businessId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Rendez-vous'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'À venir'),
              Tab(text: 'Confirmés'),
              Tab(text: 'Terminés'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AppointmentsList(status: 'pending'),
            AppointmentsList(status: 'confirmed'),
            AppointmentsList(status: 'completed'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showQuickAppointmentDialog(context),
          label: const Text('Nouveau RDV'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showQuickAppointmentDialog(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    String selectedTime = '09:00';
    final TextEditingController nameController = TextEditingController();
    final TextEditingController serviceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau Rendez-vous'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du client',
                  icon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: serviceController,
                decoration: const InputDecoration(
                  labelText: 'Service',
                  icon: Icon(Icons.business_center),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(selectedDate),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Heure'),
                subtitle: Text(selectedTime),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                      DateFormat('HH:mm').parse(selectedTime),
                    ),
                  );
                  if (picked != null) {
                    selectedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || serviceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez remplir tous les champs')),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance.collection('appointments').add({
                  'clientName': nameController.text,
                  'serviceName': serviceController.text,
                  'date': selectedDate,
                  'time': selectedTime,
                  'status': 'pending',
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rendez-vous créé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

class AppointmentsList extends StatelessWidget {
  final String status;

  const AppointmentsList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('status', isEqualTo: status)
          .orderBy('date', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final appointments = snapshot.data?.docs ?? [];

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Aucun rendez-vous ${_getStatusText(status)}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment =
                appointments[index].data() as Map<String, dynamic>;
            final date = (appointment['date'] as Timestamp).toDate();
            final formattedDate = DateFormat('dd/MM/yyyy').format(date);
            final time = appointment['time'] as String;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.calendar_today),
                ),
                title: Text(
                  appointment['serviceName'] ?? 'Service inconnu',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('$formattedDate à $time'),
                trailing: _buildStatusIcon(status),
              ),
            );
          },
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'à venir';
      case 'confirmed':
        return 'confirmés';
      case 'completed':
        return 'terminés';
      default:
        return '';
    }
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return const Icon(Icons.schedule, color: Colors.orange);
      case 'confirmed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'completed':
        return const Icon(Icons.done_all, color: Colors.blue);
      default:
        return const SizedBox.shrink();
    }
  }
}
