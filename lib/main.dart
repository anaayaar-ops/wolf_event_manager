import 'package:flutter/material.dart';

void main() => runApp(const WolfApp());

class WolfApp extends StatelessWidget {
  const WolfApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF13211E), // لون خلفية تطبيقك الأصلي
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
  // القائمة فارغة تماماً الآن لمنع تكرار الواجهة القديمة
  List<Map<String, String>> _dynamicEvents = [];
  final TextEditingController _pasteController = TextEditingController();

  // دالة ذكية لتحليل النص المنسوخ من سجلات GitHub الناجحة
  void _updateWithNewData(String rawText) {
    final List<Map<String, String>> newResults = [];
    
    // هذا التعبير يبحث عن النمط المنسوخ: 【 الاسم 】 والوقت والـ ID
    final RegExp regExp = RegExp(
      r"【\s*(.*?)\s*】.*?⏰ وقت البداية:\s*(.*?)\s*\n.*?🆔 ID:\s*(\d+)",
      dotAll: true,
    );

    final matches = regExp.allMatches(rawText);
    for (var m in matches) {
      newResults.add({
        'name': m.group(1) ?? 'فعالية',
        'time': m.group(2) ?? '00:00 AM',
        'id': m.group(3) ?? '',
      });
    }

    // تحديث الواجهة فوراً بالبيانات الجديدة
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
        actions: [
          // أيقونة اللصق البنفسجية واضحة في الأعلى
          IconButton(
            icon: const Icon(Icons.paste_rounded, color: Color(0xFF9E86FF), size: 28),
            onPressed: () => _showPasteDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          const Divider(color: Colors.white12, height: 1),
          
          Expanded(
            child: _dynamicEvents.isEmpty
                ? const Center(
                    child: Text(
                      "القائمة فارغة\nأصق مخرجات JS من الأيقونة فوق ↗️",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: _dynamicEvents.length,
                    itemBuilder: (context, i) => _buildEventRow(_dynamicEvents[i]),
                  ),
          ),
          
          _buildBottomButton(),
        ],
      ),
    );
  }

  // نافذة لصق البيانات
  void _showPasteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("لصق بيانات الفعاليات"),
        content: TextField(
          controller: _pasteController,
          maxLines: 5,
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            hintText: "أصق النص من GitHub Logs هنا...",
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
              _updateWithNewData(_pasteController.text);
              Navigator.pop(ctx);
              _pasteController.clear();
            },
            child: const Text("تحديث الأسماء"),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: _infoBox("Room ID", "18432094")),
          const SizedBox(width: 10),
          Expanded(child: _infoBox("Date", "2026-03-08")),
        ],
      ),
    );
  }

  Widget _infoBox(String t, String v) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white10),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(v, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _buildEventRow(Map<String, String> ev) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${ev['id']} ${ev['name']}", 
              style: const TextStyle(fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            ev['time']!, 
            style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 15),
          Checkbox(
            value: true, 
            onChanged: (v){}, 
            activeColor: const Color(0xFF9E86FF),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() => Padding(
    padding: const EdgeInsets.all(20),
    child: SizedBox(
      width: double.infinity, 
      height: 50, 
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, 
          foregroundColor: Colors.black, 
          shape: const StadiumBorder(),
        ),
        onPressed: () {}, 
        child: const Text("إنهاء", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ),
  );
}
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
