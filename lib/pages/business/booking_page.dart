import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart'; // Importez table_calendar
import 'models/service.dart'; // Importez la classe Service

class BookingPage extends StatefulWidget {
  final Service service;
  final String businessId;

  const BookingPage({
    super.key,
    required this.service,
    required this.businessId,
    required String businessName,
  });

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime _selectedDay = DateTime.now();
  final List<Map<String, dynamic>> _selectedSlots = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _availabilityList = [];
  List<DateTime> _availableDates = []; // Liste des dates avec disponibilités

  @override
  void initState() {
    super.initState();
    _fetchAvailability(); // Charger toutes les disponibilités au démarrage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver un créneau'),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélecteur de date avec TableCalendar
            Card(
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365 * 5)),
                focusedDay: _selectedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _selectedSlots.clear();
                    _fetchAvailabilityForSelectedDay();
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    // Afficher un cercle autour de la date si elle a des disponibilités
                    if (_availableDates.any(
                        (availableDate) => isSameDay(availableDate, date))) {
                      return Positioned(
                        right: 7,
                        bottom: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.green, // Couleur du cercle
                              width: 3, // Épaisseur du cercle
                            ),
                          ),
                          padding: const EdgeInsets.all(18), // Taille du cercle
                          // child: Text(
                          //   date.day
                          //       .toString(), // Afficher le numéro de la date
                          // style: const TextStyle(
                          // color: Colors.green, // Couleur du texte
                          // fontWeight: FontWeight.bold,
                          // ),
                        ),
                        // ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Afficher les disponibilités pour la date sélectionnée
            const Text(
              'Plages horaires disponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildAvailabilityList(),
            const SizedBox(height: 20),

            // Afficher les plages horaires sélectionnées
            if (_selectedSlots.isNotEmpty) ...[
              const Text(
                'Plages horaires sélectionnées',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildSelectedSlotsList(),
              const SizedBox(height: 20),
            ],

            // Champ de message facultatif
            const Text(
              'Message (facultatif)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Entrez un message (facultatif)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed:
              _selectedSlots.isEmpty || _isLoading ? null : _bookAppointments,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9C27B0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Confirmer les réservations',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
        ),
      ),
    );
  }

  // Méthode pour récupérer toutes les disponibilités
  Future<void> _fetchAvailability() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('availability')
          .where('businessId', isEqualTo: widget.businessId)
          .get();

      setState(() {
        _availabilityList = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'date': (data['date'] as Timestamp).toDate(),
            'startTime': data['startTime'],
            'endTime': data['endTime'],
          };
        }).toList();

        // Mettre à jour la liste des dates avec disponibilités
        _availableDates = snapshot.docs.map((doc) {
          final data = doc.data();
          return (data['date'] as Timestamp).toDate();
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des disponibilités : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Méthode pour récupérer les disponibilités pour la date sélectionnée
  Future<void> _fetchAvailabilityForSelectedDay() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('availability')
          .where('businessId', isEqualTo: widget.businessId)
          .where('date',
              isEqualTo: DateTime(
                  _selectedDay.year, _selectedDay.month, _selectedDay.day))
          .get();

      setState(() {
        _availabilityList = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'date': (data['date'] as Timestamp).toDate(),
            'startTime': data['startTime'],
            'endTime': data['endTime'],
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des disponibilités : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Méthode pour afficher la liste des disponibilités
  Widget _buildAvailabilityList() {
    if (_availabilityList.isEmpty) {
      return const Center(
        child: Text('Aucune disponibilité pour cette date.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _availabilityList.length,
      itemBuilder: (context, index) {
        final availability = _availabilityList[index];
        final date = availability['date'] as DateTime;
        final startTime = availability['startTime'] as String;
        final endTime = availability['endTime'] as String;

        return Card(
          child: ListTile(
            title: Text(
              DateFormat('dd/MM/yyyy').format(date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'De $startTime à $endTime',
            ),
            trailing: Checkbox(
              value: _selectedSlots.any((slot) =>
                  slot['startTime'] == startTime && slot['endTime'] == endTime),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedSlots.add({
                      'date': date,
                      'startTime': startTime,
                      'endTime': endTime,
                    });
                  } else {
                    _selectedSlots.removeWhere((slot) =>
                        slot['startTime'] == startTime &&
                        slot['endTime'] == endTime);
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  // Méthode pour afficher les plages horaires sélectionnées
  Widget _buildSelectedSlotsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _selectedSlots.length,
      itemBuilder: (context, index) {
        final slot = _selectedSlots[index];
        final date = slot['date'] as DateTime;
        final startTime = slot['startTime'] as String;
        final endTime = slot['endTime'] as String;

        return ListTile(
          title: Text(
            DateFormat('dd/MM/yyyy').format(date),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'De $startTime à $endTime',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _selectedSlots.removeAt(index);
              });
            },
          ),
        );
      },
    );
  }

  // Méthode pour réserver les créneaux sélectionnés
  Future<void> _bookAppointments() async {
    setState(() {
      _isLoading = true;
    });

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur non connecté'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      for (final slot in _selectedSlots) {
        await FirebaseFirestore.instance.collection('appointments').add({
          'businessId': widget.businessId,
          'userId': currentUserId,
          'serviceId': widget.service.id, // Utilisation de l'ID du service
          'serviceName': widget.service.name, // Utilisation du nom du service
          'date': slot['date'],
          'startTime': slot['startTime'],
          'endTime': slot['endTime'],
          'message': _messageController.text,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservations confirmées avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la réservation : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
