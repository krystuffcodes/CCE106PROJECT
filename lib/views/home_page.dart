import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/item_service.dart';
import '../widgets/item_card.dart';
import 'item_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // ✅ track which tab is selected

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<ItemService>(context);
    final items = service.items;

    // Pages for nav bar
    final List<Widget> _pages = [
      // 🏠 Home page (grid items)
      GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final it = items[i];
          return ItemCard(
            item: it,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ItemDetailPage(item: it)),
            ),
          );
        },
      ),

      // 🔍 Search placeholder
      const Center(
        child: Text("Search Page", style: TextStyle(fontSize: 18)),
      ),

      // 🗂️ Category placeholder
      const Center(
        child: Text("Category Page", style: TextStyle(fontSize: 18)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFb71c1c),
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            Image.asset(
              'assets/logo.png',
              height: 40,
            ),
            const SizedBox(width: 10),
            const Text(
              'Lost & Found',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // navigate to profile if created
            },
          ),
        ],
      ),

      // ✅ Floating Action Button (white background + red plus)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white, // white button
        onPressed: () => Navigator.of(context).pushNamed('/upload'),
        child: const Icon(Icons.add, color: Color(0xFFb71c1c)), // red plus
      ),

      body: SafeArea(
        child: _pages[_currentIndex], // ✅ display selected page
      ),

      // ✅ Rounded Bottom Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFFb71c1c), // ✅ red active icon
            unselectedItemColor: Colors.grey, // ✅ grey inactive
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Search",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category),
                label: "Category",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
