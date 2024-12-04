import 'package:flutter/material.dart'; 

class MyStart extends StatefulWidget {
  const MyStart({super.key});

  @override
  State<MyStart> createState() => _MyStartState(); 
}

class _MyStartState extends State<MyStart> { 
  @override
    void initState() {
      super.initState();
      Future.delayed(const Duration(seconds: 5),() { 
        Navigator.pushNamed(context, '/start2');
      });
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF0486C7),
        child: Center(
          child: Image.asset('assets/1.png',
          width: 350,
          height: 350,
          )
        )
      )
    );
  }
}
