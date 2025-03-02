import 'package:account/model/transactionItem.dart';
import 'package:account/provider/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final formKey = GlobalKey<FormState>();
  final locationController = TextEditingController();
  final sportTypeController = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('เพิ่มตารางฝึกซ้อม'),
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
                onPressed: () {
                  if (formKey.currentState!.validate() &&
                      startTime != null &&
                      endTime != null) {
                    var provider = Provider.of<TransactionProvider>(context,
                        listen: false);

                    TransactionItem item = TransactionItem(
                      title:
                          '${locationController.text} - ${sportTypeController.text}',
                      amount: 0.0, // No numerical input for amount in this case
                      date: DateTime.now(),
                    );

                    provider.addTransaction(item);
                    Navigator.pop(context);
                  }
                },
                child: const Text('เพิ่มตารางฝึกซ้อม'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
