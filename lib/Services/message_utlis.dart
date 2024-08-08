// // lib/utils/message_utils.dart
// import 'package:flutter/material.dart';

// void showMessage({
//   required BuildContext context,
//   required String message,
// }) {
//   final snackBar = SnackBar(
//     content: Container(
//       padding: EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.blue.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(8.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.5),
//             blurRadius: 6.0,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Text(
//         message,
//         style: TextStyle(color: Colors.white, fontSize: 16.0),
//       ),
//     ),
//     behavior: SnackBarBehavior.floating,
//     backgroundColor: Colors.transparent,
//     duration: Duration(seconds: 2),
//     margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.85), // Adjust this margin to position the Snackbar
//   );

//   ScaffoldMessenger.of(context).showSnackBar(snackBar);
// }
// message_utils.dart

import 'package:flutter/material.dart';

void showMessage({required BuildContext context, required String message}) {
  final snackBar = SnackBar(
    content: Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 6.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.white, fontSize: 16.0),
      ),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    duration: Duration(seconds: 2),
    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.85),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
