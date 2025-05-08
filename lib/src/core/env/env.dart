import 'package:flutter_dotenv/flutter_dotenv.dart';

String kAppId = dotenv.env['APP_ID'] ?? '';
String kToken = dotenv.env['K_TOKEN'] ?? '';