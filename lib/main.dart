import 'package:flutter/material.dart';

void main() {
  runApp(const WolfEventManagerApp());
}

class WolfEventManagerApp extends StatelessWidget {
  const WolfEventManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WOLF Event Manager',
      theme: ThemeData(
        // استخدام سمة داكنة تناسب واجهتك الأصلية
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A), // خلفية داكنة جداً
        primaryColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
        cardColor: const Color(0xFF252525), // لون البطاقات
      ),
      home: const EventInputParserScreen(),
    );
  }
}

class EventInputParserScreen extends StatefulWidget {
  const EventInputParserScreen({super.key});

  @override
  State<EventInputParserScreen> createState() => _EventInputParserScreenState();
}

class _EventInputParserScreenState extends State<EventInputParserScreen> {
  // وحدة تحكم للنص الملصق
  final TextEditingController _rawTextController = TextEditingController();
  // قائمة لتخزين الفعاليات التي تم تحليلها
  List<WOLFEvent> _parsedEvents = [];

  // دالة لتحليل النص الخام باستخدام التعبيرات النمطية (RegExp)
  void _parseAndDisplayEvents() {
    final rawText = _rawTextController.text;
    if (rawText.isEmpty) {
      _showError('الرجاء لصق نص الفعاليات أولاً.');
      return;
    }

    final List<WOLFEvent> newEvents = [];

    // التعبير النمطي للبحث عن نمط كل فعالية في النص
    // يبحث عن الاسم بين قوسين 【 】، والوقت بعد ⏰، والمدة بعد ⏳، والـ ID بعد 🆔
    final RegExp eventRegExp = RegExp(
      r'(\d{2})-\s*【\s*(.*?)\s*】.*?⏰ وقت البداية:\s*(.*?)\s*\n.*?⏳ مدة الفعالية:\s*(.*?)\s*\n.*?🆔 ID:\s*(\d+)',
      dotAll: true, // للسماح بالبحث عبر عدة أسطر
    );

    final matches = eventRegExp.allMatches(rawText);

    if (matches.isEmpty) {
      _showError('لم يتم العثور على فعاليات بتنسيق مدعوم. تأكد من لصق مخرجات JS الأصلية.');
      return;
    }

    for (var match in matches) {
      // استخراج البيانات من المجموعات التي عثر عليها التعبير النمطي
      final name = match.group(2)?.trim() ?? 'فعالية';
      final time = match.group(3)?.trim() ?? '';
      final duration = match.group(4)?.trim() ?? '';
      final id = match.group(5)?.trim() ?? '';

      newEvents.add(WOLFEvent(
        id: id,
        name: name,
        time: time,
        duration: duration,
      ));
    }

    setState(() {
      _parsedEvents = newEvents;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WOLF Event Parser'),
        actions: [
          // زر للمسح السريع
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              _rawTextController.clear();
              setState(() {
                _parsedEvents = [];
              });
            },
          ),
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
