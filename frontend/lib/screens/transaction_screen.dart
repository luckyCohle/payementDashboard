// lib/screens/transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List transactions = [];
  int page = 1;
  int limit = 10;
  String? selectedStatus;
  String? selectedMethod;
  DateTime? startDate;
  DateTime? endDate;
  String? senderId;
  String? receiverId;
  bool _showFilters = false;

  final statusOptions = ['SUCCESS', 'FAILED', 'PENDING'];
  final methodOptions = ['UPI', 'CARD', 'NETBANKING', 'WALLET', 'CASH'];

  bool isLoading = false;
  bool hasMore = true;

  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();

  Future<void> fetchTransactions({bool loadMore = false}) async {
    if (loadMore && !hasMore) return;
    if (!loadMore) setState(() => isLoading = true);

    final queryParams = {
      'page': loadMore ? (page + 1).toString() : '1',
      'limit': limit.toString(),
      if (selectedStatus != null) 'status': selectedStatus!,
      if (selectedMethod != null) 'method': selectedMethod!,
      if (startDate != null)
        'startDate': startDate!.toIso8601String().split('T')[0],
      if (endDate != null) 'endDate': endDate!.toIso8601String().split('T')[0],
      if (senderId != null && senderId!.isNotEmpty) 'senderId': senderId!,
      if (receiverId != null && receiverId!.isNotEmpty)
        'receiverId': receiverId!,
    };

    final uri = Uri.http('localhost:3000', '/payment', queryParams);
    try {
      final res = await http.get(uri);
      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        setState(() {
          if (loadMore) {
            transactions.addAll(data['data']);
            page++;
          } else {
            transactions = data['data'];
            page = 1;
          }
          hasMore = data['data'].length == limit;
        });
      } else {
        _showErrorSnackBar('Error: ${data['message']}');
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching transactions: $e');
    }

    if (!loadMore) setState(() => isLoading = false);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  @override
  void dispose() {
    _senderController.dispose();
    _receiverController.dispose();
    super.dispose();
  }

  void _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        startDate = date;
      });
      fetchTransactions();
    }
  }

  void _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        endDate = date;
      });
      fetchTransactions();
    }
  }

  void _clearFilters() {
    setState(() {
      selectedStatus = null;
      selectedMethod = null;
      startDate = null;
      endDate = null;
      senderId = null;
      receiverId = null;
      _senderController.clear();
      _receiverController.clear();
    });
    fetchTransactions();
  }

  void _navigateToDetails(Map txn) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailsScreen(transaction: txn),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
    );
  }

  Widget _buildDropdownFilter({
    required String hint,
    required String? value,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('All ${hint.toLowerCase()}'),
            ),
            ...options.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map txn) {
    final status = txn['status'];
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    switch (status) {
      case 'SUCCESS':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'FAILED':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case 'PENDING':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetails(txn),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${txn['amount']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      txn['method'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'From: ${txn['senderId']}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'To: ${txn['receiverId']}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              if (txn['createdAt'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      txn['createdAt'].toString().split('T')[0],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFiltersCount = [
      selectedStatus,
      selectedMethod,
      startDate,
      endDate,
      senderId,
      receiverId,
    ].where((filter) => filter != null && filter.toString().isNotEmpty).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
              if (activeFiltersCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$activeFiltersCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => fetchTransactions(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showFilters ? null : 0,
            child: _showFilters
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Filters',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (activeFiltersCount > 0)
                              TextButton(
                                onPressed: _clearFilters,
                                child: const Text('Clear All'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Status and Method Filters
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownFilter(
                                hint: 'Status',
                                value: selectedStatus,
                                options: statusOptions,
                                onChanged: (value) {
                                  setState(() => selectedStatus = value);
                                  fetchTransactions();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdownFilter(
                                hint: 'Method',
                                value: selectedMethod,
                                options: methodOptions,
                                onChanged: (value) {
                                  setState(() => selectedMethod = value);
                                  fetchTransactions();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Date Filters
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _selectStartDate,
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                ),
                                label: Text(
                                  startDate != null
                                      ? 'From: ${startDate!.day}/${startDate!.month}/${startDate!.year}'
                                      : 'Start Date',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _selectEndDate,
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                ),
                                label: Text(
                                  endDate != null
                                      ? 'To: ${endDate!.day}/${endDate!.month}/${endDate!.year}'
                                      : 'End Date',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // ID Filters
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _senderController,
                                decoration: const InputDecoration(
                                  labelText: 'Sender ID',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  senderId = value;
                                },
                                onSubmitted: (_) => fetchTransactions(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _receiverController,
                                decoration: const InputDecoration(
                                  labelText: 'Receiver ID',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  receiverId = value;
                                },
                                onSubmitted: (_) => fetchTransactions(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: fetchTransactions,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Transaction List
          Expanded(
            child: isLoading && transactions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading transactions...'),
                      ],
                    ),
                  )
                : transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: transactions.length + (hasMore ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == transactions.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () =>
                                  fetchTransactions(loadMore: true),
                              child: const Text('Load More'),
                            ),
                          ),
                        );
                      }
                      return _buildTransactionCard(transactions[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class TransactionDetailsScreen extends StatelessWidget {
  final Map transaction;
  const TransactionDetailsScreen({super.key, required this.transaction});

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = transaction['status'];
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    switch (status) {
      case 'SUCCESS':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'FAILED':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case 'PENDING':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade600,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '₹${transaction['amount']}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transaction Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...transaction.entries.map((entry) {
                    return _buildDetailRow(
                      entry.key.toString().toUpperCase(),
                      entry.value.toString(),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
