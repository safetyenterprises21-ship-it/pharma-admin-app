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

  Future<void> billItem(
      Map<String, dynamic> item) async {
    final controller =
        TextEditingController(
      text:
          (item['billed_qty'] ?? 0).toString(),
    );

    final result =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text("Enter Billed Qty"),
          content: TextField(
            controller: controller,
            keyboardType:
                TextInputType.number,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text(
                "Cancel",
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                controller.text,
              ),
              child:
                  const Text("Save"),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    final billedQty =
    int.tryParse(result) ?? 0;
print('ITEM ID = ${item['id']}');
print('ORDER ID = ${item['order_id']}');
print('QTY = $billedQty');
print('FULL ITEM:');
print(item);

print('ITEM ID = ${item['id']}');

final response = await supabase
    .from('order_items')
    .update({
      'billed_qty': billedQty,
    })
    .eq('id', item['id'])
    .select();

print('UPDATED ROW:');
print(response);
print('UPDATED ROW:');
print(response);

await loadItems();

    await loadItems();
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
              Text("Status: $status"),
        ),
      );

      Navigator.pop(context);
    }
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

                  /// SHOP CARD

                  Card(
                    elevation: 2,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(14),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                              12),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            order['shop_name'] ??
                                '',
                            style:
                                const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                              height: 6),

                          Text(
                            "📞 ${order['mobile_number'] ?? ''}",
                          ),

                          const SizedBox(
                              height: 10),

                          Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(
    vertical: 10,
  ),
  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: getStatusColor(
      order['status'] ?? 'Pending',
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    order['status'] ?? 'Pending',
    style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    ),
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
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// MEDICINE LIST

                  ...items.map(
                    (item) => Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 8,
                      ),
                      elevation: 1,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                                8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.medication,
                                  size: 18,
                                  color:
                                      Colors.blue,
                                ),

                                const SizedBox(
                                    width: 8),

                                Expanded(
                                  child: Text(
                                    item['product_name'] ??
                                        '',
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          14,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 8),

                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      vertical:
                                          8,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color: Colors
                                          .orange
                                          .shade50,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        10,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Ordered",
                                          style:
                                              TextStyle(
                                            fontSize:
                                                11,
                                          ),
                                        ),
                                        Text(
                                          "${item['quantity'] ?? 0}",
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                16,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                    width: 8),

                                Expanded(
                                  child:
                                      Container(
                                  
                                    child:
                                        Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        vertical:
                                            8,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color: Colors
                                            .green
                                            .shade50,
                                        borderRadius:
                                            BorderRadius.circular(
                                          10,
                                        ),
                                      ),
                                      child:
                                          Column(
                                        children: [
                                          const Text(
                                            "Billed",
                                            style:
                                                TextStyle(
                                              fontSize:
                                                  11,
                                            ),
                                          ),
                                         SizedBox(
  width: 50,
  child: TextFormField(
    initialValue:
        "${item['billed_qty'] ?? 0}",
    keyboardType:
        TextInputType.number,
    textAlign: TextAlign.center,
    decoration:
        const InputDecoration(
      border: InputBorder.none,
    ),
    onChanged: (value) async {
  final billedQty =
      int.tryParse(value) ?? 0;

  await supabase
      .from('order_items')
      .update({
    'billed_qty': billedQty,
  })
      .eq(
    'id',
    item['id'],
  );
},
  ),
),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Update Status",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          updateStatus(
                        'Processing',
                      ),
                      child: const Text(
                        'Processing',
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          updateStatus(
                        'Billed',
                      ),
                      child: const Text(
                        'Billed',
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          updateStatus(
                        'Delivered',
                      ),
                      child: const Text(
                        'Delivered',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}