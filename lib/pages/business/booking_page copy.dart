// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'models/service.dart';

// class BookingPage extends StatefulWidget {
//   final Service service;
//   final String businessId;

//   const BookingPage({
//     super.key,
//     required this.service,
//     required this.businessId,
//     required String businessName,
//   });

//   @override
//   _BookingPageState createState() => _BookingPageState();
// }

// class _BookingPageState extends State<BookingPage> {
//   DateTime _selectedDay = DateTime.now();
//   String? _selectedTime;
//   final TextEditingController _messageController = TextEditingController();
//   bool _isLoading = false;

//   final List<String> _availableTimes = [
//     '09:00',
//     '10:00',
//     '11:00',
//     '14:00',
//     '15:00',
//     '16:00'
//   ];

//   final FocusNode _focusNode = FocusNode();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Booking Now',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: const Color(0xFF9C27B0),
//       ),
//       resizeToAvoidBottomInset: true,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               child: CalendarDatePicker(
//                 initialDate: _selectedDay,
//                 firstDate: DateTime.now(),
//                 lastDate: DateTime.now().add(const Duration(days: 90)),
//                 onDateChanged: (date) {
//                   setState(() => _selectedDay = date);
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Horaires disponibles',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: _availableTimes.map((time) {
//                 return ChoiceChip(
//                   label: Text(time),
//                   selected: _selectedTime == time,
//                   onSelected: (selected) {
//                     setState(() {
//                       _selectedTime = selected ? time : null;
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _selectTime(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF9C27B0),
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(68),
//                 ),
//                 elevation: 5,
//                 minimumSize: const Size(120, 50),
//               ),
//               child: const Text(
//                 'Choisir une autre heure',
//                 style: TextStyle(
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Message (facultatif)',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _messageController,
//               focusNode: _focusNode,
//               maxLines: 3,
//               textInputAction: TextInputAction.done,
//               decoration: const InputDecoration(
//                 hintText: 'Entrez un message (facultatif)',
//                 border: OutlineInputBorder(),
//               ),
//               onSubmitted: (value) {
//                 print('Message saisi : $value');
//                 _focusNode.unfocus();
//               },
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ElevatedButton(
//           onPressed:
//               _selectedTime == null || _isLoading ? null : _bookAppointment,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF9C27B0),
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             minimumSize: const Size(double.infinity, 50),
//           ),
//           child: _isLoading
//               ? const CircularProgressIndicator(color: Colors.white)
//               : const Text(
//                   'Confirm your Booking',
//                   style: TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//         ),
//       ),
//     );
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.fromDateTime(_selectedDay),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDay = DateTime(
//           _selectedDay.year,
//           _selectedDay.month,
//           _selectedDay.day,
//           picked.hour,
//           picked.minute,
//         );
//         _selectedTime = picked.format(context);
//       });
//     }
//   }

//   Future<void> _bookAppointment() async {
//     setState(() {
//       _isLoading = true;
//     });

//     final currentUserId = FirebaseAuth.instance.currentUser?.uid;
//     print("ID utilisateur connecté : $currentUserId");

//     if (currentUserId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Utilisateur non connecté'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       setState(() {
//         _isLoading = false;
//       });
//       return;
//     }

//     try {
//       await FirebaseFirestore.instance.collection('appointments').add({
//         'serviceId': widget.service.id,
//         'serviceName': widget.service.name,
//         'businessId': widget.businessId,
//         'userId': currentUserId,
//         'date': _selectedDay,
//         'time': _selectedTime,
//         'message': _messageController.text,
//         'status': 'pending',
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Rendez-vous réservé avec succès'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erreur lors de la réservation: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
// }
