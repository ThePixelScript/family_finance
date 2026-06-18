import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

String normalizePhone(String phone) {
  return phone.replaceAll(
    RegExp(r'[^\d+]'),
    '',
  );
}

bool isValidPhone(String phone) {
  final digits = normalizePhone(phone)
      .replaceAll('+', '');

  return digits.length >= 10;
}

Future<void> launchPhoneCall(
  String phone,
) async {
  final uri = Uri(
    scheme: 'tel',
    path: normalizePhone(phone),
  );

  if (!await canLaunchUrl(uri)) {
    throw Exception('Cannot open dialer');
  }

  await launchUrl(uri);
}

Future<void> launchWhatsAppChat(
  String phone,
) async {
  var digits = normalizePhone(phone)
      .replaceAll('+', '');

  if (digits.length == 10) {
    digits = '91$digits';
  }

  final uri = Uri.parse(
    'https://wa.me/$digits',
  );

  if (!await canLaunchUrl(uri)) {
    throw Exception('Cannot open WhatsApp');
  }

  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}

Future<void> showPhoneActions(
  BuildContext context,
  String phone,
) async {
  if (!isValidPhone(phone)) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'No valid phone number available',
        ),
      ),
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.phone,
              ),
              title: const Text(
                'Call Customer',
              ),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await launchPhoneCall(phone);
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Unable to open dialer',
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.chat,
              ),
              title: const Text(
                'WhatsApp Customer',
              ),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await launchWhatsAppChat(
                    phone,
                  );
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Unable to open WhatsApp',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
