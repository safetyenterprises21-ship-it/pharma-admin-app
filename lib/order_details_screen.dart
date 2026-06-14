import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() =>
      _OrderDetailsScreenState();
}

class _OrderDetailsScreenState
    extends State<OrderDetailsScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final data = await supabase
          .from('order_items')
          .select()
          .eq(
            'order_number',
            widget.order['order_number'],
          );

      setState(() {
        items =
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

  Future<void> updateStatus(
      String status) async {
    await supabase
        .from('orders')
        .update({
      'status': status,
    }).eq(
      'order_number',
      widget.order['order_number'],
    );

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('Status updated: $status'),
        ),
      );

      Navigator.pop(context);
    }
  }

  Future<void> billItem(
    Map<String, dynamic> item) async {

  final controller =
      TextEditingController(
    text: item['quantity'].toString(),
  );

  final result =
      await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Enter Billed Qty',
        ),
        content: TextField(
          controller: controller,
          keyboardType:
              TextInputType.number,
          decoration:
              const InputDecoration(
            labelText: 'Billed Qty',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text(
              'Cancel',
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(
              context,
              controller.text,
            ),
            child: const Text(
              'Save',
            ),
          ),
        ],
      );
    },
  );

  if (result == null) return;

  final billedQty =
      int.tryParse(result) ?? 0;

  final orderedQty =
      item['quantity'] ?? 0;

  await supabase
      .from('order_items')
      .update({
    'billed_qty': billedQty,
    'billing_status':
        billedQty >= orderedQty
            ? 'Billed'
            : 'Short',
  })
      .eq('id', item['id']);

  await loadItems();

  if (mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
            Text('Billing Updated'),
      ),
    );
  }
}
  Color billingColor(String status) {
  switch (status) {
    case 'Billed':
      return Colors.green;

    case 'Short':
      return Colors.red;

    default:
      return Colors.orange;
  }
}

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          order['order_number'] ?? '',
        ),
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            "🏪 Shop: ${order['shop_name'] ?? ''}",
                          ),
                          const SizedBox(
                              height: 8),
                          Text(
                            "👤 Owner: ${order['owner_name'] ?? ''}",
                          ),
                          const SizedBox(
                              height: 8),
                          Text(
                            "📞 Mobile: ${order['mobile_number'] ?? ''}",
                          ),
                          const SizedBox(
                              height: 8),
                          Text(
                            "📦 Status: ${order['status'] ?? 'Pending'}",
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Medicines",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...items.map(
                    (item) => Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(12),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              item['product_name'] ??
                                  '',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(
                                height: 8),

                            Text(
                              "Ordered Qty: ${item['quantity'] ?? 0}",
                            ),

                            Text(
                              "Billed Qty: ${item['billed_qty'] ?? 0}",
                            ),

                            Text(
                              "Scheme: ${item['scheme'] ?? ''}",
                            ),

                            const SizedBox(
                                height: 10),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    billingColor(
                                  item['billing_status'] ??
                                      'Pending',
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                              ),
                              child: Text(
                                item['billing_status'] ??
                                    'Pending',
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

                            const SizedBox(
                                height: 10),

                            if (item['billing_status'] !=
                                'Billed')
                              ElevatedButton
                                  .icon(
                                onPressed: () {
                                  billItem(
  item,
);
                                },
                                icon:
                                    const Icon(
                                  Icons.check,
                                ),
                                label:
                                    const Text(
                                  'Bill Qty',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Update Order Status",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () =>
                        updateStatus(
                      'Processing',
                    ),
                    child: const Text(
                      'Processing',
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () =>
                        updateStatus(
                      'Billed',
                    ),
                    child: const Text(
                      'Billed',
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () =>
                        updateStatus(
                      'Delivered',
                    ),
                    child: const Text(
                      'Delivered',
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}