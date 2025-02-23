// import 'package:appointy/login/screen/chat/conversation_list.dart';
// import 'package:appointy/login/screen/chat/conversations_page.dart';
// import 'package:appointy/pages/screens/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:appointy/pages/sous_pages/producr_items.dart';

// /// A widget that displays a horizontal list of selectable categories.
// /// Each category can be selected, showing an indicator bar below the selected item.
// class CategorySelection extends StatefulWidget {
//   final Function(String) onCategorySelected;
//   final List<String> categories;
//   final String businessId;

//   const CategorySelection({
//     super.key,
//     required this.onCategorySelected,
//     required this.categories,
//     required this.businessId,
//   });

//   @override
//   State<CategorySelection> createState() => _CategorySelectionState();
// }

// class _CategorySelectionState extends State<CategorySelection> {
//   late int selectedIndex;

//   @override
//   void initState() {
//     super.initState();
//     selectedIndex = 0;
//     if (widget.categories.isNotEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         widget.onCategorySelected(widget.categories[selectedIndex]);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.categories.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     final Size size = MediaQuery.of(context).size;
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: SizedBox(
//             height: 40,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: widget.categories.length,
//               physics: const BouncingScrollPhysics(),
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemBuilder: (context, index) {
//                 final bool isSelected = selectedIndex == index;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8.0),
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedIndex = index;
//                       });
//                       widget.onCategorySelected(widget.categories[index]);
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: isSelected ? primaryColor : Colors.grey[200],
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Center(
//                         child: Text(
//                           widget.categories[index],
//                           style: TextStyle(
//                             color: isSelected ? Colors.white : Colors.black87,
//                             fontWeight: isSelected
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//         if (widget.categories[selectedIndex] == 'Portfolio')
//           const SizedBox(
//             height: 500,
//             child: ProductItems(),
//           ),
//         if (widget.categories[selectedIndex] == 'About')
//           SizedBox(
//             height: size.height * 0.8,
//             child: ConversationList(
//               businessId: widget.businessId,
//               userId: '',
//               chatRoomId: '',
//               receiverId: '', // Add appropriate value
//               receiverName: '', // Add appropriate value
//               receiverImage: '', // Add appropriate value
//             ),
//           ),
//       ],
//     );
//   }
// }
