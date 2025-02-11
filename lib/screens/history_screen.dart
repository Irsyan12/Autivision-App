import 'package:autivision_v2/screens/detail_history.dart';
import 'package:autivision_v2/widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'package:autivision_v2/services/history_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:autivision_v2/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  late List<bool> selected;
  late List<Map<String, dynamic>> historyData;
  bool selectionMode = false;

  @override
  void initState() {
    super.initState();
    selected = [];
    historyData = [];
  }

  void onLongPress(int index) {
    setState(() {
      selectionMode = true;
      selected[index] = !selected[index];
    });
  }

  void onTap(int index) {
  if (selectionMode) {
    setState(() {
      selected[index] = !selected[index];
    });
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailHistoryScreen(historyItem: historyData[index]),
      ),
    );
  }
}


  void deleteSelectedItems(String userId) async {
    for (int i = selected.length - 1; i >= 0; i--) {
      if (selected[i]) {
        await _historyService.deleteHistoryItem(
          historyData[i]['id'],
          userId,
          historyData[i]['imageUrl'],
        );
        historyData.removeAt(i);
        selected.removeAt(i);
      }
    }
    setState(() {
      if (selected.isEmpty) {
        selectionMode = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Riwayat',
        actions: [
          if (selectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white, size: 30),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Hapus Riwayat Yang Dipilih'),
                      content: const Text(
                          'Apakah Anda yakin ingin menghapus item yang dipilih?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Delete'),
                          onPressed: () {
                            deleteSelectedItems(userId!);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyService.loadHistory(userId: userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return const Center(child: Text('Error loading history'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('No history available');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.network(
                    'https://firebasestorage.googleapis.com/v0/b/autivision-c1daf.appspot.com/o/no_history_data.svg?alt=media&token=8baac719-0ac5-4128-aaef-3349a2737861',
                    width: 200,
                    height: 200,
                  ),
                  const Text('Tidak ada riwayat data'),
                ],
              ),
            );
          } else {
            historyData = snapshot.data!;
            if (selected.isEmpty) {
              selected =
                  List<bool>.generate(historyData.length, (index) => false);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                final item = historyData[index];
                return GestureDetector(
                  onLongPress: () => onLongPress(index),
                  onTap: () => onTap(index),
                  child: HistoryItem(
                    imageUrl: item['imageUrl']!,
                    status: item['classification']!,
                    date: item['timestamp'].toDate(),
                    confidence: item['confidence'],
                    isSelected: selected[index],
                    onSelect: (isSelected) {
                      setState(() {
                        selected[index] = isSelected;
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class HistoryItem extends StatefulWidget {
  final String imageUrl;
  final String status;
  final DateTime date;
  final double confidence;
  final bool isSelected;
  final ValueChanged<bool> onSelect;

  const HistoryItem({super.key, 
    required this.imageUrl,
    required this.status,
    required this.date,
    required this.confidence,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  _HistoryItemState createState() => _HistoryItemState();
}

class _HistoryItemState extends State<HistoryItem> {
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
  }

  void toggleSelection() {
    setState(() {
      isSelected = !isSelected;
      widget.onSelect(isSelected);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    if (widget.status == 'Autistic') {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
    } else if (widget.status == 'Non Autistic') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
    }

    final dateFormat = DateFormat('EEEE, dd/MM/yyyy', 'id');
    final formattedDate = dateFormat.format(widget.date);

    final formattedConfidence = '${widget.confidence.toStringAsFixed(2)}%';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black38.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/loading.gif',
                    image: widget.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: statusColor,
                  radius: 10,
                  child: Icon(
                    statusIcon,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Confidence: $formattedConfidence',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
