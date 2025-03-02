import 'package:account/model/transactionItem.dart';
import 'package:account/provider/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'formScreen.dart';
import 'package:account/editScreen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) {
            return TransactionProvider();
          })
        ],
        child: MaterialApp(
          title: 'Sports Training Camp',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 207, 117, 57)),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Sports Training Camp'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    TransactionProvider provider =
        Provider.of<TransactionProvider>(context, listen: false);
    provider.initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FormScreen();
                }));
              },
            ),
          ],
        ),
        body: Consumer(
          builder: (context, TransactionProvider provider, Widget? child) {
            int itemCount = provider.transactions.length;
            if (itemCount == 0) {
              return const Center(
                child: Text(
                  'ไม่พบตารางการฝึกซ้อม',
                  style: TextStyle(fontSize: 30),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: itemCount,
                  itemBuilder: (context, int index) {
                    TransactionItem data = provider.transactions[index];
                    return Dismissible(
                      key: Key(data.keyID.toString()),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        provider.deleteTransaction(data);
                      },
                      background: Container(
                        color: const Color.fromARGB(255, 206, 184, 63),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.edit,
                            color: Color.fromARGB(255, 229, 228, 231)),
                      ),
                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: ListTile(
                            title: Text(data.title),
                            subtitle: Text(
                                'ช่วงเวลาลงตาราง: ${data.date?.hour}:${data.date?.minute} น.',
                                style: const TextStyle(fontSize: 14)),
                            leading: CircleAvatar(
                              child: const Icon(Icons.access_time),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('ยืนยันการลบ'),
                                      content: const Text(
                                          'คุณต้องการลบรายการใช่หรือไม่?'),
                                      actions: [
                                        TextButton(
                                          child: const Text('ยกเลิก'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('ลบรายการ'),
                                          onPressed: () {
                                            provider.deleteTransaction(data);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return EditScreen(item: data);
                              }));
                            }),
                      ),
                    );
                  });
            }
          },
        ));
  }
}
