import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class ApiService {
  late Dio _dio;

  //생성자, 429 에러 상세 내용 전달을 위함, 박준수
  ApiService() {
    _dio = Dio();
    _dio.options.validateStatus = (status) {
      return status! < 500 || status == 429; // 429 상태 코드 허용
    };
  }

  Future<String> encodeImage(File image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  Future<String> sendMessageGPT({required String input_string}) async {
    try {
      final response = await _dio.post(
        "$BASE_URL/openai/deployments/test3/chat/completions?api-version=2024-04-01-preview",
        options: Options(
          headers: {
            'api-key': API_KEY,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "model": 'gpt-35-turbo',
          "messages": [
            {
              "role": "user",
              "content":
              "GPT, I need a summarized keyword to search related YouTube videos for the following descriptions. No additional information or context or numbering is needed—only summarized keyword. Answer in Korean. The following descriptions is $input_string",
            }
          ],
        },
      );

      final jsonResponse = response.data;

      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']["message"]);
      }

      return jsonResponse["choices"][0]["message"]["content"];
    } catch (error) {
      throw Exception('Error: $error');
    }
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
                  'Please let me know how I can improve this painting. You must describe each using numbers and colons(example: 1. Add something: ), the most important improvements should always come first. Answer in Korean.'
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

  //1d383e0535be3bebab1394ff988fc962716cc986328c384410f0926b4495adb2 - 학과 제공
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
                  'Please let me know how I can improve my painting. You must describe each using numbers and colons(example: 1. Add something: ), the most important improvements should always come first. You do not have to make any other unnecessary answers. Answer in Korean. If you cannot do that, explain why.'
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