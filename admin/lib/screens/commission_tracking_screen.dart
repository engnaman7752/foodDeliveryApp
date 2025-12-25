import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/commission_report.dart';

class CommissionTrackingScreen extends StatefulWidget {
  const CommissionTrackingScreen({super.key});

  @override
  State<CommissionTrackingScreen> createState() =>
      _CommissionTrackingScreenState();
}

class _CommissionTrackingScreenState extends State<CommissionTrackingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filterPaymentMethod = 'all'; // all, card, cash_on_delivery

  Stream<QuerySnapshot> _getCommissionStream() {
    if (_filterPaymentMethod == 'all') {
      return _firestore
          .collection('orders')
          .orderBy('orderTime', descending: true)
          .snapshots();
    } else {
      return _firestore
          .collection('orders')
          .where('paymentMethod', isEqualTo: _filterPaymentMethod)
          .orderBy('orderTime', descending: true)
          .snapshots();
    }
  }

  Future<Map<String, dynamic>> _getCommissionStats() async {
    try {
      final snapshot = await _firestore.collection('orders').get();

      double totalCommission = 0;
      double cardPaymentCommission = 0;
      double codCommission = 0;
      int totalOrders = 0;
      int codOrders = 0;
      int cardOrders = 0;

      for (var doc in snapshot.docs) {
        final commission =
            double.tryParse(doc.get('companyCommission')?.toString() ?? '0') ??
            0;
        final paymentMethod = doc.get('paymentMethod')?.toString() ?? '';

        totalCommission += commission;
        totalOrders++;

        if (paymentMethod == 'cash_on_delivery') {
          codCommission += commission;
          codOrders++;
        } else if (paymentMethod == 'card') {
          cardPaymentCommission += commission;
          cardOrders++;
        }
      }

      return {
        'totalCommission': totalCommission,
        'cardPaymentCommission': cardPaymentCommission,
        'codCommission': codCommission,
        'totalOrders': totalOrders,
        'codOrders': codOrders,
        'cardOrders': cardOrders,
      };
    } catch (e) {
      return {
        'totalCommission': 0,
        'cardPaymentCommission': 0,
        'codCommission': 0,
        'totalOrders': 0,
        'codOrders': 0,
        'cardOrders': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stats Section
            FutureBuilder<Map<String, dynamic>>(
              future: _getCommissionStats(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  );
                }

                final stats = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Commission Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Total Commission',
                              value:
                                  '₹${(stats['totalCommission'] as double).toStringAsFixed(2)}',
                              icon: Icons.trending_up,
                              color: const Color(0xFF6200EA),
                              subtitle: '${stats['totalOrders']} orders',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Card Payments',
                              value:
                                  '₹${(stats['cardPaymentCommission'] as double).toStringAsFixed(2)}',
                              icon: Icons.credit_card,
                              color: const Color(0xFF03DAC6),
                              subtitle: '${stats['cardOrders']} orders',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        title: 'Cash on Delivery',
                        value:
                            '₹${(stats['codCommission'] as double).toStringAsFixed(2)}',
                        icon: Icons.money,
                        color: const Color(0xFFFF6D00),
                        subtitle: '${stats['codOrders']} orders',
                      ),
                    ],
                  ),
                );
              },
            ),

            // Filter Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Payment Method',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildFilterChip('all', 'All Orders')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildFilterChip('card', 'Card Payment')),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFilterChip(
                          'cash_on_delivery',
                          'Cash on Delivery',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Commission List
            StreamBuilder<QuerySnapshot>(
              stream: _getCommissionStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No commission records found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (context, index) {
                    final orderDoc = snapshot.data!.docs[index];
                    final orderData = orderDoc.data() as Map<String, dynamic>;
                    return _buildCommissionCard(orderData);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterPaymentMethod == value;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterPaymentMethod = selected ? value : 'all';
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFF6200EA),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
    );
  }

  Widget _buildCommissionCard(Map<String, dynamic> orderData) {
    final orderId = orderData['orderId']?.toString() ?? 'Unknown';
    final sellerName = orderData['sellerName']?.toString() ?? 'Unknown';
    final totalAmount =
        double.tryParse(orderData['totalAmount']?.toString() ?? '0') ?? 0;
    final commission =
        double.tryParse(orderData['companyCommission']?.toString() ?? '0') ?? 0;
    final sellerAmount =
        double.tryParse(orderData['sellerAmount']?.toString() ?? '0') ?? 0;
    final paymentMethod = orderData['paymentMethod']?.toString() ?? 'Unknown';
    final orderTime =
        int.tryParse(orderData['orderTime']?.toString() ?? '0') ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${orderId.substring(0, min(8, orderId.length))}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sellerName,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: paymentMethod == 'cash_on_delivery'
                        ? Colors.orange
                        : Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    paymentMethod == 'cash_on_delivery' ? 'COD' : 'CARD',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Commission Breakdown
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Amount',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        '₹${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Our Commission (10%)',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        '₹${commission.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6200EA),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seller Gets (90%)',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        '₹${sellerAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF03DAC6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Order Time
            Text(
              'Order Time: ${DateFormat('dd MMM, hh:mm aa').format(DateTime.fromMillisecondsSinceEpoch(orderTime))}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

int min(int a, int b) => a < b ? a : b;
