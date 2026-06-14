import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'order_details_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() =>
      _AdminOrdersScreenState();
}

class _AdminOrdersScreenState
    extends State<AdminOrdersScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> orders = [];
  bool loading = true;

  List<Map<String, dynamic>> filteredOrders = [];

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
          .order('created_at', ascending: false);

      setState(() {
  orders =
      List<Map<String, dynamic>>.from(data);

  filteredOrders =
      List<Map<String, dynamic>>.from(data);

  loading = false;
});
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;

      case 'Processing':
        return Colors.orange;

      case 'Billed':
        return Colors.blue;

      case 'Delivered':
        return Colors.purple;

      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'All Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : orders.isEmpty
              ? const Center(
                  child: Text(
                    'No Orders Found',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadOrders,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.all(
                      12,
                    ),
                    itemCount: orders.length,
                    itemBuilder:
                        (context, index) {
                      final order =
                          orders[index];

                      final status =
                          order['status']
                                  ?.toString() ??
                              'Pending';

                      return Card(
                        elevation: 4,
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
                            radius: 25,
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
                            order['order_number']
                                    ?.toString() ??
                                '',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize: 16,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const SizedBox(
                                height: 6,
                              ),

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
                                height: 8,
                              ),

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
                ),
    );
  }
}