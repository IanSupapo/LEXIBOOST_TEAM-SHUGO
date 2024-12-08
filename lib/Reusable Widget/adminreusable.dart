import 'package:flutter/material.dart';

Widget adminReusableWidget({
  required TextEditingController textController,
  required String labelText,
  required BuildContext context,
  bool isPassword = false,
  bool isPasswordObscured = true,
  bool showEyeIcon = true,
  VoidCallback? onVisibilityToggle,
  Color labelColor = Colors.white,
  bool isDescription = false,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(
          left: (MediaQuery.of(context).size.width - screenWidth * 0.6) / 2,
          bottom: 8
        ),
        child: Text(
          labelText,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenHeight * 0.016,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Center(
        child: Container(
          width: screenWidth * 0.6,
          height: isDescription ? screenHeight * 0.2 : screenHeight * 0.05,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: textController,
            obscureText: isPassword ? isPasswordObscured : false,
            decoration: InputDecoration(
              prefixIcon: Icon(
                isPassword ? Icons.lock_outline : Icons.person_outline,
                color: Colors.grey[700],
                size: screenHeight * 0.025,
              ),
              suffixIcon: isPassword && showEyeIcon
                  ? IconButton(
                      icon: Icon(
                        isPasswordObscured ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey[700],
                        size: screenHeight * 0.025,
                      ),
                      onPressed: onVisibilityToggle,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02,
                vertical: screenHeight * 0.01,
              ),
            ),
            style: TextStyle(
              fontSize: screenHeight * 0.016,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    ],
  );
}

Widget adminButton({
  required VoidCallback onPressed,
  required String text,
  required BuildContext context,
  Color backgroundColor = const Color(0xFF4CAF50),
  Color textColor = Colors.white,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  
  return Container(
    width: screenWidth * 0.6,
    height: screenHeight * 0.05,
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenHeight * 0.018,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
