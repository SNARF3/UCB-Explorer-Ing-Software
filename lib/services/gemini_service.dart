import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyBZUUal0DLkceJwScxBWdW8vLWE1ldiuoQ';
  static const String _modelName = 'gemini-1.5-flash';

  late final GenerativeModel _model;

  GeminiService() {
    _initializeModel();
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      generationConfig: _getGenerationConfig(),
      safetySettings: _getSafetySettings(),
    );
  }

  GenerationConfig _getGenerationConfig() => GenerationConfig(
        temperature: 0.9,
        topK: 1,
        topP: 1,
        maxOutputTokens: 2048,
      );

  List<SafetySetting> _getSafetySettings() => [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
      ];

  Future<ChatResponse> getResponse(String prompt) async {
    try {
      final String formattedPrompt = '''
      Eres un asistente de la Universidad Católica Boliviana "San Pablo" (UCB). 
      Debes proporcionar información precisa y actualizada sobre:
      - Carreras, facultades, programas académicos
      - Admisiones, requisitos, fechas importantes
      - Eventos, noticias universitarias
      - Instalaciones, servicios estudiantiles
      
      Reglas importantes:
      1. SIEMPRE verifica información crítica con fuentes oficiales
      2. Usa emojis relevantes para hacer la conversación amigable
      3. Estructura la información en formato Markdown con:
         - Encabezados claros
         - Listas con viñetas
         - Negritas para puntos importantes
         - Enlaces claramente identificados como [Texto del enlace](URL)
      4. Proporciona fechas de actualización cuando sea relevante
      5. Si no tienes información, indica que no estás seguro y sugiere consultar fuentes oficiales y dales el link correspondiente
      6. Puedes tener acceso a internet para buscar información confiable y actualizada
      
      Pregunta del usuario: "$prompt"
      ''';

      final content = Content.text(formattedPrompt);
      final response = await _model.generateContent([content]);
      
      return _processResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  ChatResponse _processResponse(GenerateContentResponse response) {
    if (response.text == null || response.text!.isEmpty) {
      return ChatResponse(
        text: 'No recibí una respuesta válida. ¿Podrías reformular tu pregunta?',
        structuredData: [],
      );
    }
    
    // Procesar enlaces y estructura
    final text = response.text!;
    final structuredData = _extractStructuredData(text);
    
    return ChatResponse(
      text: text,
      structuredData: structuredData,
    );
  }

  List<StructuredData> _extractStructuredData(String text) {
    final List<StructuredData> data = [];
    
    // Extraer enlaces
    final linkRegExp = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    final matches = linkRegExp.allMatches(text);
    
    for (final match in matches) {
      data.add(StructuredData(
        type: 'link',
        content: match.group(1) ?? '',
        metadata: {'url': match.group(2) ?? ''},
      ));
    }
    
    // Extraer información importante (puedes añadir más patrones)
    final importantInfoRegExp = RegExp(r'\*\*(.+?)\*\*');
    final infoMatches = importantInfoRegExp.allMatches(text);
    
    for (final match in infoMatches) {
      data.add(StructuredData(
        type: 'important_info',
        content: match.group(1) ?? '',
      ));
    }
    
    return data;
  }

  ChatResponse _handleError(dynamic error) {
    final errorMsg = error is Exception 
        ? 'Error de la API: ${error.toString()}' 
        : 'Error desconocido: ${error.toString()}';
    
    return ChatResponse(
      text: errorMsg,
      structuredData: [],
    );
  }
}

class ChatResponse {
  final String text;
  final List<StructuredData> structuredData;

  ChatResponse({required this.text, required this.structuredData});
}

class StructuredData {
  final String type; // 'link', 'important_info', etc.
  final String content;
  final Map<String, String>? metadata;

  StructuredData({
    required this.type,
    required this.content,
    this.metadata,
  });
}