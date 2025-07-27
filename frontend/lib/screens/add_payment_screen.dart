import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<int> extractUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');
  Map<String, dynamic> payload = Jwt.parseJwt(token!);

  final userId = payload['sub'];

  print("User ID from token: $userId");
  return userId;
}

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();

  String? selectedStatus;
  String? selectedMethod;
  bool isLoading = false;

  final List<String> statusOptions = ['SUCCESS', 'FAILED', 'PENDING'];
  final List<String> methodOptions = ['UPI', 'CARD', 'NETBANKING', 'CASH'];

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text.trim());
    final receiverId = int.tryParse(_receiverController.text.trim());
    final senderId = await extractUserId();

    final paymentData = {
      'amount': amount,
      'method': selectedMethod,
      'status': selectedStatus,
      'senderId': senderId,
      'receiverId': receiverId,
    };

    setState(() {
      isLoading = true;
    });

    try {
      final res = await http.post(
        Uri.parse('http://localhost:3000/payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(paymentData),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Payment created')),
        );
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Failed to create payment')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _receiverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Payment')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (value) => value!.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _receiverController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Receiver ID'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter receiver ID' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                items: statusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => selectedStatus = value),
                decoration: const InputDecoration(labelText: 'Status'),
                validator: (value) => value == null ? 'Select status' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedMethod,
                items: methodOptions
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (value) => setState(() => selectedMethod = value),
                decoration: const InputDecoration(labelText: 'Method'),
                validator: (value) => value == null ? 'Select method' : null,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Submit Payment'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
