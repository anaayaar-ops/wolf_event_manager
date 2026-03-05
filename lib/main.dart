import 'package:flutter/material.dart';

void main() => runApp(const WolfApp());

class WolfApp extends StatelessWidget {
  const WolfApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  // القائمة الآن فارغة تماماً ولن تعرض "فعالية 753729" أبداً بشكل تلقائي
  List<Map<String, String>> _dynamicEvents = [];
  final TextEditingController _textController = TextEditingController();

  // الدالة التي تحول النص الملصق إلى بيانات حقيقية وتعرضها فوراً
  void _updateUIWithNewData(String rawText) {
    final List<Map<String, String>> newResults = [];
    
    // هذا التعبير يبحث عن النمط المطبوع في سجلات GitHub الخاصة بك
    final RegExp regExp = RegExp(
      r"【\s*(.*?)\s*】.*?⏰ وقت البداية:\s*(.*?)\s*\n.*?🆔 ID:\s*(\d+)",
      dotAll: true,
    );

    final matches = regExp.allMatches(rawText);
    for (var m in matches) {
      newResults.add({
        'name': m.group(1) ?? 'فعالية جديدة',
        'time': m.group(2) ?? '00:00 AM',
        'id': m.group(3) ?? '',
      });
    }

    // هنا يتم تحديث الواجهة فوراً بعد التحليل
    setState(() {
      _dynamicEvents = newResults;
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
        // أضفت زر اللصق في الـ AppBar ليكون مستقلاً وواضحاً جداً
        actions: [
          IconButton(
            icon: const Icon(Icons.paste_rounded, color: Color(0xFF9E86FF), size: 30),
            onPressed: () => _showInputDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderSection(),
          
          const Divider(color: Colors.white24, indent: 20, endIndent: 20),

          // عرض الفعاليات الحقيقية فقط
          Expanded(
            child: _dynamicEvents.isEmpty
                ? const Center(
                    child: Text(
                      "القائمة فارغة\nاضغط على أيقونة اللصق البنفسجية فوق ↗️",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _dynamicEvents.length,
                    itemBuilder: (context, i) => _buildEventRow(_dynamicEvents[i]),
                  ),
          ),

          _buildBottomAction(),
        ],
      ),
    );
  }

  // نافذة لصق النص (Dialog)
  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text("أصق مخرجات JS المنسوخة"),
        content: TextField(
          controller: _textController,
          maxLines: 5,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            hintText: "انسخ النص من GitHub Logs وضعه هنا...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9E86FF)),
            onPressed: () {
              _updateUIWithNewData(_textController.text);
              Navigator.pop(ctx);
              _textController.clear();
            },
            child: const Text("تحديث الأسماء فوراً"),
          )
        ],
      ),
    );
  }

  // مخرجات الصف (نفس تصميمك الأصلي)
  Widget _buildEventRow(Map<String, String> ev) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${ev['id']} ${ev['name']}", 
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)
            )
          ),
          Text(
            ev['time']!, 
            style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)
          ),
          const SizedBox(width: 15),
          Checkbox(
            value: true, 
            onChanged: (v) {}, 
            activeColor: const Color(0xFF9E86FF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: _infoBox("Room ID", "9969")),
          const SizedBox(width: 10),
          Expanded(child: _infoBox("Date", "2026-03-05")),
        ],
      ),
    );
  }

  Widget _infoBox(String title, String val) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(val, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
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
