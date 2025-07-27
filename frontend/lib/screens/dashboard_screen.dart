import 'package:flutter/material.dart';
import 'package:frontend/screens/add_payment_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/payment_stats.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PaymentStats? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    final url = Uri.parse('http://localhost:3000/payment/stats');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        final parsed = PaymentStats.fromJson(jsonBody['stats']);
        setState(() {
          stats = parsed;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallCard = constraints.maxWidth < 180;
        return Container(
          padding: EdgeInsets.all(isSmallCard ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallCard ? 6 : 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: isSmallCard ? 20 : 24,
                    ),
                  ),
                  if (subtitle != null && !isSmallCard) ...[
                    const Spacer(),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: isSmallCard ? 8 : 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: isSmallCard ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallCard ? 11 : 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildChart() {
    if (stats == null) return const SizedBox();
    final data = stats!.recentRevenue;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;

        return Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flex(
                direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Revenue Trend",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (!isSmallScreen) const Spacer(),
                  SizedBox(height: isSmallScreen ? 8 : 0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "Last 7 Days",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              SizedBox(
                height: isSmallScreen ? 180 : 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: !isSmallScreen,
                      horizontalInterval: 1,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: isSmallScreen ? 25 : 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= data.length)
                              return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                data[index].date.split('-').last,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                  fontSize: isSmallScreen ? 10 : 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: null,
                          reservedSize: isSmallScreen ? 45 : 55,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '₹${value.toInt()}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: data
                            .asMap()
                            .entries
                            .map(
                              (e) => FlSpot(e.key.toDouble(), e.value.amount),
                            )
                            .toList(),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                        barWidth: isSmallScreen ? 2.5 : 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: !isSmallScreen,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 3,
                              color: Colors.white,
                              strokeWidth: 2,
                              strokeColor: Colors.blue.shade600,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade100.withOpacity(0.3),
                              Colors.blue.shade50.withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchStats();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading dashboard...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : stats == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load stats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      fetchStats();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards - Responsive Layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isTablet = screenWidth > 600;
                      final cardPadding = screenWidth < 400 ? 12.0 : 16.0;

                      if (isTablet) {
                        // Tablet: 3 cards in a row, then revenue card full width
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: buildStatCard(
                                    title: "Total Transactions",
                                    value: "${stats!.totalTransactions}",
                                    icon: Icons.receipt_long,
                                    color: Colors.green,
                                    subtitle: "All time",
                                  ),
                                ),
                                SizedBox(width: cardPadding),
                                Expanded(
                                  child: buildStatCard(
                                    title: "Failed Transactions",
                                    value: "${stats!.failedTransactions}",
                                    icon: Icons.error_outline,
                                    color: Colors.red,
                                    subtitle: "Needs attention",
                                  ),
                                ),
                                SizedBox(width: cardPadding),
                                Expanded(
                                  child: buildStatCard(
                                    title: "Total Revenue",
                                    value:
                                        "₹${stats!.totalRevenue.toStringAsFixed(2)}",
                                    icon: Icons.account_balance_wallet,
                                    color: Colors.blue,
                                    subtitle: "All time",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        // Mobile: Stacked layout or 2x2 grid based on screen size
                        return Column(
                          children: [
                            if (screenWidth < 350) ...[
                              // Very small screens: Stack vertically
                              buildStatCard(
                                title: "Total Transactions",
                                value: "${stats!.totalTransactions}",
                                icon: Icons.receipt_long,
                                color: Colors.green,
                                subtitle: "All time",
                              ),
                              SizedBox(height: cardPadding),
                              buildStatCard(
                                title: "Failed Transactions",
                                value: "${stats!.failedTransactions}",
                                icon: Icons.error_outline,
                                color: Colors.red,
                                subtitle: "Needs attention",
                              ),
                              SizedBox(height: cardPadding),
                              buildStatCard(
                                title: "Total Revenue",
                                value:
                                    "₹${stats!.totalRevenue.toStringAsFixed(2)}",
                                icon: Icons.account_balance_wallet,
                                color: Colors.blue,
                                subtitle: "All time",
                              ),
                            ] else ...[
                              // Normal mobile: 2x2 grid for first two, then full width for revenue
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: buildStatCard(
                                      title: "Total Transactions",
                                      value: "${stats!.totalTransactions}",
                                      icon: Icons.receipt_long,
                                      color: Colors.green,
                                      subtitle: "All time",
                                    ),
                                  ),
                                  SizedBox(width: cardPadding),
                                  Expanded(
                                    child: buildStatCard(
                                      title: "Failed Transactions",
                                      value: "${stats!.failedTransactions}",
                                      icon: Icons.error_outline,
                                      color: Colors.red,
                                      subtitle: "Needs attention",
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: cardPadding),
                              buildStatCard(
                                title: "Total Revenue",
                                value:
                                    "₹${stats!.totalRevenue.toStringAsFixed(2)}",
                                icon: Icons.account_balance_wallet,
                                color: Colors.blue,
                                subtitle: "All time earnings",
                              ),
                            ],
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  // Chart - Responsive
                  buildChart(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddPaymentScreen(),
                        ),
                      );
                    },
                    child: const Text('Add Payment'),
                  ),
                ],
              ),
            ),
    );
  }
}
