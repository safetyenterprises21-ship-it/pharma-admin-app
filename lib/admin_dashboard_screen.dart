import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'order_details_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> filteredOrders = [];

  bool loading = true;

  String selectedStatus = 'All';

  final searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      setState(() {
        loading = true;
      });

      final data = await supabase
          .from('orders')
          .select()
          .order(
            'created_at',
            ascending: false,
          );

      orders =
          List<Map<String, dynamic>>.from(data);

      applyFilters();

      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  void applyFilters() {
    List<Map<String, dynamic>> temp =
        List.from(orders);

    if (selectedStatus != 'All') {
      temp = temp.where((order) {
        return order['status'] ==
            selectedStatus;
      }).toList();
    }

    final query =
        searchController.text.toLowerCase();

    if (query.isNotEmpty) {
      temp = temp.where((order) {
        final orderNo =
            order['order_number']
                    ?.toString()
                    .toLowerCase() ??
                '';

        final shop =
            order['shop_name']
                    ?.toString()
                    .toLowerCase() ??
                '';

        final mobile =
            order['mobile_number']
                    ?.toString()
                    .toLowerCase() ??
                '';

        return orderNo.contains(query) ||
            shop.contains(query) ||
            mobile.contains(query);
      }).toList();
    }

    filteredOrders = temp;
  }

  int countStatus(String status) {
    return orders
        .where(
          (e) => e['status'] == status,
        )
        .length;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Processing':
        return Colors.orange;

      case 'Billed':
        return Colors.blue;

      case 'Delivered':
        return Colors.green;

      default:
        return Colors.red;
    }
  }

  Widget statusChip(String status) {
    final selected =
        selectedStatus == status;

    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),
      child: ChoiceChip(
        label: Text(status),
        selected: selected,
        onSelected: (_) {
          setState(() {
            selectedStatus = status;
            applyFilters();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FA),

    appBar: AppBar(
  elevation: 0,
  backgroundColor: const Color(0xFF1E293B),

  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Safety Enterprises",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      Text(
        "${orders.length} Orders",
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
    ],
  ),

  actions: [
    Padding(
      padding: const EdgeInsets.only(
        right: 16,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Text(
            "${countStatus('Pending')} Pending",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  ],
),

      floatingActionButton:
          FloatingActionButton(
        onPressed: loadOrders,
        child: const Icon(
          Icons.refresh,
        ),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadOrders,
              child: ListView(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                children: [

                  /// SEARCH
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius:
        BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: TextField(
    controller: searchController,
    decoration: InputDecoration(
      hintText:
          "Search shop, mobile or order",
      prefixIcon: const Icon(
        Icons.search,
        color: Color(0xFF1E293B),
      ),
      border: InputBorder.none,
      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 16,
      ),
    ),
    onChanged: (_) {
      setState(() {
        applyFilters();
      });
    },
  ),
),

                  const SizedBox(
                    height: 16,
                  ),

                  /// FILTERS

                  SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal,
                    child: Row(
                      children: [
                        statusChip(
                          'All',
                        ),
                        statusChip(
                          'Pending',
                        ),
                        statusChip(
                          'Processing',
                        ),
                        statusChip(
                          'Billed',
                        ),
                        statusChip(
                          'Delivered',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  /// ORDERS

                  ...filteredOrders.map(
                    (order) {
                      final status =
                          order['status']
                                  ?.toString() ??
                              'Pending';

                      return Card(
                        elevation: 5,
                        shadowColor: Colors.black12,
                        margin:
                            const EdgeInsets
                                .only(
                          bottom: 12,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets
                                  .all(12),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailsScreen(
                                  order: order,
                                ),
                              ),
                            );
                          },

                          leading: Container(
  width: 50,
  height: 50,
  decoration: BoxDecoration(
    color: getStatusColor(status)
        .withOpacity(0.15),
    borderRadius:
        BorderRadius.circular(12),
  ),
  child: Icon(
    Icons.local_shipping_outlined,
    color: getStatusColor(status),
  ),
),

  title: Row(
  children: [
    Expanded(
      child: Text(
        order['shop_name'] ?? 'Medical Store',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    ),

    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: getStatusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    ),
  ],
),

  subtitle: Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Text(
        "#${order['order_number']
            .toString()
            .substring(
              order['order_number']
                      .toString()
                      .length -
                  4,
            )}",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 6),

      Text(
        "📞 ${order['mobile_number'] ?? 'N/A'}",
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 6),

Text(
  order['created_at'] != null
      ? order['created_at']
          .toString()
          .substring(0, 10)
      : '',
  style: const TextStyle(
    fontSize: 12,
    color: Colors.grey,
  ),
),
    ],
  ),
),

                          trailing:
                              const Icon(
                            Icons
                                .arrow_forward_ios,
                            size: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}