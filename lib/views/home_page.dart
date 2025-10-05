import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/item_service.dart';
import '../widgets/item_card.dart';
import 'item_detail_page.dart';
import '../models/item.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _searchQuery = "";

  // ✅ Get current Firebase user
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<ItemService>(context);
    final items = service.items;

    final filteredItems = items.where((item) {
      final q = _searchQuery.toLowerCase();
      return item.title.toLowerCase().contains(q) ||
          item.locationFound.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);
    }).toList();

    final List<Widget> _pages = [
      // 🏠 HOME PAGE
      Column(
        children: [
          Container(
            color: const Color(0xFFb71c1c),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: const Text(
              "Lost & Found Items",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
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
          ),
        ],
      ),

      // 🔍 SEARCH PAGE
      Column(
        children: [
          Container(
            color: const Color(0xFFb71c1c),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: const Text(
              "Search Items",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by name, category, or location",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      "No items found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (ctx, i) {
                      final it = filteredItems[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: it.imagePath.startsWith('assets/')
                                ? Image.asset(
                                    it.imagePath,
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.contain,
                                  )
                                : Image.file(
                                    File(it.imagePath),
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                          title: Text(
                            it.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle:
                              Text("${it.category} • ${it.locationFound}"),
                          trailing: Icon(
                            it.isFound ? Icons.check_circle : Icons.cancel,
                            color: it.isFound ? Colors.green : Colors.red,
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ItemDetailPage(item: it),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // 📂 CATEGORY PAGE
      CategoryPage(items: items),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFb71c1c),
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🔹 Left side: Logo
            Row(
              children: [
                const SizedBox(width: 12),
                Image.asset('assets/logo.png', height: 40),
              ],
            ),

            // 🔹 Right side: user name + avatar
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    user?.displayName ?? 'Guest User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      user?.photoURL ??
                          'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ],
        ),
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

// ===============================
// CATEGORY PAGE
// ===============================
class CategoryPage extends StatefulWidget {
  final List<Item> items;
  const CategoryPage({super.key, required this.items});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final categories = widget.items
        .map((e) => (e.category ?? 'Others').trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final dropdownCategories = ["All", ...categories];

    final filteredItems = (selectedCategory == null || selectedCategory == "All")
        ? widget.items
        : widget.items
            .where((it) => (it.category ?? '').toLowerCase() ==
                selectedCategory!.toLowerCase())
            .toList();

    return Column(
      children: [
        Container(
          color: const Color(0xFFb71c1c),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: const Text(
            "Browse by Category",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: DropdownButtonFormField<String>(
            value: selectedCategory ?? "All",
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelText: "Select Category",
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: dropdownCategories.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(cat),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                selectedCategory = val;
              });
            },
          ),
        ),
        Expanded(
          child: filteredItems.isEmpty
              ? const Center(child: Text("No items in this category"))
              : GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (ctx, i) {
                    final it = filteredItems[i];
                    return ItemCard(
                      item: it,
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
