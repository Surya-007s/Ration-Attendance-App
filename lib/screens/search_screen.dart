import 'package:flutter/material.dart';

import '../database/ration_repository.dart';
import '../models/ration_card.dart';
import 'card_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  final RationRepository repository = RationRepository.instance;

  List<RationCard> filteredCards = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCards();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadCards() async {
    filteredCards = await repository.getAllCards();

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Future<void> searchCard(String value) async {
    if (value.trim().isEmpty) {
      filteredCards = await repository.getAllCards();
    } else {
      filteredCards = await repository.searchCards(value.trim());
    }

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Ration Card"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: searchCard,
              decoration: InputDecoration(
                hintText: "Search Card Number / Name / Mobile",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : filteredCards.isEmpty
                      ? const Center(
                          child: Text(
                            "No Records Found",
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredCards.length,
                          itemBuilder: (context, index) {
                            final card = filteredCards[index];

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade100,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.green,
                                  ),
                                ),
                                title: Text(
                                  card.headName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Card No : ${card.cardNumber}"),
                                    Text(
                                        "Category : ${card.category}"),
                                    Text(
                                        "Units : ${card.units}"),
                                  ],
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CardDetailsScreen(card: card),
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
      ),
    );
  }
}