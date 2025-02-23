// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class AdminAvailabilityPage extends StatefulWidget {
//   final String businessId;

//   const AdminAvailabilityPage({super.key, required this.businessId});

//   @override
//   _AdminAvailabilityPageState createState() => _AdminAvailabilityPageState();
// }

// class _AdminAvailabilityPageState extends State<AdminAvailabilityPage> {
//   DateTime? _selectedDay; // Date sélectionnée
//   TimeOfDay? _startTime; // Heure de début
//   TimeOfDay? _endTime; // Heure de fin
//   final List<Map<String, dynamic>> _availabilityList =
//       []; // Liste des disponibilités

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Configurer les disponibilités'),
//         backgroundColor: const Color(0xFF9C27B0),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Section pour sélectionner une date
//             const Text(
//               'Sélectionner une date',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () => _selectDay(context),
//               child: Text(
//                 _selectedDay != null
//                     ? '${DateFormat('dd/MM/yyyy').format(_selectedDay!)}'
//                     : 'Choisir une date',
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Section pour sélectionner l'heure de début
//             const Text(
//               'Heure de début',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () => _selectTime(context, isStartTime: true),
//               child: Text(
//                 _startTime != null
//                     ? _startTime!.format(context)
//                     : 'Choisir une heure de début',
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Section pour sélectionner l'heure de fin
//             const Text(
//               'Heure de fin',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () => _selectTime(context, isStartTime: false),
//               child: Text(
//                 _endTime != null
//                     ? _endTime!.format(context)
//                     : 'Choisir une heure de fin',
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Bouton pour ajouter la disponibilité à la liste
//             ElevatedButton(
//               onPressed: _addAvailability,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF9C27B0),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text('Ajouter cette disponibilité'),
//             ),
//             const SizedBox(height: 20),

//             // Afficher la liste des disponibilités ajoutées
//             const Text(
//               'Disponibilités ajoutées',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _availabilityList.length,
//                 itemBuilder: (context, index) {
//                   final availability = _availabilityList[index];
//                   final date = availability['date'] as DateTime;
//                   final startTime = availability['startTime'] as String;
//                   final endTime = availability['endTime'] as String;

//                   return ListTile(
//                     title: Text(
//                       '${DateFormat('dd/MM/yyyy').format(date)}',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text(
//                       'De $startTime à $endTime',
//                     ),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => _removeAvailability(index),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // Bouton pour enregistrer les disponibilités dans Firestore
//             ElevatedButton(
//               onPressed: _saveAvailability,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF9C27B0),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text('Enregistrer les disponibilités'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Méthode pour sélectionner une date
//   Future<void> _selectDay(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now()
//           .add(const Duration(days: 365 * 5)), // 5 ans dans le futur
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDay = picked;
//       });
//     }
//   }

//   // Méthode pour sélectionner une heure (début ou fin)
//   Future<void> _selectTime(BuildContext context,
//       {required bool isStartTime}) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStartTime) {
//           _startTime = picked;
//         } else {
//           _endTime = picked;
//         }
//       });
//     }
//   }

//   // Méthode pour ajouter une disponibilité à la liste
//   void _addAvailability() {
//     if (_selectedDay == null || _startTime == null || _endTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//               'Veuillez sélectionner une date, une heure de début et une heure de fin.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _availabilityList.add({
//         'date': _selectedDay!,
//         'startTime': _startTime!.format(context),
//         'endTime': _endTime!.format(context),
//       });
//       // Réinitialiser les champs après l'ajout
//       _selectedDay = null;
//       _startTime = null;
//       _endTime = null;
//     });
//   }

//   // Méthode pour supprimer une disponibilité de la liste
//   void _removeAvailability(int index) {
//     setState(() {
//       _availabilityList.removeAt(index);
//     });
//   }

//   // Méthode pour enregistrer les disponibilités dans Firestore
//   Future<void> _saveAvailability() async {
//     if (_availabilityList.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Veuillez ajouter au moins une disponibilité.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     try {
//       for (final availability in _availabilityList) {
//         await FirebaseFirestore.instance.collection('availability').add({
//           'businessId': widget.businessId,
//           'date': availability['date'],
//           'startTime': availability['startTime'],
//           'endTime': availability['endTime'],
//           'createdAt': FieldValue.serverTimestamp(),
//         });
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Disponibilités enregistrées avec succès !'),
//           backgroundColor: Colors.green,
//         ),
//       );

//       // Réinitialiser la liste après l'enregistrement
//       setState(() {
//         _availabilityList.clear();
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Erreur lors de l\'enregistrement : $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }
