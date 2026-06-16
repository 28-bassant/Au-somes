import 'package:url_launcher/url_launcher.dart';

Future<void> openPhone(String phone) async {
  final uri = Uri.parse("tel:$phone");
  await launchUrl(uri);
}

Future<void> openLink(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> openMap(double lat, double lng) async {
  final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng");
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
