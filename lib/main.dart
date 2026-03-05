import 'package:flutter/material.dart';

void main() => runApp(const WolfApp());

class WolfApp extends StatelessWidget {
  const WolfApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF13211E)),
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
  // هذه القائمة ستخزن الفعاليات بعد تحليلها
  List<Map<String, String>> _events = [];
  final TextEditingController _inputController = TextEditingController();

  // دالة ذكية لتحويل النص المنسوخ من GitHub إلى قائمة منظمة
  void _parseAndShow(String rawText) {
    final List<Map<String, String>> parsed = [];
    // التعبير النمطي للبحث عن الاسم والوقت و الـ ID في نصك الأصلي
    final RegExp regExp = RegExp(
      r"【\s*(.*?)\s*】.*?وقت البداية:\s*(.*?)\s*\n.*?ID:\s*(\d+)",
      dotAll: true,
    );

    final matches = regExp.allMatches(rawText);
    for (var m in matches) {
      parsed.add({
        'name': m.group(1) ?? 'فعالية',
        'time': m.group(2) ?? '00:00 AM',
        'id': m.group(3) ?? '',
      });
    }

    setState(() {
      _events = parsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WOLF Event Manager'), centerTitle: true, elevation: 0, backgroundColor: Colors.transparent),
      body: Column(
        children: [
          _buildHeader(),
          
          // زر جديد للصق النتائج من GitHub
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.paste),
              label: const Text("لصق بيانات JS الحقيقية"),
              onPressed: () => _showImportDialog(),
            ),
          ),

          Expanded(
            child: _events.isEmpty 
              ? const Center(child: Text("أصق مخرجات JS لعرض الأسماء الحقيقية"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _events.length,
                  itemBuilder: (context, i) => _buildEventItem(_events[i]),
                ),
          ),
          
          _buildBottomButton(),
        ],
      ),
    );
  }

  // مخرجات تصميم البطاقة كما في صورك بالضبط
  Widget _buildEventItem(Map<String, String> ev) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Expanded(child: Text("${ev['id']} ${ev['name']}", style: const TextStyle(fontSize: 16))),
          Text(ev['time']!, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          const SizedBox(width: 15),
          Checkbox(value: true, onChanged: (v){}, activeColor: const Color(0xFF9E86FF)),
        ],
      ),
    );
  }

  // نافذة اللصق
  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("أصق نص الـ Console هنا"),
        content: TextField(controller: _inputController, maxLines: 5, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          ElevatedButton(onPressed: () {
            _parseAndShow(_inputController.text);
            Navigator.pop(ctx);
          }, child: const Text("تحليل وعرض"))
        ],
      ),
    );
  }

  Widget _buildHeader() { /* كود مربعات Room ID و Date كما في صورتك */ return const SizedBox(); }
  Widget _buildBottomButton() { /* كود زر إنهاء */ return const SizedBox(); }
}
