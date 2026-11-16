import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/ration_repository.dart';
import '../models/attendance_history.dart';
import '../models/ration_card.dart';
import '../services/audio_service.dart';
import 'edit_card_screen.dart';

class CardDetailsScreen extends StatefulWidget {
  final RationCard card;

  const CardDetailsScreen({
    super.key,
    required this.card,
  });

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  final RationRepository repository = RationRepository.instance;

  late RationCard card;

  bool isReceived = false;
  bool loading = true;

  List<AttendanceHistory> history = [];

  @override
  void initState() {
    super.initState();

    card = widget.card;

    checkAttendance();
  }

  Future<void> checkAttendance() async {
    isReceived = await repository.isReceived(card.cardNumber);

    history = await repository.getAttendanceHistory(card.cardNumber);

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    AudioService.instance.announceCardFound(card.headName);
  }

  Future<void> markReceived() async {
    if (isReceived) {
      AudioService.instance.announceAlreadyReceived();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Already marked for this month."),
        ),
      );
      return;
    }

    try {
      await repository.markReceived(card.cardNumber);

      history = await repository.getAttendanceHistory(card.cardNumber);

      setState(() {
        isReceived = true;
      });

      if (!mounted) return;

      AudioService.instance.announceAttendanceMarked(
        card.headName,
        card.rice,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Ration marked successfully."),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error: $e"),
        ),
      );
    }
  }

  Future<void> editCard() async {
    final updated = await Navigator.push<RationCard>(
      context,
      MaterialPageRoute(
        builder: (_) => EditCardScreen(card: card),
      ),
    );

    if (updated != null) {
      setState(() {
        card = updated;
      });

      await checkAttendance();
    }
  }

  String formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return "-";
    }

    final date = DateTime.parse(value);

    return DateFormat(
      "dd MMM yyyy • hh:mm a",
    ).format(date);
  }

  String monthName(int month) {
    return DateFormat("MMMM").format(
      DateTime(2025, month),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ration Card Details"),
        actions: [
          IconButton(
            onPressed: editCard,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.green.shade100,
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.green,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      buildDetail(
                        Icons.credit_card,
                        "Card Number",
                        card.cardNumber,
                      ),

                      buildDetail(
                        Icons.person,
                        "Head of Family",
                        card.headName,
                      ),

                      buildDetail(
                        Icons.family_restroom,
                        "Relation",
                        card.relation,
                      ),

                      buildDetail(
                        Icons.phone,
                        "Mobile",
                        card.mobile,
                      ),

                      buildDetail(
                        Icons.category,
                        "Category",
                        card.category,
                      ),

                      buildDetail(
                        Icons.people,
                        "Family Units",
                        card.units.toString(),
                      ),

                      buildDetail(
                        Icons.rice_bowl,
                        "Rice",
                        "${card.rice} KG",
                      ),

                      buildDetail(
                        Icons.location_on,
                        "Address",
                        card.address,
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isReceived
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            isReceived
                                ? "✅ RECEIVED"
                                : "❌ NOT RECEIVED",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isReceived
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Divider(),

                      const SizedBox(height: 10),

                      const Text(
                        "Attendance History",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      history.isEmpty
                      ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "No attendance history available.",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount: history.length,
                              itemBuilder: (context, index) {
                                final item = history[index];

                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Colors.green.shade100,
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      ),
                                    ),
                                    title: Text(
                                      "${monthName(item.month)} ${item.year}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "📅 ${formatDate(item.receivedAt)}",
                                    ),
                                    trailing: const Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                    ),
                                  ),
                                );
                              },
                            ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed:
                              isReceived ? null : markReceived,
                          icon: const Icon(Icons.check_circle),
                          label: Text(
                            isReceived
                                ? "ALREADY RECEIVED"
                                : "MARK RECEIVED",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildDetail(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "-" : value,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}