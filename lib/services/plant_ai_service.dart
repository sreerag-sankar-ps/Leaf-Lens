import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/disease_analysis.dart';

class PlantAIService {
  static const String _apiKey = "YOUR_API_KEY_HERE";
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-opus-4-5';

  Future<DiseaseAnalysis> analyzePlantImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    final mimeType = _getMimeType(imageFile.path);
    final prompt = _buildPrompt();

    final requestBody = {
      'model': _model,
      'max_tokens': 2000,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': mimeType,
                'data': base64Image,
              },
            },
            {'type': 'text', 'text': prompt},
          ],
        },
      ],
    };

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': _apiKey,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parse(data['content'][0]['text'] as String);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please contact support.');
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests. Please wait and try again.');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        final msg = error['error']?['message'] ?? '';
        if (msg.contains('credit')) {
          throw Exception('Credits too low. Please top up.');
        }
        throw Exception('Error: $msg');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          'Error: ${error['error']?['message'] ?? 'Unknown error'}',
        );
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to analyze: $e');
    }
  }

  String _buildPrompt() {
    return '''You are an expert plant pathologist. Analyze this plant image.

Respond ONLY with a valid JSON object, no markdown, no extra text:

{
  "plant_name": "Common name of the plant",
  "health_status": "Healthy",
  "disease_name": null,
  "severity": null,
  "description": "2-3 sentence description of what you observe",
  "symptoms": ["symptom 1", "symptom 2"],
  "causes": ["cause 1", "cause 2"],
  "treatments": [
    {
      "type": "Organic",
      "name": "Treatment name",
      "description": "Brief description",
      "how_to_apply": "Step by step instructions",
      "is_organic": true
    }
  ],
  "prevention_tips": ["tip 1", "tip 2", "tip 3"],
  "confidence_score": 0.85
}

Rules:
- health_status must be: "Healthy", "Diseased", or "Unknown"
- If not a plant set health_status to "Unknown" and disease_name to null
- If diseased provide 2-3 treatments
- confidence_score between 0.0 and 1.0
- Return ONLY the JSON nothing else''';
  }

  DiseaseAnalysis _parse(String responseText) {
    try {
      String text = responseText.trim();
      if (text.startsWith('```json')) {
        text = text.substring(7);
      }
      if (text.startsWith('```')) {
        text = text.substring(3);
      }
      if (text.endsWith('```')) {
        text = text.substring(0, text.length - 3);
      }
      text = text.trim();
      final startIndex = text.indexOf('{');
      final endIndex = text.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        text = text.substring(startIndex, endIndex + 1);
      }
      return DiseaseAnalysis.fromJson(jsonDecode(text));
    } catch (e) {
      return DiseaseAnalysis(
        plantName: 'Unknown',
        healthStatus: 'Unknown',
        description:
            'Unable to parse results. Please try again with a clearer image.',
        symptoms: [],
        causes: [],
        treatments: [],
        preventionTips: [],
        confidenceScore: 0.0,
        analyzedAt: DateTime.now(),
      );
    }
  }

  String _getMimeType(String filePath) {
    final ext = filePath.toLowerCase().split('.').last;
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
