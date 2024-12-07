import 'package:flutter/material.dart';

Widget reusableDropdown({
  required String labelText,
  String? dropdownValue,
  required List<String> dropdownOptions,
  required ValueChanged<String?> onChanged,
  required BuildContext context,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: screenWidth * 0.04),
        child: Text(
          labelText,
          style: TextStyle(
            fontSize: screenHeight * 0.02,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 5),
      Container(
        width: screenWidth * 0.6,
        height: screenHeight * 0.05,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(screenHeight * 0.02),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: dropdownValue,
            isExpanded: true,
            icon: Icon(
              Icons.arrow_drop_down, 
              color: Colors.black,
              size: screenHeight * 0.025,
            ),
            style: TextStyle(
              color: Colors.black,
              fontSize: screenHeight * 0.02,
              fontFamily: 'Poppins',
            ),
            items: dropdownOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
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
  required BuildContext context,
  required String labelText,
  required DateTime? selectedDate,
  required Function(DateTime?) onDateChanged,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: screenWidth * 0.04),
        child: Text(
          labelText,
          style: TextStyle(
            fontSize: screenHeight * 0.02,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 5),
      Container(
        width: screenWidth * 0.6,
        height: screenHeight * 0.05,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(screenHeight * 0.02),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                onDateChanged(picked);
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                        : "Select Date",
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: screenHeight * 0.025,
                    color: Colors.black,
                  ),
                ],
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
