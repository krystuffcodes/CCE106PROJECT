import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/item_service.dart';
import '../models/item.dart';
import 'item_detail_page.dart'; // ✅ Import details page

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<ItemService>(context).items;

    // 🔎 Filter items by query
    final results = items.where((item) {
      final title = item.title.toLowerCase();
      final category = item.category.toLowerCase();
      final location = item.locationFound.toLowerCase();
      final search = query.toLowerCase();

      return title.contains(search) ||
          category.contains(search) ||
          location.contains(search);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Items'),
        backgroundColor: Colors.red[700],
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by name, category, or location...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),
          ),

          // 📋 Show search results
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text(
                      "No items found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Image.asset(
                            item.imagePath,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item.title),
                          subtitle:
                              Text("${item.category} • ${item.locationFound}"),
                          trailing: Icon(
                            item.isFound ? Icons.check_circle : Icons.search,
                            color: item.isFound ? Colors.green : Colors.orange,
                          ),

                          // 👉 Tap to go to details
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ItemDetailPage(item: item),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
