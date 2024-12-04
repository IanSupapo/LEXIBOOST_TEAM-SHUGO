import 'package:flutter/material.dart';

Widget reusableWidget({
  required TextEditingController textController,
  required String labelText,
  bool isPassword = false,
  bool isPasswordObscured = true,
  bool showEyeIcon = true,
  VoidCallback? onVisibilityToggle,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Text(
          labelText,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 5),
      Container(
        width: 328,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: textController,
          obscureText: isPassword ? isPasswordObscured : false,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: InputBorder.none,
            suffixIcon: isPassword && showEyeIcon
                ? IconButton(
                    icon: Icon(
                      isPasswordObscured
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: onVisibilityToggle,
                  )
                : null,
          ),
        ),
      ),
    ],
  );
}

Widget customButton({
  required VoidCallback onPressed,
  required String text,
  Color backgroundColor = const Color(0xFFDAFEFC),
}) {
  return SizedBox(
    width: 328,
    height: 55,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
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
}) {
  return customButton(onPressed: onPressed, text: "Sign Up");
}

Widget loginButton({
  required VoidCallback onPressed,
}) {
  return customButton(onPressed: onPressed, text: "Log In");
}

Widget continueButton({
  required VoidCallback onPressed,
}) {
  return customButton(onPressed: onPressed, text: "Continue");
}

Widget resetPasswordButton({
  required VoidCallback onPressed, required String text,
}) {
  return customButton(onPressed: onPressed, text: "Reset Password");
}

Widget GetPasswordButton({
  required VoidCallback onPressed, required String text,
}) {
  return customButton(onPressed: onPressed, text: "GetPassword");
}

Widget socialSignUpButton({
  required VoidCallback onPressed,
  required String imagePath,
  required String text,
}) {
  return SizedBox(
    width: 328,
    height: 55,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 20,
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
