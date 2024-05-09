import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hs_mailing_repository/src/exceptions/hs_send_email_exception.dart';
import 'package:hs_mailing_repository/src/hs_registration_template.dart';

enum HSMailType { welcome }

class HSMailingRepository {
  HSMailingRepository() {
    this.apiKey = dotenv.env["re_AJvgWvQH_NTPxajAn6neREPhZCjmBu8uU"];
    assert((this.apiKey != null),
        "The api key cannot be null. Please check the .env file at the root of the project.");
  }

  late final String? apiKey;
  final _dio = Dio();
  String getWelcome() {
    return registrationTemplate;
  }

  _HSMailData _getTemplate(HSMailType mailType) {
    switch (mailType) {
      case HSMailType.welcome:
        return _HSMailData(html: getWelcome(), subject: "Welcome onboard!");
    }
  }

  Future<Response> sendEmail(
    HSMailType mailType, {
    String emailFrom = "onboarding@resend.dev",
    String emailTo = "delivered@resend.dev",
  }) async {
    Response response;
    final _HSMailData mailData = _getTemplate(mailType);
    final String url = "https://api.resend.com/emails";
    try {
      // response = await _dio.post(url,
      //     data: {
      //       "from": emailFrom,
      //       "to": [emailTo],
      //       "subject": mailData.subject,
      //       // "html": mailData.html,
      //       // "bcc": null,
      //       // "cc": null,
      //       // "reply_to": null,
      //       "text": "Text!",
      //     },
      //     options: Options(headers: {
      //       HttpHeaders.acceptHeader: "application/json",
      //       HttpHeaders.authorizationHeader:
      //           "Bearer re_pBRU21QS", // TODO: Hide in .env
      //       HttpHeaders.contentTypeHeader: "application/json",
      //     }));
      // return response;
      String apiUrl = 'https://api.resend.com/emails';
      String token = apiKey ?? "no_key";
      try {
        Response response = await _dio.post(
          apiUrl,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
          data: {
            "from": "Acme <onboarding@resend.dev>",
            "to": ["delivered@resend.dev"],
            "subject": "hello world",
            "text": "it works!",
            "headers": {"X-Entity-Ref-ID": "123"},
          },
        );

        print(response.data);
        return response;
      } catch (e) {
        print('Error sending email: $e');
        rethrow;
      }
    } on DioException catch (e) {
      print("Dio: ${e.message}");
      throw HSSendEmailException("Dio Exception: ${e.message}");
    } catch (_) {
      print("Unknown: $_");
      throw HSSendEmailException();
    }
  }
}

class _HSMailData {
  const _HSMailData({this.email, required this.html, required this.subject});

  final String html;
  final String subject;
  final String? email;
}
