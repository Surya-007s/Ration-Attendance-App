import 'package:flutter/material.dart';

import '../database/ration_repository.dart';
import '../models/ration_card.dart';
import 'card_details_screen.dart';

class PendingScreen extends StatefulWidget {
  const PendingScreen({super.key});

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  final RationRepository repository = RationRepository.instance;

  final TextEditingController searchController = TextEditingController();

  List<RationCard> allCards = [];
  List<RationCard> filteredCards = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPendingCards();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadPendingCards() async {
    allCards = await repository.getPendingCards();
    filteredCards = List.from(allCards);

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  void search(String value) {
    if (value.isEmpty) {
      filteredCards = List.from(allCards);
    } else {
      filteredCards = allCards.where((card) {
        return card.headName
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            card.cardNumber
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            card.mobile
                .toLowerCase()
                .contains(value.toLowerCase());
      }).toList();
    }

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Cards"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadPendingCards,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      controller: searchController,
                      onChanged: search,
                      decoration: InputDecoration(
                        hintText: "Search Pending Cards",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.pending_actions,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Pending : ${filteredCards.length}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: filteredCards.isEmpty
                        ? const Center(
                            child: Text(
                              "No Pending Cards",
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredCards.length,
                            itemBuilder: (context, index) {
                              final card = filteredCards[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                elevation: 3,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Colors.orange.shade100,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.orange,
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
                                          "Card : ${card.cardNumber}"),
                                      Text(
                                          "Mobile : ${card.mobile}"),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "Pending",
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CardDetailsScreen(
                                          card: card,
                                        ),
                                      ),
                                    );

                                    await loadPendingCards();
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