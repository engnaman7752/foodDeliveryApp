import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/seller_model.dart';

class SellersManagementScreen extends StatefulWidget {
  const SellersManagementScreen({super.key});

  @override
  State<SellersManagementScreen> createState() =>
      _SellersManagementScreenState();
}

class _SellersManagementScreenState extends State<SellersManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filterStatus = 'all'; // all, approved, pending

  Stream<QuerySnapshot> _getSellersStream() {
    if (_filterStatus == 'all') {
      return _firestore.collection('sellers').snapshots();
    } else if (_filterStatus == 'approved') {
      return _firestore
          .collection('sellers')
          .where('isApproved', isEqualTo: true)
          .snapshots();
    } else {
      return _firestore
          .collection('sellers')
          .where('isApproved', isEqualTo: false)
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
                  'Filter Sellers',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildFilterChip('all', 'All Sellers')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFilterChip('approved', 'Approved')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFilterChip('pending', 'Pending')),
                  ],
                ),
              ],
            ),
          ),
          // Sellers List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getSellersStream(),
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
                          Icons.store_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No sellers found',
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
                    final sellerDoc = snapshot.data!.docs[index];
                    final sellerData = SellerModel.fromJson(
                      sellerDoc.data() as Map<String, dynamic>,
                    );
                    return _buildSellerCard(sellerData);
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
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? value : 'all';
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

  Widget _buildSellerCard(SellerModel seller) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seller Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seller.sellerName ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        seller.restaurantName ?? 'No restaurant name',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: seller.isApproved == true
                        ? Colors.green
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    seller.isApproved == true ? 'APPROVED' : 'PENDING',
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

            // Seller Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Orders',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      seller.totalOrders ?? '0',
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
                      'Total Earnings',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '₹${seller.totalEarnings ?? '0'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF03DAC6),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rating',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          seller.rating ?? '0.0',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Contact Info
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    seller.sellerEmail ?? 'No email',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  seller.phoneNumber ?? 'No phone',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _showSellerDetails(seller);
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Details'),
                ),
                const SizedBox(width: 8),
                if (seller.isApproved != true)
                  TextButton.icon(
                    onPressed: () {
                      _approveSeller(seller.sellerId!);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                  ),
                if (seller.isApproved == true)
                  TextButton.icon(
                    onPressed: () {
                      _removeSeller(seller.sellerId!);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Remove'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSellerDetails(SellerModel seller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(seller.sellerName ?? 'Seller Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', seller.sellerEmail ?? 'N/A'),
              _buildDetailRow('Phone', seller.phoneNumber ?? 'N/A'),
              _buildDetailRow('Restaurant', seller.restaurantName ?? 'N/A'),
              _buildDetailRow('Address', seller.address ?? 'N/A'),
              _buildDetailRow('Total Orders', seller.totalOrders ?? '0'),
              _buildDetailRow(
                'Total Earnings',
                '₹${seller.totalEarnings ?? '0'}',
              ),
              _buildDetailRow('Rating', '${seller.rating ?? '0'}/5'),
              _buildDetailRow(
                'Status',
                seller.isApproved == true ? 'Approved' : 'Pending',
              ),
              _buildDetailRow('Joined', seller.joinDate ?? 'N/A'),
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

  Future<void> _approveSeller(String sellerId) async {
    try {
      await _firestore.collection('sellers').doc(sellerId).update({
        'isApproved': true,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seller approved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _removeSeller(String sellerId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Seller'),
        content: const Text('Are you sure you want to remove this seller?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _firestore.collection('sellers').doc(sellerId).delete();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Seller removed successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
