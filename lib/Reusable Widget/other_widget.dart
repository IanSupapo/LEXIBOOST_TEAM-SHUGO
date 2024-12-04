import 'package:flutter/material.dart';

Widget reusableDropdown({
  required String labelText,
  String? dropdownValue,
  required List<String> dropdownOptions,
  required ValueChanged<String?> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: dropdownValue,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Poppins',
            ),
            items:
                dropdownOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(value),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
      const SizedBox(height: 20),
    ],
  );
}

Widget reusableDatePicker({
  required BuildContext context, // Add the BuildContext parameter
  required String labelText,
  DateTime? selectedDate,
  required ValueChanged<DateTime?> onDateChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
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
      GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context, // Correctly use context here
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          onDateChanged(pickedDate);
        },
        child: Container(
          width: 328,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                selectedDate != null
                    ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                    : "Select your birthday",
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
    ],
  );
}

Widget getOtpButton({
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: 328,
    height: 55,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDAFEFC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text(
        "Get OTP",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          color: Colors.black,
        ),
      ),
    ),
  );
}
