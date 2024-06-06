import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:hs_mailing_repository/src/exceptions/hs_send_email_exception.dart';
import 'package:hs_mailing_repository/src/hs_registration_template.dart';

enum HSMailType { welcome }

class HSMailingRepository {
  HSMailingRepository() {
    this.apiKey = FlutterConfig.get("RESEND_API_KEY");
    assert((this.apiKey != null),
        "The api key cannot be null. Please check the .env file at the root of the project.");
  }

  late final String? apiKey;
  final _dio = Dio();
  final String _endpoint = "https://api.resend.com/emails";

  String getWelcome() {
    return registrationTemplate;
  }

  _HSMailData _getTemplate(HSMailType mailType) {
    switch (mailType) {
      case HSMailType.welcome:
        return _HSMailData(html: getWelcome(), subject: "Welcome aboard!");
    }
  }

  Future<Response> sendEmail(
    HSMailType mailType, {
    String emailFrom = "Hitspot Noreply <noreply@send.hitspot.app>",
    String emailTo = "delivered@resend.dev",
  }) async {
    Response response;
    final _HSMailData mailData = _getTemplate(mailType);
    try {
      response = await _dio.post(_endpoint,
          data: {
            "from": emailFrom,
            "to": [emailTo],
            "subject": mailData.subject,
            "html": mailData.html,
          },
          options: Options(headers: {
            HttpHeaders.acceptHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer $apiKey",
            HttpHeaders.contentTypeHeader: "application/json",
          }));
      return response;
    } on DioException catch (e) {
      throw HSSendEmailException.fromStatusCode(e.response?.statusCode ?? 441);
    } catch (_) {
      throw HSSendEmailException();
    }
  }
}

class _HSMailData {
  const _HSMailData({required this.html, required this.subject, this.email});

  final String html;
  final String subject;
  final String? email;
}
