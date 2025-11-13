import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';

/// Orders list screen
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch orders on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrderProvider>().fetchOrders(refresh: true);
            },
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.errorMessage != null &&
              orderProvider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(orderProvider.errorMessage!),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      orderProvider.fetchOrders(refresh: true);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (orderProvider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await orderProvider.fetchOrders(refresh: true);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderProvider.orders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.orders[index];
                return OrderCard(
                  orderId: order.id,
                  customerName: order.customerName ?? 'Guest',
                  status: order.status,
                  totalAmount: order.totalAmount,
                  itemCount: order.items.length,
                  createdAt: order.createdAt,
                  onTap: () {
                    // TODO: Navigate to order detail screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Order #${order.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Order card widget
class OrderCard extends StatelessWidget {
  final int orderId;
  final String customerName;
  final OrderStatus status;
  final double totalAmount;
  final int itemCount;
  final DateTime createdAt;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.status,
    required this.totalAmount,
    required this.itemCount,
    required this.createdAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #$orderId',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  _buildStatusChip(context, status),
                ],
              ),
              const SizedBox(height: 12),

              // Customer name
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    customerName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items count
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '$itemCount item${itemCount > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Time
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy - HH:mm').format(createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Total amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '\$${totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, OrderStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        break;
      case OrderStatus.confirmed:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        break;
      case OrderStatus.preparing:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade900;
        break;
      case OrderStatus.ready:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        break;
      case OrderStatus.delivering:
        backgroundColor = Colors.indigo.shade100;
        textColor = Colors.indigo.shade900;
        break;
      case OrderStatus.delivered:
        backgroundColor = AppTheme.successColor.withOpacity(0.2);
        textColor = AppTheme.successColor;
        break;
      case OrderStatus.cancelled:
        backgroundColor = AppTheme.errorColor.withOpacity(0.2);
        textColor = AppTheme.errorColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.value,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
