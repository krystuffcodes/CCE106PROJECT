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
  int _currentIndex = 0; 
  String? _selectedCategory; // ✅ Track which category is selected

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<ItemService>(context);
    final items = service.items;

    // Categories
    final categories = [
      {"name": "Phone", "icon": Icons.phone_iphone},
      {"name": "Wallet", "icon": Icons.wallet},
      {"name": "ID", "icon": Icons.badge},
      {"name": "Keys", "icon": Icons.key},
      {"name": "Bottle", "icon": Icons.local_drink},
      {"name": "Bag", "icon": Icons.backpack},
      {"name": "Others", "icon": Icons.more_horiz},
    ];

    // Pages for nav bar
    final List<Widget> _pages = [
      // 🏠 Home page
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

      // 🔍 Search page
      _buildSearchPage(items),

      // 🗂️ Category page
      _selectedCategory == null
          ? _buildCategoryGrid(categories) // show categories
          : _buildCategoryItems(items),    // show filtered items
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
              // navigate to profile
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () => Navigator.of(context).pushNamed('/upload'),
        child: const Icon(Icons.add, color: Color(0xFFb71c1c)),
      ),

      body: SafeArea(child: _pages[_currentIndex]),

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
                _selectedCategory = null; // reset when switching tabs
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFFb71c1c),
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
              BottomNavigationBarItem(icon: Icon(Icons.category), label: "Category"),
            ],
          ),
        ),
      ),
    );
  }

  // 🔍 Search Page
  Widget _buildSearchPage(List items) {
    return Column(
      children: [
        Container(
          color: const Color(0xFFb71c1c),
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          child: const Text(
            "Search Items",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        const SizedBox(height: 8),
        // TODO: add search bar logic
        const Center(child: Text("Search UI here")),
      ],
    );
  }

  // 🗂️ Category Grid
  Widget _buildCategoryGrid(List categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (ctx, i) {
        final cat = categories[i];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = cat["name"];
            });
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat["icon"], size: 40, color: const Color(0xFFb71c1c)),
                const SizedBox(height: 8),
                Text(cat["name"],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🗂️ Show Items by Category
  Widget _buildCategoryItems(List items) {
    final filtered = items
        .where((it) => it.category.toLowerCase() == _selectedCategory!.toLowerCase())
        .toList();

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => setState(() => _selectedCategory = null),
            ),
            Text("$_selectedCategory Items",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text("No items found in this category"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final it = filtered[i];
                    return ListTile(
                      leading: Image.asset(
                        it.imagePath,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(it.title),
                      subtitle: Text(it.locationFound),
                      trailing: Icon(
                        it.isFound ? Icons.check_circle : Icons.error,
                        color: it.isFound ? Colors.green : Colors.red,
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ItemDetailPage(item: it),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
