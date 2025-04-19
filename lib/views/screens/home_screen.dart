import 'package:daily_calo/views/screens/exercise_screen.dart';
import 'package:daily_calo/views/screens/meal_screen.dart';
import 'package:daily_calo/views/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: TabBarView(
        controller: _tabController,
        children: [
          MealScreen(),
          ExerciseScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _tabController.animateTo(index);
          });
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.dining_outlined)),
          const BottomNavigationBarItem(icon: Icon(Icons.healing_outlined)),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline)),
        ],
      ),
    );
  }
}
