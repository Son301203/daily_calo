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
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: const [
          HomeScreenContent(),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dining_outlined),
            label: "Bữa ăn",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.healing_outlined),
            label: "Tập luyện",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Thông tin",
          ),
        ],
      ),
    );
  }
}

// New widget for Home tab content
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trang chủ")),
      body: Center(child: Text("Trang chủ", style: TextStyle(fontSize: 24))),
    );
  }
}
