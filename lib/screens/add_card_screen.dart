import 'package:flutter/material.dart';
import '../database/ration_repository.dart';
import '../models/ration_card.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final repository = RationRepository.instance;

  final cardNumberController = TextEditingController();
  final headNameController = TextEditingController();
  final relationController = TextEditingController();
  final mobileController = TextEditingController();
  final categoryController = TextEditingController();
  final unitsController = TextEditingController();
  final riceController = TextEditingController();
  final addressController = TextEditingController();

  bool saving = false;

  @override
  void dispose() {
    cardNumberController.dispose();
    headNameController.dispose();
    relationController.dispose();
    mobileController.dispose();
    categoryController.dispose();
    unitsController.dispose();
    riceController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      saving = true;
    });

    final card = RationCard(
      cardNumber: cardNumberController.text.trim(),
      headName: headNameController.text.trim(),
      relation: relationController.text.trim(),
      mobile: mobileController.text.trim(),
      category: categoryController.text.trim(),
      units: int.tryParse(unitsController.text.trim()) ?? 0,
      rice: int.tryParse(riceController.text.trim()) ?? 0,
      address: addressController.text.trim(),
    );

    try {
      await repository.addCard(card);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Beneficiary Added Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('UNIQUE')
                ? "A card with this number already exists."
                : "Failed to save: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool requiredField = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: requiredField
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return "$label is required";
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Beneficiary"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            buildTextField(
              controller: cardNumberController,
              label: "Card Number",
              requiredField: true,
            ),
            buildTextField(
              controller: headNameController,
              label: "Head Name",
              requiredField: true,
            ),
            buildTextField(
              controller: relationController,
              label: "Relation",
            ),
            buildTextField(
              controller: mobileController,
              label: "Mobile Number",
              keyboardType: TextInputType.phone,
            ),
            buildTextField(
              controller: categoryController,
              label: "Category",
            ),
            buildTextField(
              controller: unitsController,
              label: "Units",
              keyboardType: TextInputType.number,
            ),
            buildTextField(
              controller: riceController,
              label: "Rice (KG)",
              keyboardType: TextInputType.number,
            ),
            buildTextField(
              controller: addressController,
              label: "Address",
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: saving ? null : saveCard,
                icon: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  saving ? "Saving..." : "SAVE BENEFICIARY",
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
    );
  }
}