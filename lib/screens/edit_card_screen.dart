import 'package:flutter/material.dart';

import '../database/ration_repository.dart';
import '../models/ration_card.dart';

class EditCardScreen extends StatefulWidget {
  final RationCard card;

  const EditCardScreen({
    super.key,
    required this.card,
  });

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final _formKey = GlobalKey<FormState>();

  final repository = RationRepository.instance;

  late TextEditingController cardNumberController;
  late TextEditingController headNameController;
  late TextEditingController relationController;
  late TextEditingController mobileController;
  late TextEditingController categoryController;
  late TextEditingController unitsController;
  late TextEditingController riceController;
  late TextEditingController addressController;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    cardNumberController =
        TextEditingController(text: widget.card.cardNumber);

    headNameController =
        TextEditingController(text: widget.card.headName);

    relationController =
        TextEditingController(text: widget.card.relation);

    mobileController =
        TextEditingController(text: widget.card.mobile);

    categoryController =
        TextEditingController(text: widget.card.category);

    unitsController =
        TextEditingController(text: widget.card.units.toString());

    riceController =
        TextEditingController(text: widget.card.rice.toString());

    addressController =
        TextEditingController(text: widget.card.address);
  }

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    final updatedCard = RationCard(
      id: widget.card.id,
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
      await repository.updateCard(updatedCard);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Card updated successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, updatedCard);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Update failed: $e"),
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
        title: const Text("Edit Beneficiary"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            buildTextField(
              controller: cardNumberController,
              label: "Card Number",
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
                  saving ? "Saving..." : "Save Changes",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}