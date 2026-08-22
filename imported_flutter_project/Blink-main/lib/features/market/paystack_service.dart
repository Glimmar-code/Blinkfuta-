import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blink/services/auth_service.dart';

/// Wraps Paystack checkout for two flows in ALUTA MARKET:
///   1. The one-time ₦2,000 seller registration fee.
///   2. Paying to promote a listing (run it as an ad in the feed).
///
/// Uses `flutter_paystack_plus`'s secure flow: a Supabase Edge Function
/// (see `supabase/functions/paystack-initialize`) holds your Paystack
/// SECRET key and calls Paystack's `/transaction/initialize` REST API on
/// your behalf, returning an `authorization_url`. The app only ever opens
/// that URL in Paystack's own hosted checkout — the secret key is never
/// bundled into the Flutter app.
///
/// SETUP REQUIRED (see integration notes at the end of this response):
///   1. `flutter pub add flutter_paystack_plus`
///   2. Deploy `supabase/functions/paystack-initialize` and
///      `supabase/functions/paystack-verify`
///   3. `supabase secrets set PAYSTACK_SECRET_KEY=sk_live_xxx`
class PaystackService {
  static final _client = Supabase.instance.client;

  /// amountNaira: e.g. 2000 for the seller registration fee.
  /// purpose: a short tag logged by the edge function, e.g.
  /// 'seller_registration' or 'promote_listing'.
  /// onSuccess is called once payment is confirmed server-side.
  static Future<void> pay({
    required BuildContext context,
    required double amountNaira,
    required String purpose,
    required VoidCallback onSuccess,
    required ValueChanged<String> onError,
  }) async {
    final email = AuthService.currentUser?.email;
    if (email == null) {
      onError('You must be signed in to pay.');
      return;
    }

    final reference = '${purpose}_${DateTime.now().millisecondsSinceEpoch}';

    late final String authorizationUrl;
    try {
      final res = await _client.functions.invoke('paystack-initialize', body: {
        'email': email,
        'amount_kobo': (amountNaira * 100).round(),
        'reference': reference,
        'purpose': purpose,
      });
      final data = res.data as Map<String, dynamic>;
      authorizationUrl = data['authorization_url'] as String;
    } catch (e) {
      onError('Could not start payment. Please try again.');
      return;
    }

    if (!context.mounted) return;

    await FlutterPaystackPlus.openPaystackPopup(
      context: context,
      customerEmail: email,
      amount: (amountNaira * 100).round().toString(),
      reference: reference,
      authorizationUrl: authorizationUrl,
      callBackUrl: 'https://your-app.com/payment/callback',
      onSuccess: () async {
        final ok = await verify(reference);
        if (ok) {
          onSuccess();
        } else {
          onError('Payment could not be verified. Contact support with reference $reference.');
        }
      },
      onClosed: () => onError('Payment was cancelled.'),
    );
  }

  /// Confirms the transaction server-side via `paystack-verify`. Always
  /// call this before unlocking anything paid-for — Paystack's own
  /// `/transaction/verify` endpoint is the source of truth, not the popup
  /// closing "successfully" on-device.
  static Future<bool> verify(String reference) async {
    try {
      final res = await _client.functions.invoke('paystack-verify', body: {'reference': reference});
      final data = res.data as Map<String, dynamic>;
      return data['verified'] == true;
    } catch (_) {
      return false;
    }
  }
}
