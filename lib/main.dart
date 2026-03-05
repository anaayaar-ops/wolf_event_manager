import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF14302C), // اللون الأخضر الداكن المفضل لك
        primaryColor: Colors.tealAccent,
      ),
      home: WolfEventPro(),
    ));

class EventItem {
  String id;
  TimeOfDay time;
  bool isSelected;

  EventItem({required this.id, required this.time, this.isSelected = true});
}

class WolfEventPro extends StatefulWidget {
  @override
  _WolfEventProState createState() => _WolfEventProState();
}

class _WolfEventProState extends State<WolfEventPro> {
  // استخدام رقم الروم الافتراضي من مشروعك السابق
  final TextEditingController roomController = TextEditingController(text: "18432094");
  DateTime selectedDate = DateTime.now();
  List<EventItem> events = [];
  bool isLoading = false;

  // دالة الاتصال بكود الـ JS (الـ API) الخاص بك
  Future<void> fetchFromJS() async {
    if (roomController.text.isEmpty) return;

    setState(() => isLoading = true);
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    try {
      // استبدل هذا الرابط برابط السيرفر الذي يشغل كود الـ JS الخاص بك
      final url = Uri.parse('https://your-js-server.com/get-events?room=${roomController.text}&date=$formattedDate');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        setState(() {
          events = data.map((e) => EventItem(
            id: e['id'].toString(),
            time: TimeOfDay(hour: int.parse(e['hour']), minute: int.parse(e['minute'])),
          )).toList();
        });
        _showSnackBar("تم جلب ${events.length} فعالية بنجاح");
      } else {
        _showSnackBar("فشل الجلب: تأكد من تشغيل كود الـ JS");
      }
    } catch (e) {
      _showSnackBar("خطأ في الاتصال بالسيرفر");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // اختيار التاريخ من التقويم
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // تعديل الوقت يدويًا لكل فعالية
  Future<void> _editTime(int index) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: events[index].time,
    );
    if (picked != null) setState(() => events[index].time = picked);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WOLF Event Manager"),
        centerTitle: true,
        actions: [if (isLoading) Center(child: Padding(padding: EdgeInsets.all(15), child: CircularProgressIndicator(strokeWidth: 2)) )],
      ),
      body: Column(
        children: [
          // لوحة التحكم العلوية
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: TextField(controller: roomController, decoration: InputDecoration(labelText: "Room ID", border: OutlineInputBorder()))),
                    SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: InputDecoration(labelText: "Date", border: OutlineInputBorder()),
                          child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : fetchFromJS,
                  icon: Icon(Icons.refresh),
                  label: Text("جلب الفعاليات عبر الـ JS"),
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 45)),
                )
              ],
            ),
          ),
          
          // قائمة الفعاليات
          Expanded(
            child: events.isEmpty 
              ? Center(child: Text("اضغط جلب لسحب البيانات من البوت"))
              : ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (c, i) => CheckboxListTile(
                    activeColor: Colors.tealAccent,
                    title: Row(
                      children: [
                        Text("ID: ${events[i].id}"),
                        Spacer(),
                        TextButton(
                          style: TextButton.styleFrom(backgroundColor: Colors.black26),
                          onPressed: () => _editTime(i),
                          child: Text(events[i].time.format(context), style: TextStyle(color: Colors.yellowAccent)),
                        ),
                      ],
                    ),
                    value: events[i].isSelected,
                    onChanged: (v) => setState(() => events[i].isSelected = v!),
                  ),
                ),
          ),

          // زر الإنهاء والنسخ
          if (events.isNotEmpty) Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                String report = "تقرير فعاليات الروم: ${roomController.text}\nالتاريخ: ${DateFormat('yyyy-MM-dd').format(selectedDate)}\n";
                report += "-------------------\n";
                report += events.where((e) => e.isSelected).map((e) => "ID: ${e.id} | الوقت: ${e.time.format(context)}").join("\n");
                
                Clipboard.setData(ClipboardData(text: report)); // نسخ تلقائي
                _showSnackBar("تم نسخ الجدول للحافظة!");
                
                showDialog(context: context, builder: (c) => AlertDialog(title: Text("التقرير النهائي"), content: SelectableText(report)));
              },
              child: Text("تأكيد ونسخ الجدول", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }
}
