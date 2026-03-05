import 'package:flutter/material.dart';

void main() {
  runApp(const WolfManagerApp());
}

class WolfManagerApp extends StatelessWidget {
  const WolfManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF13211E), // لون خلفية تطبيقك الأصلي
        primaryColor: const Color(0xFF9E86FF),
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
  // القائمة التي ستحمل البيانات الحقيقية
  List<Map<String, String>> _events = [];
  final TextEditingController _importController = TextEditingController();

  // الدالة السحرية التي تحلل النص القادم من GitHub/JS
  void _parseAndShowEvents(String rawText) {
    final List<Map<String, String>> parsedList = [];
    
    // التعبير النمطي للبحث عن الاسم بين 【 】 والوقت بعد ⏰ والـ ID بعد 🆔
    final RegExp regExp = RegExp(
      r"【\s*(.*?)\s*】.*?⏰ وقت البداية:\s*(.*?)\s*\n.*?🆔 ID:\s*(\d+)",
      dotAll: true,
    );

    final matches = regExp.allMatches(rawText);

    for (var match in matches) {
      parsedList.add({
        'name': match.group(1) ?? 'فعالية',
        'time': match.group(2) ?? '00:00 AM',
        'id': match.group(3) ?? '000000',
      });
    }

    setState(() {
      _events = parsedList;
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
          // الحقول العلوية (Room ID & Date)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _buildHeaderBox("Room ID", "18432094")),
                const SizedBox(width: 10),
                Expanded(child: _buildHeaderBox("Date", "2026-03-05")),
              ],
            ),
          ),

          // زر اللصق الجديد لجلب الأسماء الحقيقية
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showPasteDialog(),
              icon: const Icon(Icons.paste, color: Colors.white),
              label: const Text("لصق مخرجات JS الحقيقية"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9E86FF),
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // القائمة التي ستعرض النتائج
          Expanded(
            child: _events.isEmpty
                ? const Center(child: Text("لا توجد فعاليات مضافة بعد.\nأصق مخرجات JS للأعلى.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      return _buildEventItem(_events[index]);
                    },
                  ),
          ),

          // زر الإنهاء السفلي
          _buildBottomButton(),
        ],
      ),
    );
  }

  // تصميم مربع Room ID و Date
  Widget _buildHeaderBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // تصميم الفعالية (نفس شكل صورتك بالضبط)
  Widget _buildEventItem(Map<String, String> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "${event['id']} ${event['name']}",
              style: const TextStyle(fontSize: 15, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            event['time']!,
            style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 15),
          Checkbox(
            value: true,
            onChanged: (v) {},
            activeColor: const Color(0xFF9E86FF),
          ),
        ],
      ),
    );
  }

  // زر الإنهاء في أسفل الشاشة
  Widget _buildBottomButton() {
    return Padding(
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
          child: const Text("إنهاء", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  // نافذة لصق البيانات
  void _showPasteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text("أصق مخرجات JS المنسوخة"),
        content: TextField(
          controller: _importController,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: "أصق النص من GitHub Logs هنا...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              _parseAndShowEvents(_importController.text);
              Navigator.pop(context);
            },
            child: const Text("تحويل الآن"),
          ),
        ],
      ),
    );
  }
}
