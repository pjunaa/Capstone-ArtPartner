import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<String> encodeImage(File image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  Future<String> sendImageToGPT4Vision({
    required File image,
    int maxTokens = 1000,
    String model = "gpt-4-vision-preview",
  }) async {
    final String base64Image = await encodeImage(image);

    try {
      final response = await _dio.post(
        '$BASE_URL/openai/deployments/test3/chat/completions?api-version=2023-12-01-preview',
        options: Options(
          headers: {
            'api-key': API_KEY,
            'Content-Type': 'application/json',
          },
        ),
        data: jsonEncode({
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant with the drawing.'
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text':
                  'Explain the techniques and artistic features used in the following painting. Leave spaces between paragraphs so that it is easy to read. Do not use numbering. You need to analyze this in detail, but please answer with 400~600 characters. Answer in Korean.'
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
              ],
            },
          ],
          'max_tokens': maxTokens,
          //"stream": false
        }),
      );

      final jsonResponse = response.data;

      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']["message"]);
      }
      return jsonResponse["choices"][0]["message"]["content"];
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> sendImageToGPT4Vision_2({
    required File image,
    String model = "gpt-4o-2024-05-13",
  }) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final String base64Image = await encodeImage(image);

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $API_KEY_2',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant with the drawing.'
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text':
                  'Explain the techniques and artistic features used in the following painting. Leave spaces between paragraphs so that it is easy to read. Do not use numbering. You need to analyze this in detail, but please answer with 400~600 characters. Answer in Korean.'
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse["choices"][0]["message"]["content"] ?? "No content returned.";
      } else {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse["error"]?["message"] ?? "Unknown error occurred.";
      }

    } catch (error) {
      throw Exception('Error: $error');
    }
  }

}
