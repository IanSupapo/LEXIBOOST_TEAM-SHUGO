import 'package:flutter/material.dart';
import 'package:animated_button/animated_button.dart';
import 'package:shugo/phase2/mail.dart';
import 'package:shugo/phase2/phase%202%20reusable/reusable1.dart';
import 'package:shugo/phase2/settings.dart';
import 'profile.dart';
import 'rank.dart';
import 'contact.dart';
import 'achievement.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final PageController _pageController =
      PageController(initialPage: 3); // Default to "Home"
  int _currentIndex = 3;

  // Local notifications plugin instance
  late FlutterLocalNotificationsPlugin localNotifications;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    localNotifications = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    localNotifications.initialize(
      initializationSettings,
    );
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'achievement_channel', // Channel ID
      'Achievements', // Channel name
      channelDescription: 'Notifications for achievements unlocked',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await localNotifications.show(0, title, body, notificationDetails);
  }

  // Define achievements list
  final List<Map<String, dynamic>> achievements = [
    {
      'title': 'First Journey',
      'description': 'Play for the first time in solo adventure.',
      'completed': false,
    },
    {
      'title': 'First Battle',
      'description': 'Play in Versus mode for the first time.',
      'completed': false,
    },
    {
      'title': 'Winner',
      'description': 'Win a game in solo adventure 3 times!',
      'completed': false,
    },
    {
      'title': 'The Winner',
      'description': 'Win in a Versus mode 3 times!',
      'completed': false,
    },
    {
      'title': 'Unstoppable',
      'description': 'Win in a Versus mode 5 times!',
      'completed': false,
    },
  ];

  // Pages including the MyAchievement page with achievements
  List<Widget> get _pages => [
        const MyRank(),
        MyAchievement(),
        const MyContact(),
        const MyHomePage(),
        const MyMail(notifications: []),
        const MyProfile(),
        const MySettings(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Instantly switch to the selected page
    _pageController.jumpToPage(index);
  }

  // Unlock an achievement
  void unlockAchievement(int index) {
    if (achievements[index]['completed']) {
      // No need to show a notification for already unlocked achievements
      return;
    }

    setState(() {
      achievements[index]['completed'] = true;
    });

    // Trigger a local notification
    _showNotification(
      '🎉 Achievement Unlocked!',
      achievements[index]['title'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent manual swiping
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: customNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final myHome = context.findAncestorStateOfType<_MyHomeState>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define threshold for large screens
    final isLargeScreen = screenWidth > 600;

    // Calculate button dimensions based on screen size
    final buttonWidth = isLargeScreen ? 300.0 : screenWidth * 0.4; // 300 if large, otherwise 40% of screen width
    final buttonHeight = isLargeScreen ? 620.0 : screenHeight * 0.4; // 620 if large, otherwise 40% of screen height
    final fontSize = isLargeScreen ? 24.0 : screenWidth * 0.05; // 24 if large, otherwise change with screen width
    final imageSize = isLargeScreen ? 150.0 : buttonWidth * 0.5; // 150 if large, otherwise change proportionally

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Top Text: "Lexi Boost"
        const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            "Lexi Boost",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20), // Space between text and buttons
        // Row of Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left Button: SOLO ADVENTURE
            AnimatedButton(
              width: buttonWidth, // Width dynamically set based on screen size
              height: buttonHeight, // Height dynamically set based on screen size
              onPressed: () {
                print("SOLO ADVENTURE button pressed");

                // Navigate to the solo adventure page
                Navigator.pushNamed(context, '/solo');
              },
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      "SOLO ADVENTURE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Image(
                        image: const AssetImage('assets/solo-traveller.gif'),
                        width: imageSize, // Width changes proportionally
                        height: imageSize, // Height changes proportionally
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              shadowDegree: ShadowDegree.light,
              enabled: true,
            ),
            const SizedBox(width: 20), // Space between buttons
            // Right Button: VERSUS MODE
            AnimatedButton(
              width: buttonWidth, // Width dynamically set based on screen size
              height: buttonHeight, // Height dynamically set based on screen size
              onPressed: () {
                print("VERSUS MODE button pressed");
                myHome.unlockAchievement(1);
                Navigator.pushNamed(context, '/versus');
              },
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      "VERSUS MODE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Image(
                        image: const AssetImage('assets/players.gif'),
                        width: imageSize, // Width changes proportionally
                        height: imageSize, // Height changes proportionally
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              shadowDegree: ShadowDegree.light,
              enabled: true,
            ),
          ],
        ),
      ],
    );
  }
}
