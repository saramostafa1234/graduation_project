// import 'package:flutter/material.dart';
//
// class CustomTextField extends StatelessWidget {
//   final String hintText;
//   final bool obscureText;
//   final Function(String) onChanged;
//   final Function()? onSuffixIconPressed;
//
//   const CustomTextField({
//     required this.hintText,
//     required this.obscureText,
//     required this.onChanged,
//     this.onSuffixIconPressed,
//      final TextInputType keyboardType;
//     super.key, //required Padding prefixIcon,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       obscureText: obscureText,
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         hintText: hintText,
//         hintTextDirection: TextDirection.rtl, // الكتابة من اليمين لليسار
//         fillColor: Color(0xFFE6E9EA), // اللون الأبيض داخل الحقل
//         contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15), // المسافة بين النص والحواف
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12), // زوايا دائرية
//           borderSide: BorderSide(
//             color: Colors.grey, // لون الحواف
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: Colors.grey, // لون الحواف عند التمكين
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: Color(0xFFE6E9EA),
//           ),
//         ),
//         prefixIcon: onSuffixIconPressed != null
//             ? IconButton(
//           icon: Icon(
//             obscureText ? Icons.visibility_off : Icons.visibility,
//             color: Colors.grey,
//           ),
//           onPressed: onSuffixIconPressed,
//         )
//             : null,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Function(String) onChanged;
  final Function()? onSuffixIconPressed;
  final TextInputType keyboardType; // إضافة متغير لوحة المفاتيح

  const CustomTextField({
    required this.hintText,
    required this.obscureText,
    required this.onChanged,
    this.onSuffixIconPressed,
    this.keyboardType = TextInputType.text, // قيمة افتراضية
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType, // تمرير قيمة keyboardType
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintTextDirection: TextDirection.rtl,
        // الكتابة من اليمين لليسار
        fillColor: const Color(0xFFE6E9EA),
        // اللون الأبيض داخل الحقل
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        // المسافة بين النص والحواف
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // زوايا دائرية
          borderSide: const BorderSide(
            color: Colors.grey, // لون الحواف
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.grey, // لون الحواف عند التمكين
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE6E9EA),
          ),
        ),
        prefixIcon: onSuffixIconPressed != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onSuffixIconPressed,
              )
            : null,
      ),
    );
  }
}
