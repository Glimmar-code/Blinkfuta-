import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blink/services/auth_service.dart';
import '../profile/user_profile_model.dart';
import 'package:blink/post_model.dart';

/// Status of a seller's registration row.
enum SellerStatus { none, pendingPayment, active, suspended }

SellerStatus _statusFromString(String? v) {
  switch (v) {
    case 'pending_payment':
      return SellerStatus.pendingPayment;
    case 'active':
      return SellerStatus.active;
    case 'suspended':
      return SellerStatus.suspended;
    default:
      return SellerStatus.none;
  }
}

/// The professional details collected during "Become a Seller" onboarding.
class SellerProfile {
  final String id;
  final String businessName;
  final String contactPhone;
  final String whatsappNumber;
  final String stateOfResidence;
  final String city;
  final String fullAddress;
  final String bio;
  final List<String> categoriesSold;
  final SellerStatus status;

  const SellerProfile({
    required this.id,
    required this.businessName,
    required this.contactPhone,
    required this.whatsappNumber,
    required this.stateOfResidence,
    required this.city,
    required this.fullAddress,
    required this.bio,
    required this.categoriesSold,
    required this.status,
  });

  factory SellerProfile.fromMap(Map<String, dynamic> map) {
    return SellerProfile(
      id: map['id'] as String? ?? '',
      businessName: map['business_name'] as String? ?? '',
      contactPhone: map['contact_phone'] as String? ?? '',
      whatsappNumber: map['whatsapp_number'] as String? ?? '',
      stateOfResidence: map['state_of_residence'] as String? ?? '',
      city: map['city'] as String? ?? '',
      fullAddress: map['full_address'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      categoriesSold: (map['categories_sold'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      status: _statusFromString(map['status'] as String?),
    );
  }
}

/// All Supabase reads/writes for seller onboarding. Mirrors the style of
/// `ProfileService` — static methods, permissive on read, throws on write
/// failures so the UI can show a real error instead of silently no-op'ing.
///
/// Expects a `sellers` table:
///   id                 uuid primary key references profiles(id)
///   business_name      text
///   contact_phone      text
///   whatsapp_number    text
///   state_of_residence text
///   city               text
///   full_address       text
///   bio                text
///   categories_sold    text[]
///   status             text  ('pending_payment' | 'active' | 'suspended')
///   created_at         timestamptz default now()
class SellerService {
  static final _client = Supabase.instance.client;

  /// Reads the caller's verification tier from their existing profile row
  /// (`profiles.verification`, mapped through `VerificationBadge`). This is
  /// the gate for "Become a Seller" — only Blue/Gold tick users may proceed.
  static Future<VerificationBadge> myVerificationBadge() async {
    final user = AuthService.currentUser;
    if (user == null) return VerificationBadge.none;
    try {
      final row = await _client.from('profiles').select('verification').eq('id', user.id).maybeSingle();
      final raw = row?['verification'] as String?;
      switch (raw) {
        case 'blue':
          return VerificationBadge.blue;
        case 'gold':
          return VerificationBadge.gold;
        default:
          return VerificationBadge.none;
      }
    } catch (_) {
      return VerificationBadge.none;
    }
  }

  static Future<SellerProfile?> myProfile() async {
    final user = AuthService.currentUser;
    if (user == null) return null;
    try {
      final row = await _client.from('sellers').select().eq('id', user.id).maybeSingle();
      if (row == null) return null;
      return SellerProfile.fromMap(row);
    } catch (_) {
      return null;
    }
  }

  /// Creates/updates the seller row in `pending_payment` status. Call this
  /// BEFORE starting the Paystack checkout; flip to `active` afterwards
  /// with [activateAfterPayment].
  static Future<void> savePendingProfile({
    required String businessName,
    required String contactPhone,
    required String whatsappNumber,
    required String stateOfResidence,
    required String city,
    required String fullAddress,
    required String bio,
    required List<String> categoriesSold,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) throw StateError('You must be signed in to become a seller.');

    await _client.from('sellers').upsert({
      'id': user.id,
      'business_name': businessName,
      'contact_phone': contactPhone,
      'whatsapp_number': whatsappNumber,
      'state_of_residence': stateOfResidence,
      'city': city,
      'full_address': fullAddress,
      'bio': bio,
      'categories_sold': categoriesSold,
      'status': 'pending_payment',
    });
  }

  static Future<void> activateAfterPayment() async {
    final user = AuthService.currentUser;
    if (user == null) return;
    await _client.from('sellers').update({'status': 'active'}).eq('id', user.id);
  }

  /// Persists a newly-created item. Call after `PaystackService` confirms
  /// payment when the seller chooses to promote the listing on posting.
  static Future<void> createListing(MarketItem item) async {
    final user = AuthService.currentUser;
    if (user == null) throw StateError('You must be signed in to post an item.');

    await _client.from('market_items').insert({
      'seller_id': user.id,
      'title': item.title,
      'description': item.description,
      'price': item.price,
      'negotiable': item.negotiable,
      'category': item.tag,
      'tags': item.tags,
      'images': item.gallery,
      'location': item.location,
      'condition': item.condition.name,
      'is_promoted': item.isPromoted,
    });
  }
}
