import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _getDashboardStats();
  }

  Future<Map<String, dynamic>> _getDashboardStats() async {
    try {
      print('=== Starting Dashboard Stats Fetch ===');

      final currentUser = FirebaseAuth.instance.currentUser;
      print('Current User: ${currentUser?.email}');
      print('User UID: ${currentUser?.uid}');

      int totalOrders = 0;
      double totalCommission = 0;
      int totalSellers = 0;
      int pendingOrders = 0;

      // Get total orders
      try {
        print('Fetching orders...');
        final ordersSnapshot =
            await FirebaseFirestore.instance.collection('orders').get();
        totalOrders = ordersSnapshot.docs.length;
        print('Orders fetched: $totalOrders');

        for (var doc in ordersSnapshot.docs) {
          try {
            final commission = double.tryParse(
                    doc.get('companyCommission')?.toString() ?? '0') ??
                0;
            totalCommission += commission;
          } catch (e) {
            //
          }
        }
      } catch (e) {
        print('Error fetching orders: $e');
      }

      // Get total sellers
      try {
        print('Fetching sellers...');
        final sellersSnapshot =
            await FirebaseFirestore.instance.collection('sellers').get();
        totalSellers = sellersSnapshot.docs.length;
        print('Sellers fetched: $totalSellers');
      } catch (e) {
        print('Error fetching sellers: $e');
      }

      // Get pending orders
      try {
        print('Fetching pending orders...');
        final allOrders =
            await FirebaseFirestore.instance.collection('orders').get();
        pendingOrders = allOrders.docs.where((doc) {
          return doc.get('status') == 'pending';
        }).length;
        print('Pending orders: $pendingOrders');
      } catch (e) {
        print('Error fetching pending orders: $e');
      }

      print('=== Stats Fetch Complete ===');

      return {
        'totalOrders': totalOrders,
        'totalCommission': totalCommission,
        'totalSellers': totalSellers,
        'pendingOrders': pendingOrders,
      };
    } catch (e) {
      print('Dashboard Stats Error: $e');
      return {
        'totalOrders': 0,
        'totalCommission': 0.0,
        'totalSellers': 0,
        'pendingOrders': 0,
      };
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF6200EA),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: _buildDashboardHome(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6200EA),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Sellers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Commission',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHome() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6200EA), Color(0xFF3700B3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to Admin Portal',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage orders, sellers, and commissions',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User: ${FirebaseAuth.instance.currentUser?.email ?? "Unknown"}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                print('=== FutureBuilder Debug ===');
                print('Connection State: ${snapshot.connectionState}');
                print('Has Data: ${snapshot.hasData}');
                print('Has Error: ${snapshot.hasError}');
                print('Error: ${snapshot.error}');
                print('Data: ${snapshot.data}');

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('ERROR IN SNAPSHOT: ${snapshot.error}');
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final stats = snapshot.data ??
                    {
                      'totalOrders': 0,
                      'totalCommission': 0.0,
                      'totalSellers': 0,
                      'pendingOrders': 0,
                    };

                print('Using stats: $stats');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Stats',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(
                          title: 'Total Orders',
                          value: '${stats['totalOrders']}',
                          icon: Icons.shopping_cart,
                        ),
                        _buildStatCard(
                          title: 'Commission',
                          value:
                              '₹${(stats['totalCommission'] as num).toStringAsFixed(2)}',
                          icon: Icons.trending_up,
                        ),
                        _buildStatCard(
                          title: 'Sellers',
                          value: '${stats['totalSellers']}',
                          icon: Icons.store,
                        ),
                        _buildStatCard(
                          title: 'Pending',
                          value: '${stats['pendingOrders']}',
                          icon: Icons.pending_actions,
                        ),
                      ],
                    ),
                  ],
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF6200EA), size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
