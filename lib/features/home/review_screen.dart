import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _rating = 0; // 별 개수
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("거래 후기 작성", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 0, 59, 29),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("별점을 선택해주세요:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        // 같은 별을 다시 누르면 취소
                        if (_rating == index + 1) {
                          _rating = 0;
                        } else {
                          _rating = index + 1;
                        }
                      });
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            const Text("후기를 작성해주세요:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "거래 경험에 대해 작성해주세요",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 59, 29),
                ),
                onPressed: () {
                  String reviewText = _reviewController.text;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("별점: $_rating, 후기: $reviewText")),
                  );
                  Navigator.pop(context); // 작성 후 뒤로 가기
                },
                child: const Text(
                  "제출하기",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
