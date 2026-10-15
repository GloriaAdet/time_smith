import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'navigation_screen.dart';
import 'task_completion_screen.dart';
import 'productivity_report_screen.dart';
import 'splash_screen.dart';
import 'task_analyzer.dart';
import 'adapt_screen.dart'; // Import the AdaptScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TaskAnalyzer.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // ignore: prefer_final_fields
  static List<Widget> _pages = <Widget>[
    HomeScreen(),
    NavigationScreen(),
    TaskCompletionScreen(),
    ProductivityReportScreen(),
    AdaptScreen(), // Add the AdaptScreen as a page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Navigation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb), // New icon for AdaptScreen
            label: 'Adapt',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
