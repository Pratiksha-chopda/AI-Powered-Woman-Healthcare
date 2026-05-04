import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class HFChatService {
  static Future<String> sendMessage(String userMessage) async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) return "⚠ Missing HF API Token.";

      final response = await http.post(
        Uri.parse("https://router.huggingface.co/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "meta-llama/Llama-3.2-3B-Instruct",
          "messages": [
            {"role": "user", "content": userMessage}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body["choices"][0]["message"]["content"];
      }

      // Helpful for debugging any remaining issues
      return "⚠ HF Error ${response.statusCode}: ${response.body}";
    } catch (e) {
      return "⚠ Error: $e";
    }
  }
}