import 'package:flutter/material.dart';

void main() => runApp(const WolfApp());

class WolfApp extends StatelessWidget {
  const WolfApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF13211E), // نفس لون خلفية صورك
      ),
      home: const EventManagerScreen(),
    );
  }
}

class EventManagerScreen extends StatefulWidget {
  const EventManagerScreen({super.key});
  @override
  State<EventManagerScreen> createState() => _EventManagerScreenState();
}

class _EventManagerScreenState extends State<EventManagerScreen> {
  // القائمة التي ستحتوي على الأسماء الحقيقية
  List<Map<String, String>> _realEvents = [];
  final TextEditingController _textController = TextEditingController();

  // هذه هي الدالة التي ستحول نص GitHub إلى أسماء حقيقية
  void _processRawText(String text) {
    final List<Map<String, String>> results = [];
    final RegExp regExp = RegExp(
      r"【\s*(.*?)\s*】.*?⏰ وقت البداية:\s*(.*?)\s*\n.*?🆔 ID:\s*(\d+)",
      dotAll: true,
    );

    final matches = regExp.allMatches(text);
    for (var m in matches) {
      results.add({
        'name': m.group(1) ?? 'فعالية',
        'time': m.group(2) ?? '00:00 AM',
        'id': m.group(3) ?? '',
      });
    }

    setState(() {
      _realEvents = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WOLF Event Manager'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. زر اللصق (وضعتُه هنا في البداية ليكون واضحاً جداً)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.content_paste),
              label: const Text("اضغط هنا للصق مخرجات JS"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9E86FF), // اللون البنفسجي في تطبيقك
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => _showInputDialog(),
            ),
          ),

          // 2. مربعات المعلومات (Room ID & Date)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(child: _headerBox("Room ID", "9969")),
                const SizedBox(width: 10),
                Expanded(child: _headerBox("Date", "2026-03-05")),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. عرض الفعاليات (الحقيقية إذا وُجدت، أو رسالة تنبيه)
          Expanded(
            child: _realEvents.isEmpty
                ? const Center(child: Text("لا توجد بيانات.. اضغط على الزر البنفسجي بالأعلى"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _realEvents.length,
                    itemBuilder: (context, i) => _eventTile(_realEvents[i]),
                  ),
          ),

          // 4. زر الإنهاء السفلي
          _bottomButton(),
        ],
      ),
    );
  }

  // نافذة الإدخال
  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("أصق مخرجات JS هنا"),
        content: TextField(
          controller: _textController,
          maxLines: 5,
          decoration: const InputDecoration(hintText: "01- 【 اسم الفعالية 】 ..."),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _processRawText(_textController.text);
              Navigator.pop(ctx);
            },
            child: const Text("تحديث الأسماء الآن"),
          )
        ],
      ),
    );
  }

  Widget _headerBox(String label, String val) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(val, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _eventTile(Map<String, String> ev) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Expanded(child: Text("${ev['id']} ${ev['name']}", style: const TextStyle(fontSize: 16))),
          Text(ev['time']!, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          const SizedBox(width: 15),
          Checkbox(value: true, onChanged: (v) {}, activeColor: const Color(0xFF9E86FF)),
        ],
      ),
    );
  }

  Widget _bottomButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder()),
          onPressed: () {},
          child: const Text("إنهاء", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
