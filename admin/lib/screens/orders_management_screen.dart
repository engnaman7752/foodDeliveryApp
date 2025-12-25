import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  String _selectedFilter = 'all';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getOrdersStream() {
    if (_selectedFilter == 'all') {
      return _firestore
          .collection('orders')
          .orderBy('orderTime', descending: true)
          .snapshots();
    } else {
      return _firestore
          .collection('orders')
          .where('status', isEqualTo: _selectedFilter)
          .orderBy('orderTime', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Orders',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All Orders'),
                      const SizedBox(width: 8),
                      _buildFilterChip('pending', 'Pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('confirmed', 'Confirmed'),
                      const SizedBox(width: 8),
                      _buildFilterChip('preparing', 'Preparing'),
                      const SizedBox(width: 8),
                      _buildFilterChip('ready', 'Ready'),
                      const SizedBox(width: 8),
                      _buildFilterChip('in_delivery', 'In Delivery'),
                      const SizedBox(width: 8),
                      _buildFilterChip('ended', 'Delivered'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Orders List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getOrdersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No orders found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final orderDoc = snapshot.data!.docs[index];
                    final orderData = OrderModel.fromJson(
                      orderDoc.data() as Map<String, dynamic>,
                    );
                    return _buildOrderCard(orderData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFF6200EA),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.orderId?.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.sellerName ?? 'Unknown',
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
                    color: _getStatusColor(order.status ?? ''),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status?.toUpperCase() ?? 'UNKNOWN',
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

            // Order Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '₹${order.totalAmount}',
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
                      'Company Commission (10%)',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '₹${order.companyCommission}',
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
                      '₹${order.sellerAmount}',
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
            const SizedBox(height: 12),

            // Payment and Rider Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      order.paymentMethod == 'cash_on_delivery'
                          ? Icons.money
                          : Icons.credit_card,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.paymentMethod == 'cash_on_delivery'
                          ? 'Cash on Delivery'
                          : 'Card Payment',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                if (order.riderName != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.delivery_dining,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Rider: ${order.riderName}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Time Info
            Text(
              'Order Time: ${DateFormat('dd MMM, hh:mm aa').format(DateTime.fromMillisecondsSinceEpoch(int.parse(order.orderTime ?? '0')))}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _showOrderDetails(order);
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Details'),
                ),
                const SizedBox(width: 8),
                if (order.status != 'ended' && order.status != 'cancelled')
                  TextButton.icon(
                    onPressed: () {
                      _showUpdateStatusDialog(order);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Update'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.deepOrange;
      case 'ready':
        return Colors.teal;
      case 'in_delivery':
        return Colors.indigo;
      case 'ended':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.orderId?.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Seller', order.sellerName ?? 'N/A'),
              _buildDetailRow('Rider', order.riderName ?? 'Not Assigned'),
              _buildDetailRow('Payment', order.paymentMethod ?? 'N/A'),
              _buildDetailRow('Status', order.status ?? 'N/A'),
              _buildDetailRow('Total Amount', '₹${order.totalAmount}'),
              _buildDetailRow(
                'Commission (10%)',
                '₹${order.companyCommission}',
              ),
              _buildDetailRow('Seller Amount (90%)', '₹${order.sellerAmount}'),
              if (order.paymentMethod == 'cash_on_delivery')
                _buildDetailRow(
                  'Cash Collected',
                  order.cashCollected == true ? 'Yes' : 'No',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(OrderModel order) {
    final statuses = [
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'in_delivery',
      'ended',
    ];
    String? selectedStatus = order.status;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: DropdownButton<String>(
          value: selectedStatus,
          isExpanded: true,
          items: statuses
              .map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.toUpperCase()),
                ),
              )
              .toList(),
          onChanged: (value) {
            selectedStatus = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (selectedStatus != null) {
                await _firestore.collection('orders').doc(order.orderId).update(
                  {'status': selectedStatus},
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order status updated')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
