import 'package:flutter/material.dart';

Widget reusableWidget({
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
  
  // Calculate responsive sizes
  final double labelSize = screenHeight * 0.02;  // 2% of screen height
  final double inputTextSize = screenHeight * 0.018;  // 1.8% of screen height
  final double verticalPadding = screenHeight * 0.01;  // 1% of screen height
  final double horizontalPadding = screenWidth * 0.04;  // 4% of screen width
  final double iconSize = screenHeight * 0.025;  // 2.5% of screen height

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Text(
          labelText,
          style: TextStyle(
            fontSize: labelSize,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: labelColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 5),
      Container(
        width: screenWidth * 0.6,
        height: isDescription ? screenHeight * 0.2 : screenHeight * 0.05,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(screenHeight * 0.02),
        ),
        child: TextField(
          controller: textController,
          obscureText: isPassword ? isPasswordObscured : false,
          keyboardType: isDescription ? TextInputType.multiline : _getKeyboardType(labelText),
          maxLines: isDescription ? null : 1,
          maxLength: isDescription ? 120 : null,
          expands: isDescription,
          textAlignVertical: isDescription ? TextAlignVertical.top : TextAlignVertical.center,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: horizontalPadding,
            ),
            border: InputBorder.none,
            counterText: '',
            hintText: isDescription ? 'Enter description (max 120 words)...' : null,
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey,
            ),
            suffixIcon: isPassword && showEyeIcon
                ? IconButton(
                    icon: Icon(
                      isPasswordObscured
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.black,
                      size: iconSize,
                    ),
                    onPressed: onVisibilityToggle,
                  )
                : null,
          ),
          onChanged: isDescription ? (text) {
            final words = text.split(' ');
            if (words.length > 120) {
              textController.text = words.take(120).join(' ');
              textController.selection = TextSelection.fromPosition(
                TextPosition(offset: textController.text.length),
              );
            }
          } : null,
          style: TextStyle(
            color: Colors.black,
            fontSize: inputTextSize,
            fontFamily: 'Poppins',
            letterSpacing: _getLetterSpacing(labelText, screenWidth),
          ),
        ),
      ),
    ],
  );
}

Widget customButton({
  required VoidCallback onPressed,
  required String text,
  required BuildContext context,
  Color backgroundColor = const Color(0xFFDAFEFC),
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  
  return SizedBox(
    width: screenWidth * 0.6,
    height: screenHeight * 0.05,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenHeight * 0.02),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenHeight * 0.02,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    ),
  );
}

Widget signUpButton({
  required VoidCallback onPressed,
  required BuildContext context,
}) {
  return customButton(
    onPressed: onPressed,
    text: "Sign Up",
    context: context,
  );
}

Widget loginButton({
  required VoidCallback onPressed,
  required BuildContext context,
}) {
  return customButton(
    onPressed: onPressed,
    text: "Log In",
    context: context,
  );
}

Widget continueButton({
  required VoidCallback onPressed,
  required BuildContext context,
}) {
  return customButton(
    onPressed: onPressed,
    text: "Continue",
    context: context,
  );
}

Widget resetPasswordButton({
  required VoidCallback onPressed,
  required String text,
  required BuildContext context,
}) {
  return customButton(
    onPressed: onPressed,
    text: "Reset Password",
    context: context,
  );
}

Widget GetPasswordButton({
  required VoidCallback onPressed,
  required String text,
  required BuildContext context,
}) {
  return customButton(
    onPressed: onPressed,
    text: "GetPassword",
    context: context,
  );
}

Widget socialSignUpButton({
  required VoidCallback onPressed,
  required String imagePath,
  required String text,
  required BuildContext context,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  
  return SizedBox(
    width: screenWidth * 0.6,
    height: screenHeight * 0.05,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenHeight * 0.02),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: screenHeight * 0.03,
            height: screenHeight * 0.03,
          ),
          SizedBox(width: screenWidth * 0.02),
          Text(
            text,
            style: TextStyle(
              fontSize: screenHeight * 0.015,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}

TextInputType _getKeyboardType(String labelText) {
  switch (labelText.toLowerCase()) {
    case 'email':
      return TextInputType.emailAddress;
    case 'full name':
      return TextInputType.name;
    case 'password':
    case 'confirm password':
      return TextInputType.visiblePassword;
    default:
      return TextInputType.text;
  }
}

bool _isSpecialField(String labelText) {
  final label = labelText.toLowerCase();
  return label == 'email' || 
         label == 'password' || 
         label == 'confirm password';
}

double? _getLetterSpacing(String labelText, double screenWidth) {
  final label = labelText.toLowerCase();
  if (label == 'email') {
    return screenWidth * 0.002;
  } else if (label == 'password' || label == 'confirm password') {
    return screenWidth * 0.001;
  }
  return null;
}
