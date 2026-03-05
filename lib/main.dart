import 'package:flutter/material.dart';

void main() => runApp(const WolfManagerApp());

class WolfManagerApp extends StatelessWidget {
  const WolfManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF13211E), // نفس لون خلفية صورك
      ),
      home: const WolfEventScreen(),
    );
  }
}

class WolfEventScreen extends StatefulWidget {
  const WolfEventScreen({super.key});

  @override
  State<WolfEventScreen> createState() => _WolfEventScreenState();
}

class _WolfEventScreenState extends State<WolfEventScreen> {
  final List<Map<String, String>> _events = [];
  final TextEditingController _importController = TextEditingController();

  // دالة لتحويل النص الملصق إلى قائمة فعاليات
  void _parseAndAddEvents(String rawText) {
    final RegExp regExp = RegExp(
      r"【\s*(.*?)\s*】.*?وقت البداية:\s*(.*?)\s*\n.*?ID:\s*(\d+)",
      dotAll: true,
    );

    final matches = regExp.allMatches(rawText);
    setState(() {
      for (var match in matches) {
        _events.add({
          'name': match.group(1) ?? 'فعالية',
          'time': match.group(2) ?? '00:00 AM',
          'id': match.group(3) ?? '000000',
        });
      }
    });
    _importController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WOLF Event Manager'), backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          // حقول الإدخال كما في صورتك
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _buildHeaderField("Room ID", "9969")),
                const SizedBox(width: 10),
                Expanded(child: _buildHeaderField("Date", "2026-03-05")),
              ],
            ),
          ),
          
          // زر لصق البيانات من GitHub
          ElevatedButton(
            onPressed: () => _showImportDialog(),
            child: const Text("لصق بيانات من JS"),
          ),

          // قائمة الفعاليات المنظمة
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return _buildEventTile(_events[index]);
              },
            ),
          ),
          
          // زر الإنهاء
          Padding(
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
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEventTile(Map<String, String> event) {
    return ListTile(
      title: Text("${event['id']} ${event['name']}"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(event['time']!, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Checkbox(value: true, onChanged: (v) {}, activeColor: const Color(0xFF9E86FF)),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("أصق مخرجات JS هنا"),
        content: TextField(controller: _importController, maxLines: 5, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              _parseAndAddEvents(_importController.text);
              Navigator.pop(context);
            },
            child: const Text("تحويل"),
          ),
        ],
      ),
    );
  }
}
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // منطقة لصق النص
            TextField(
              controller: _rawTextController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'أصق هنا النص الخام للفعاليات كما هو من مخرجات JS...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                fillColor: const Color(0xFF252525),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
            const SizedBox(height: 16),
            // زر التحليل والعرض
            ElevatedButton.icon(
              onPressed: _parseAndDisplayEvents,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('تحليل وعرض الفعاليات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 20),
            // عنوان القسم وقائمة النتائج
            if (_parsedEvents.isNotEmpty)
              Row(
                children: const [
                  Text(
                    'الفعاليات المكتشفة:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                ],
              ),
            if (_parsedEvents.isNotEmpty) const SizedBox(height: 10),
            Expanded(
              child: _parsedEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.content_paste, size: 60, color: Colors.grey.shade700),
                          const SizedBox(height: 16),
                          Text(
                            'النتائج ستظهر هنا بعد التحليل',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _parsedEvents.length,
                      itemBuilder: (context, index) {
                        return EventDisplayCard(event: _parsedEvents[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// نموذج بيانات للفعالية
class WOLFEvent {
  final String id;
  final String name;
  final String time;
  final String duration;
  bool isChecked;

  WOLFEvent({
    required this.id,
    required this.name,
    required this.time,
    required this.duration,
    this.isChecked = true, // مفعلة افتراضياً كما في واجهتك
  });
}

// بطاقة عرض الفعالية بتنسيق يشبه واجهتك الأصلية
class EventDisplayCard extends StatefulWidget {
  final WOLFEvent event;

  const EventDisplayCard({super.key, required this.event});

  @override
  State<EventDisplayCard> createState() => _EventDisplayCardState();
}

class _EventDisplayCardState extends State<EventDisplayCard> {
  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: BorderRadius.circular(15),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // الـ ID والاسم
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${event.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // الوقت والمدة
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    event.time,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent, // لون مميز للوقت
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '⏳ ${event.duration}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            // خانة الاختيار
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: event.isChecked,
                    onChanged: (bool? newValue) {
                      setState(() {
                        event.isChecked = newValue ?? true;
                      });
                    },
                    activeColor: Colors.deepPurpleAccent,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(color: Colors.grey.shade600, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
