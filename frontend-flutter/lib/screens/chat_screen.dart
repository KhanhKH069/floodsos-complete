// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // 🟢 Để tự cuộn

  // Tin nhắn ban đầu
  final List<Map<String, String>> _messages = [
    {
      "role": "bot",
      "text":
          "🤖 Chào bạn! Tôi là Trợ lý PCTT.\n\nBạn cần tìm số hotline của tỉnh nào?"
    }
  ];

  bool _isTyping = false;

  // 🟢 DỮ LIỆU SỐ ĐIỆN THOẠI PCTT 34 TỈNH THÀNH (Miền Bắc & Trung)
  final Map<String, String> _provinceHotlines = {
    'bắc giang': '0204.3854.437',
    'hà nội': '0243.3839.131',
    'hải phòng': '0225.3842.100',
    'quảng ninh': '0203.3835.636',
    'hải dương': '0220.3853.847',
    'hưng yên': '0221.3863.664',
    'thái bình': '0227.3731.551',
    'nam định': '0228.3649.009',
    'ninh bình': '0229.3871.189',
    'hà nam': '0226.3852.793',
    'thái nguyên': '0208.3855.127',
    'phú thọ': '0210.3846.518',
    'bắc kạn': '0209.3870.089',
    'cao bằng': '0206.3852.282',
    'lạng sơn': '0205.3812.228',
    'tuyên quang': '0207.3822.427',
    'yên bái': '0216.3852.316',
    'lào cai': '0214.3840.063',
    'điện biên': '0215.3825.269',
    'lai châu': '0213.3876.515',
    'sơn la': '0212.3852.136',
    'hòa bình': '0218.3852.327',
    'thanh hóa': '0237.3852.348',
    'nghệ an': '0238.3844.729',
    'hà tĩnh': '0239.3855.457',
    'quảng bình': '0232.3822.372',
    'quảng trị': '0233.3852.483',
    'thừa thiên huế': '0234.3822.693',
    'đà nẵng': '0236.3822.259',
    'quảng nam': '0235.3810.150',
    'quảng ngãi': '0255.3822.569',
    'bình định': '0256.3822.346',
    'phú yên': '0257.3823.364',
    'khánh hòa': '0258.3822.559',
  };

  // 🟢 KIẾN THỨC CHUNG
  final Map<List<String>, String> _generalKnowledge = {
    ['113', 'công an', 'cướp', 'đánh nhau']: "👮 CÔNG AN: Gọi 113",
    ['114', 'cháy', 'cứu hỏa', 'mắc kẹt', 'đuối nước']:
        "🚒 CỨU HỎA & CỨU NẠN: Gọi 114",
    ['115', 'cấp cứu', 'thương', 'máu', 'bệnh viện']: "🚑 CẤP CỨU: Gọi 115",
    ['sos', 'khẩn cấp', 'cứu']:
        "🚨 Bấm nút ĐỎ to ngoài màn hình chính để gửi vị trí ngay!",
    ['drone', 'máy bay']:
        "🚁 Đội bay Drone sẽ tự động xuất kích khi nhận tín hiệu SOS.",
  };

  Future<void> _handleReply(String userText) async {
    String reply =
        "Xin lỗi, tôi chưa tìm thấy thông tin cho tỉnh này. Hãy thử nhập tên tỉnh chính xác (vd: Bắc Giang).";
    String input = userText.toLowerCase().trim();
    bool found = false;

    // 1. Tìm trong danh sách Tỉnh thành trước
    for (var entry in _provinceHotlines.entries) {
      if (input.contains(entry.key)) {
        // Viết hoa chữ cái đầu cho đẹp
        String provinceName = entry.key
            .split(" ")
            .map((str) => str[0].toUpperCase() + str.substring(1))
            .join(" ");
        reply =
            "📞 **Ban Chỉ Huy PCTT Tỉnh $provinceName**\n\n☎️ Hotline: ${entry.value}\n\n(Trực ban 24/7)";
        found = true;
        break;
      }
    }

    // 2. Nếu không phải tỉnh, tìm trong kiến thức chung
    if (!found) {
      for (var entry in _generalKnowledge.entries) {
        for (var keyword in entry.key) {
          if (input.contains(keyword)) {
            reply = entry.value;
            found = true;
            break;
          }
        }
        if (found) break;
      }
    }

    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Giả lập độ trễ

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({"role": "bot", "text": reply});
      });
      // Tự động cuộn xuống cuối
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    String userText = _controller.text;

    setState(() {
      _messages.add({"role": "user", "text": userText});
      _controller.clear();
    });

    _handleReply(userText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2129),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.support_agent, color: Colors.cyanAccent, size: 28),
            SizedBox(width: 10),
            Text("TRA CỨU HOTLINE",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF2C2F36),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // 🟢 Gắn controller vào đây
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color:
                          isUser ? Colors.blueAccent : const Color(0xFF383C46),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                            isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight:
                            isUser ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      msg['text']!,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16, height: 1.5),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 10),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Trợ lý đang tìm danh bạ...",
                      style: TextStyle(
                          color: Colors.white54, fontStyle: FontStyle.italic))),
            ),

          // KHUNG NHẬP LIỆU
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF2C2F36),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Nhập tên tỉnh (vd: Bắc Giang)...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.cyanAccent,
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.black87),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
