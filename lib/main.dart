import 'package:flutter/material.dart';

void main() => runApp(WolfApp());

class WolfApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D3D33), // لون الخلفية من صورتك
      ),
      home: EventScreen(),
    );
  }
}

class EventItem {
  String id;
  TimeOfDay time;
  bool isSelected;
  EventItem({required this.id, required this.time, this.isSelected = true});
}

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  // حقول قابلة للتعديل
  TextEditingController roomController = TextEditingController(text: "9969");
  TextEditingController dateController = TextEditingController(text: "12/3/2026");

  List<EventItem> events = [
    EventItem(id: "753729", time: TimeOfDay(hour: 0, minute: 0)),
    EventItem(id: "753730", time: TimeOfDay(hour: 0, minute: 45)),
    EventItem(id: "753731", time: TimeOfDay(hour: 1, minute: 30)),
    EventItem(id: "753732", time: TimeOfDay(hour: 2, minute: 15)),
    EventItem(id: "753733", time: TimeOfDay(hour: 3, minute: 00)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // الهيدر: حقول إدخال الروم والتاريخ
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(child: _buildInput("عضوية الروم", roomController)),
                  SizedBox(width: 20),
                  Expanded(child: _buildInput("التاريخ", dateController)),
                ],
              ),
            ),
            // قائمة الفعاليات
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    activeColor: Colors.tealAccent,
                    title: Row(
                      children: [
                        Text("${events[index].id} تبدأ ", style: TextStyle(fontSize: 16)),
                        InkWell(
                          onTap: () => _selectTime(index),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(5)),
                            child: Text(
                              events[index].time.format(context),
                              style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    value: events[index].isSelected,
                    onChanged: (val) => setState(() => events[index].isSelected = val!),
                  );
                },
              ),
            ),
            // الزر النهائي
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF0D3D33),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => _generateSummary(),
                child: Text("مراجعة البيانات (نص)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 14)),
        TextField(
          controller: controller,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          decoration: InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
        ),
      ],
    );
  }

  Future<void> _selectTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: events[index].time,
    );
    if (picked != null) setState(() => events[index].time = picked);
  }

  void _generateSummary() {
    String summary = "تقرير الفعاليات:\n";
    summary += "الروم: ${roomController.text}\n";
    summary += "التاريخ: ${dateController.text}\n";
    summary += "-------------------\n";
    
    for (var e in events.where((element) => element.isSelected)) {
      summary += "الفعالية: ${e.id} | الوقت: ${e.time.format(context)}\n";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تأكيد البيانات"),
        content: SelectableText(summary), // يسمح لك بنسخ النص
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("إغلاق"))
        ],
      ),
    );
  }
}
