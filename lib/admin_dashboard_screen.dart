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

  Widget statusCard(
    String title,
    int count,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
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
        title: const Text(
          "Pharma Admin",
        ),
        centerTitle: true,
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

                  /// SUMMARY

                  Row(
                    children: [
                      statusCard(
                        'Pending',
                        countStatus(
                          'Pending',
                        ),
                        Colors.red,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      statusCard(
                        'Processing',
                        countStatus(
                          'Processing',
                        ),
                        Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    children: [
                      statusCard(
                        'Billed',
                        countStatus(
                          'Billed',
                        ),
                        Colors.blue,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      statusCard(
                        'Delivered',
                        countStatus(
                          'Delivered',
                        ),
                        Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  /// SEARCH

                  TextField(
                    controller:
                        searchController,
                    decoration:
                        InputDecoration(
                      hintText:
                          'Search Order / Shop / Mobile',
                      prefixIcon:
                          const Icon(
                        Icons.search,
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {
                        applyFilters();
                      });
                    },
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
                        elevation: 3,
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

                          leading:
                              CircleAvatar(
                            backgroundColor:
                                getStatusColor(
                              status,
                            ),
                            child: const Icon(
                              Icons.receipt,
                              color:
                                  Colors.white,
                            ),
                          ),

                          title: Text(
                            order[
                                    'order_number'] ??
                                '',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const SizedBox(
                                  height:
                                      6),

                              Text(
                                "🏪 ${order['shop_name'] ?? ''}",
                              ),

                              Text(
                                "👤 ${order['owner_name'] ?? ''}",
                              ),

                              Text(
                                "📞 ${order['mobile_number'] ?? ''}",
                              ),

                              const SizedBox(
                                  height:
                                      6),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      10,
                                  vertical: 4,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      getStatusColor(
                                    status,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),
                                ),
                                child: Text(
                                  status,
                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .white,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                            ],
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