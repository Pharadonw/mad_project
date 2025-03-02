import 'package:account/model/transactionItem.dart';
import 'package:account/provider/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditScreen extends StatefulWidget {
  final TransactionItem item;

  EditScreen({super.key, required this.item});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final formKey = GlobalKey<FormState>();
  final locationController = TextEditingController();
  final sportTypeController = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
    locationController.text = widget.item.title.split(' - ')[0];
    sportTypeController.text = widget.item.title.split(' - ').length > 1
        ? widget.item.title.split(' - ')[1]
        : '';

    // โหลดค่าเวลาถ้ามีข้อมูลอยู่
    if (widget.item.date != null) {
      startTime = TimeOfDay(
          hour: widget.item.date!.hour, minute: widget.item.date!.minute);
      endTime = TimeOfDay(
          hour: (widget.item.date!.hour + 1) % 24,
          minute: widget.item.date!.minute);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (startTime ?? TimeOfDay.now())
          : (endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange, // เปลี่ยนสีเป็นสีส้ม
        title: const Text('แก้ไขตารางฝึกซ้อม'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'สถานที่'),
                controller: locationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนสถานที่";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ประเภทกีฬา'),
                controller: sportTypeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาระบุประเภทกีฬา";
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectTime(context, true),
                      child: Text(startTime == null
                          ? 'เลือกเวลาเริ่ม'
                          : 'เริ่ม: ${startTime!.format(context)}'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectTime(context, false),
                      child: Text(endTime == null
                          ? 'เลือกเวลาสิ้นสุด'
                          : 'สิ้นสุด: ${endTime!.format(context)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange), // เปลี่ยนสีปุ่มเป็นสีส้ม
                onPressed: () {
                  if (formKey.currentState!.validate() &&
                      startTime != null &&
                      endTime != null) {
                    var provider = Provider.of<TransactionProvider>(context,
                        listen: false);

                    TransactionItem updatedItem = TransactionItem(
                      keyID: widget.item.keyID,
                      title:
                          '${locationController.text} - ${sportTypeController.text}',
                      amount: 0.0, // No numerical input for amount
                      date: DateTime(
                        widget.item.date?.year ?? DateTime.now().year,
                        widget.item.date?.month ?? DateTime.now().month,
                        widget.item.date?.day ?? DateTime.now().day,
                        startTime!.hour,
                        startTime!.minute,
                      ),
                    );

                    provider.updateTransaction(updatedItem);
                    Navigator.pop(context);
                  }
                },
                child: const Text('บันทึกการแก้ไข',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
