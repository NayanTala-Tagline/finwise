class UserModel {
  final String? email;
  final String? name;
  final String? phoneNo;
  final String? photoUrl;
  String? walletAddress;
  
  final double btcCount;
  
  // Renamed/Mapped from shareBtcCount to referralRewards for clarity
  final double referralRewards; 
  
  final String referralCode;
  
  // New fields for referral logic
  final int shareCount;
  final String? referredBy;

   UserModel({
    this.email,
    this.name,
    this.phoneNo,
    this.photoUrl,
    this.walletAddress,
    required this.btcCount,
    required this.referralRewards,
    required this.referralCode,
    this.shareCount = 0,
    this.referredBy,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String?,
      name: map['name'] as String?,
      phoneNo: map['phone_no'] as String?,
      photoUrl: map['photo_url'] as String?,
      walletAddress: map['wallet_address'] as String?,
      
      // Handle potential legacy keys or new keys
      btcCount: (map['btc_count'] ?? map['btc_count'] ?? 0.0).toDouble(),
      
      // Map 'referral_rewards' (new) or fall back to 'share_btc_count' (old)
      referralRewards: (map['referral_rewards'] ?? map['share_btc_count'] ?? 0.0).toDouble(),
      
      referralCode: map['referral_code'] ?? '',
      
      shareCount: (map['share_count'] ?? 0).toInt(),
      referredBy: map['referred_by'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone_no': phoneNo,
      'photo_url': photoUrl,
      'wallet_address': walletAddress,
      'btc_count': btcCount,
      'referral_rewards': referralRewards, // storing as new key
      'referral_code': referralCode,
      'share_count': shareCount,
      'referred_by': referredBy,
    };
  }

  /// ✅ `copyWith` method for immutability and updates
  UserModel copyWith({
    String? email,
    String? name,
    String? phoneNo,
    String? photoUrl,
    String? walletAddress,
    double? btcCount,
    double? referralRewards,
    String? referralCode,
    int? shareCount,
    String? referredBy,
  }) {
    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNo: phoneNo ?? this.phoneNo,
      photoUrl: photoUrl ?? this.photoUrl,
      walletAddress: walletAddress ?? this.walletAddress,
      btcCount: btcCount ?? this.btcCount,
      referralRewards: referralRewards ?? this.referralRewards,
      referralCode: referralCode ?? this.referralCode,
      shareCount: shareCount ?? this.shareCount,
      referredBy: referredBy ?? this.referredBy,
    );
  }
}


// class UserModel {
//   final String? email;
//   final String? name;
//   final String? phoneNo;
//   final String? photoUrl;
//   final String? walletAddress;
//   final double btcCount;
//   final double shareBtcCount;
//   final String referralCode;

//   const UserModel({
//     this.email,
//     this.name,
//     this.phoneNo,
//     this.photoUrl,
//     this.walletAddress,
//     required this.btcCount,
//     required this.shareBtcCount,
//     required this.referralCode,
//   });

//   factory UserModel.fromMap(Map<String, dynamic> map) {
//     return UserModel(
//       email: map['email'] as String?,
//       name: map['name'] as String?,
//       phoneNo: map['phone_no'] as String?,
//       photoUrl: map['photo_url'] as String?,
//       walletAddress: map['wallet_address'] as String?,
//       btcCount: (map['btc_count'] ?? 0.0).toDouble(),
//       shareBtcCount: (map['share_btc_count'] ?? 0.0).toDouble(),
//       referralCode: map['referral_code'] ?? '',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'email': email,
//       'name': name,
//       'phone_no': phoneNo,
//       'photo_url': photoUrl,
//       'wallet_address': walletAddress,
//       'btc_count': btcCount,
//       'share_btc_count': shareBtcCount,
//       'referral_code': referralCode,
//     };
//   }

//   /// ✅ `copyWith` method for immutability and updates
//   UserModel copyWith({
//     String? email,
//     String? name,
//     String? phoneNo,
//     String? photoUrl,
//     String? walletAddress,
//     double? btcCount,
//     double? shareBtcCount,
//     String? referralCode,
//   }) {
//     return UserModel(
//       email: email ?? this.email,
//       name: name ?? this.name,
//       phoneNo: phoneNo ?? this.phoneNo,
//       photoUrl: photoUrl ?? this.photoUrl,
//       walletAddress: walletAddress ?? this.walletAddress,
//       btcCount: btcCount ?? this.btcCount,
//       shareBtcCount: shareBtcCount ?? this.shareBtcCount,
//       referralCode: referralCode ?? this.referralCode,
//     );
//   }
// }
