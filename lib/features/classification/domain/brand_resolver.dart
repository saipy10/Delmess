import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/messages/data/sender_metadata_repository.dart';

/// Information about a resolved brand.
class BrandInfo {
  final String brandName;
  final String? organization;
  final String? industry;
  final CategoryType? defaultCategory;

  const BrandInfo({
    required this.brandName,
    this.organization,
    this.industry,
    this.defaultCategory,
  });
}

/// Resolves Indian SMS entity headers to friendly brand names and industry metadata.
class BrandResolver {
  final SenderMetadataRepository? repository;
  final Map<String, BrandInfo> _cache = {};

  BrandResolver({this.repository}) {
    _loadBuiltinBrands();
  }

  /// Built-in canonical dictionary of Indian commercial headers.
  static final Map<String, BrandInfo> _builtinBrands = {
    // --- Banking & Finance (Transactional) ---
    'HDFCBN': const BrandInfo(
      brandName: 'HDFC Bank',
      organization: 'HDFC Bank Ltd.',
      industry: 'Banking & Financial Services',
      defaultCategory: CategoryType.transactional,
    ),
    'HDFCBK': const BrandInfo(
      brandName: 'HDFC Bank',
      organization: 'HDFC Bank Ltd.',
      industry: 'Banking & Financial Services',
      defaultCategory: CategoryType.transactional,
    ),
    'HDFCBANK': const BrandInfo(
      brandName: 'HDFC Bank',
      organization: 'HDFC Bank Ltd.',
      industry: 'Banking & Financial Services',
      defaultCategory: CategoryType.transactional,
    ),
    'HDFC': const BrandInfo(
      brandName: 'HDFC Bank',
      organization: 'HDFC Bank Ltd.',
      industry: 'Banking & Financial Services',
      defaultCategory: CategoryType.transactional,
    ),
    'HDFCCC': const BrandInfo(
      brandName: 'HDFC Bank Cards',
      organization: 'HDFC Bank Ltd.',
      industry: 'Credit Cards',
      defaultCategory: CategoryType.transactional,
    ),
    'SBIINB': const BrandInfo(
      brandName: 'SBI Bank',
      organization: 'State Bank of India',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'SBIPSG': const BrandInfo(
      brandName: 'SBI Bank',
      organization: 'State Bank of India',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'SBMSMS': const BrandInfo(
      brandName: 'SBI Bank',
      organization: 'State Bank of India',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'SBICRD': const BrandInfo(
      brandName: 'SBI Card',
      organization: 'SBI Cards and Payment Services Ltd.',
      industry: 'Credit Cards',
      defaultCategory: CategoryType.transactional,
    ),
    'SBICARD': const BrandInfo(
      brandName: 'SBI Card',
      organization: 'SBI Cards and Payment Services Ltd.',
      industry: 'Credit Cards',
      defaultCategory: CategoryType.transactional,
    ),
    'ICICIB': const BrandInfo(
      brandName: 'ICICI Bank',
      organization: 'ICICI Bank Ltd.',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'ICICIK': const BrandInfo(
      brandName: 'ICICI Bank',
      organization: 'ICICI Bank Ltd.',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'ICICIN': const BrandInfo(
      brandName: 'ICICI Bank',
      organization: 'ICICI Bank Ltd.',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'ICICIP': const BrandInfo(
      brandName: 'ICICI Prudential',
      organization: 'ICICI Prudential Life Insurance',
      industry: 'Insurance',
      defaultCategory: CategoryType.transactional,
    ),
    'AXISBK': const BrandInfo(
      brandName: 'Axis Bank',
      organization: 'Axis Bank Ltd.',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'AXISBN': const BrandInfo(
      brandName: 'Axis Bank',
      organization: 'Axis Bank Ltd.',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'AXISIN': const BrandInfo(
      brandName: 'Axis Bank',
      organization: 'Axis Bank Ltd.',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'KOTAKB': const BrandInfo(
      brandName: 'Kotak Mahindra Bank',
      organization: 'Kotak Mahindra Bank Ltd.',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'KMBANK': const BrandInfo(
      brandName: 'Kotak Mahindra Bank',
      organization: 'Kotak Mahindra Bank Ltd.',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'PNBSMS': const BrandInfo(
      brandName: 'Punjab National Bank',
      organization: 'Punjab National Bank',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'PNBBNK': const BrandInfo(
      brandName: 'Punjab National Bank',
      organization: 'Punjab National Bank',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'BOBSMS': const BrandInfo(
      brandName: 'Bank of Baroda',
      organization: 'Bank of Baroda',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'CANBNK': const BrandInfo(
      brandName: 'Canara Bank',
      organization: 'Canara Bank',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'UNIONB': const BrandInfo(
      brandName: 'Union Bank of India',
      organization: 'Union Bank of India',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'INDBNK': const BrandInfo(
      brandName: 'IndusInd Bank',
      organization: 'IndusInd Bank Ltd.',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'YESBNK': const BrandInfo(
      brandName: 'Yes Bank',
      organization: 'Yes Bank Ltd.',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'IDFCFB': const BrandInfo(
      brandName: 'IDFC FIRST Bank',
      organization: 'IDFC FIRST Bank Ltd.',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'CITIBK': const BrandInfo(
      brandName: 'Citibank',
      organization: 'Citibank N.A.',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),
    'PAYTMB': const BrandInfo(
      brandName: 'Paytm Payments Bank',
      organization: 'Paytm Payments Bank Ltd.',
      industry: 'Fintech & Payments',
      defaultCategory: CategoryType.transactional,
    ),
    'PAYTM': const BrandInfo(
      brandName: 'Paytm',
      organization: 'One97 Communications Ltd.',
      industry: 'Fintech & Payments',
      defaultCategory: CategoryType.transactional,
    ),
    'PHONEPE': const BrandInfo(
      brandName: 'PhonePe',
      organization: 'PhonePe Pvt Ltd.',
      industry: 'Fintech & Payments',
      defaultCategory: CategoryType.transactional,
    ),
    'PHNPE': const BrandInfo(
      brandName: 'PhonePe',
      organization: 'PhonePe Pvt Ltd.',
      industry: 'Fintech & Payments',
      defaultCategory: CategoryType.transactional,
    ),
    'GPAY': const BrandInfo(
      brandName: 'Google Pay',
      organization: 'Google India Digital Services',
      industry: 'Fintech & Payments',
      defaultCategory: CategoryType.transactional,
    ),
    'CRED': const BrandInfo(
      brandName: 'CRED',
      organization: 'Dreamplug Technologies',
      industry: 'Fintech & Credit Cards',
      defaultCategory: CategoryType.transactional,
    ),

    // --- Government Services (Government) ---
    'UIDAI': const BrandInfo(
      brandName: 'UIDAI Aadhaar',
      organization: 'Unique Identification Authority of India',
      industry: 'Government Services',
      defaultCategory: CategoryType.government,
    ),
    'AADHAAR': const BrandInfo(
      brandName: 'UIDAI Aadhaar',
      organization: 'Unique Identification Authority of India',
      industry: 'Government Services',
      defaultCategory: CategoryType.government,
    ),
    'INCOME': const BrandInfo(
      brandName: 'Income Tax Department',
      organization: 'Ministry of Finance, Govt of India',
      industry: 'Government Services',
      defaultCategory: CategoryType.government,
    ),
    'ITDEPT': const BrandInfo(
      brandName: 'Income Tax Department',
      organization: 'Ministry of Finance, Govt of India',
      industry: 'Government Services',
      defaultCategory: CategoryType.government,
    ),
    'GOVTIN': const BrandInfo(
      brandName: 'Govt of India',
      organization: 'Ministry of Electronics and IT',
      industry: 'Government Services',
      defaultCategory: CategoryType.government,
    ),
    'GOVT': const BrandInfo(
      brandName: 'Govt of India',
      organization: 'Government of India',
      industry: 'Government Services',
      defaultCategory: CategoryType.government,
    ),
    'COWIN': const BrandInfo(
      brandName: 'CoWIN',
      organization: 'Ministry of Health and Family Welfare',
      industry: 'Government Services',
      defaultCategory: CategoryType.government,
    ),
    'DIGILK': const BrandInfo(
      brandName: 'DigiLocker',
      organization: 'Ministry of Electronics and IT',
      industry: 'Government Services',
      defaultCategory: CategoryType.government,
    ),
    'EPFOHO': const BrandInfo(
      brandName: 'EPFO',
      organization: 'Employees Provident Fund Organisation',
      industry: 'Government Services',
      defaultCategory: CategoryType.government,
    ),
    'VAHAN': const BrandInfo(
      brandName: 'Parivahan Sewa',
      organization: 'Ministry of Road Transport and Highways',
      industry: 'Government Services',
      defaultCategory: CategoryType.government,
    ),
    'PARIVH': const BrandInfo(
      brandName: 'Parivahan Sewa',
      organization: 'Ministry of Road Transport and Highways',
      industry: 'Government Services',
      defaultCategory: CategoryType.government,
    ),
    'INPOST': const BrandInfo(
      brandName: 'India Post',
      organization: 'Department of Posts, Govt of India',
      industry: 'Postal & Delivery',
      defaultCategory: CategoryType.service,
    ),
    'IPPB': const BrandInfo(
      brandName: 'India Post Payments Bank',
      organization: 'India Post Payments Bank Ltd.',
      industry: 'Banking',
      defaultCategory: CategoryType.transactional,
    ),

    // --- Food, Travel & Delivery (Service) ---
    'SWIGGY': const BrandInfo(
      brandName: 'Swiggy',
      organization: 'Bundl Technologies Pvt Ltd',
      industry: 'Food & Delivery',
      defaultCategory: CategoryType.service,
    ),
    'SWGIND': const BrandInfo(
      brandName: 'Swiggy',
      organization: 'Bundl Technologies Pvt Ltd',
      industry: 'Food & Delivery',
      defaultCategory: CategoryType.service,
    ),
    'ZOMATO': const BrandInfo(
      brandName: 'Zomato',
      organization: 'Zomato Ltd',
      industry: 'Food & Delivery',
      defaultCategory: CategoryType.service,
    ),
    'BLINKIT': const BrandInfo(
      brandName: 'Blinkit',
      organization: 'Blink Commerce Pvt Ltd',
      industry: 'Quick Commerce',
      defaultCategory: CategoryType.service,
    ),
    'ZEPTO': const BrandInfo(
      brandName: 'Zepto',
      organization: 'KiranaKart Technologies',
      industry: 'Quick Commerce',
      defaultCategory: CategoryType.service,
    ),
    'DOMINO': const BrandInfo(
      brandName: "Domino's Pizza",
      organization: 'Jubilant FoodWorks Ltd',
      industry: 'Food & Delivery',
      defaultCategory: CategoryType.service,
    ),
    'UBERIN': const BrandInfo(
      brandName: 'Uber',
      organization: 'Uber India Systems Pvt Ltd',
      industry: 'Ride & Mobility',
      defaultCategory: CategoryType.service,
    ),
    'UBER': const BrandInfo(
      brandName: 'Uber',
      organization: 'Uber India Systems Pvt Ltd',
      industry: 'Ride & Mobility',
      defaultCategory: CategoryType.service,
    ),
    'OLACAB': const BrandInfo(
      brandName: 'Ola',
      organization: 'ANI Technologies Pvt Ltd',
      industry: 'Ride & Mobility',
      defaultCategory: CategoryType.service,
    ),
    'OLAIN': const BrandInfo(
      brandName: 'Ola',
      organization: 'ANI Technologies Pvt Ltd',
      industry: 'Ride & Mobility',
      defaultCategory: CategoryType.service,
    ),
    'RAPIDO': const BrandInfo(
      brandName: 'Rapido',
      organization: 'Roppen Transportation',
      industry: 'Ride & Mobility',
      defaultCategory: CategoryType.service,
    ),
    'IRCTC': const BrandInfo(
      brandName: 'IRCTC',
      organization: 'Indian Railway Catering and Tourism Corp',
      industry: 'Travel & Railway',
      defaultCategory: CategoryType.service,
    ),
    'IRCTCi': const BrandInfo(
      brandName: 'IRCTC',
      organization: 'Indian Railway Catering and Tourism Corp',
      industry: 'Travel & Railway',
      defaultCategory: CategoryType.service,
    ),

    // --- E-Commerce ---
    'AMAZON': const BrandInfo(
      brandName: 'Amazon India',
      organization: 'Amazon Wholesale India Pvt Ltd',
      industry: 'E-Commerce',
      defaultCategory: CategoryType.service,
    ),
    'AMZIN': const BrandInfo(
      brandName: 'Amazon India',
      organization: 'Amazon Wholesale India Pvt Ltd',
      industry: 'E-Commerce',
      defaultCategory: CategoryType.service,
    ),
    'AMZPAY': const BrandInfo(
      brandName: 'Amazon Pay',
      organization: 'Amazon Pay India Pvt Ltd',
      industry: 'Fintech & Payments',
      defaultCategory: CategoryType.transactional,
    ),
    'FLPKRT': const BrandInfo(
      brandName: 'Flipkart',
      organization: 'Flipkart Internet Pvt Ltd',
      industry: 'E-Commerce',
      defaultCategory: CategoryType.service,
    ),
    'FLIPKT': const BrandInfo(
      brandName: 'Flipkart',
      organization: 'Flipkart Internet Pvt Ltd',
      industry: 'E-Commerce',
      defaultCategory: CategoryType.service,
    ),
    'MYNTRA': const BrandInfo(
      brandName: 'Myntra',
      organization: 'Myntra Designs Pvt Ltd',
      industry: 'Fashion & E-Commerce',
      defaultCategory: CategoryType.service,
    ),

    // --- Telecom & Utilities (Service) ---
    'JIOINF': const BrandInfo(
      brandName: 'Jio',
      organization: 'Reliance Jio Infocomm Ltd',
      industry: 'Telecom',
      defaultCategory: CategoryType.service,
    ),
    'JIO': const BrandInfo(
      brandName: 'Jio',
      organization: 'Reliance Jio Infocomm Ltd',
      industry: 'Telecom',
      defaultCategory: CategoryType.service,
    ),
    'AIRTEL': const BrandInfo(
      brandName: 'Airtel',
      organization: 'Bharti Airtel Ltd',
      industry: 'Telecom',
      defaultCategory: CategoryType.service,
    ),
    'AIRINF': const BrandInfo(
      brandName: 'Airtel',
      organization: 'Bharti Airtel Ltd',
      industry: 'Telecom',
      defaultCategory: CategoryType.service,
    ),
    'VODAIN': const BrandInfo(
      brandName: 'Vi (Vodafone Idea)',
      organization: 'Vodafone Idea Ltd',
      industry: 'Telecom',
      defaultCategory: CategoryType.service,
    ),
    'VIINFO': const BrandInfo(
      brandName: 'Vi (Vodafone Idea)',
      organization: 'Vodafone Idea Ltd',
      industry: 'Telecom',
      defaultCategory: CategoryType.service,
    ),
    'BSNLIN': const BrandInfo(
      brandName: 'BSNL',
      organization: 'Bharat Sanchar Nigam Ltd',
      industry: 'Telecom',
      defaultCategory: CategoryType.service,
    ),
    'TATAPLY': const BrandInfo(
      brandName: 'Tata Play',
      organization: 'Tata Play Ltd',
      industry: 'DTH & Entertainment',
      defaultCategory: CategoryType.service,
    ),
    'ACTFIB': const BrandInfo(
      brandName: 'ACT Fibernet',
      organization: 'Atria Convergence Technologies',
      industry: 'Broadband & Internet',
      defaultCategory: CategoryType.service,
    ),
  };

  void _loadBuiltinBrands() {
    _cache.addAll(_builtinBrands);
  }

  /// Synchronously looks up brand info for [cleanHeader].
  BrandInfo? resolveSync(String cleanHeader) {
    final key = cleanHeader.toUpperCase().trim();
    return _cache[key];
  }

  /// Asynchronously looks up brand info with database backing.
  Future<BrandInfo?> resolve(String cleanHeader) async {
    final key = cleanHeader.toUpperCase().trim();
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    if (repository != null) {
      try {
        final meta = await repository!.getMetadataForHeader(key);
        if (meta != null) {
          final info = BrandInfo(
            brandName: meta.brand,
            organization: meta.organization,
            industry: meta.industry,
            defaultCategory: _inferCategoryFromIndustry(meta.industry),
          );
          _cache[key] = info;
          return info;
        }
      } catch (_) {
        // Fallback safely
      }
    }

    return null;
  }

  /// Infers default category from industry string.
  CategoryType? _inferCategoryFromIndustry(String industry) {
    final lower = industry.toLowerCase();
    if (lower.contains('bank') ||
        lower.contains('financ') ||
        lower.contains('credit') ||
        lower.contains('loan') ||
        lower.contains('pay')) {
      return CategoryType.transactional;
    }
    if (lower.contains('govt') ||
        lower.contains('government') ||
        lower.contains('tax') ||
        lower.contains('aadhaar') ||
        lower.contains('ministry')) {
      return CategoryType.government;
    }
    if (lower.contains('deliver') ||
        lower.contains('food') ||
        lower.contains('telecom') ||
        lower.contains('utilit') ||
        lower.contains('travel') ||
        lower.contains('ride')) {
      return CategoryType.service;
    }
    return null;
  }

  /// Preloads or updates a brand in the resolver cache.
  void cacheBrand(String header, BrandInfo info) {
    _cache[header.toUpperCase().trim()] = info;
  }

  /// Resolves a display brand name with a clean fallback.
  String getDisplayName(String cleanHeader, {String? rawSender}) {
    final info = resolveSync(cleanHeader);
    if (info != null) return info.brandName;

    // Fallback: title-case alphanumeric header or rawSender
    if (cleanHeader.isNotEmpty && cleanHeader != 'UNKNOWN') {
      return cleanHeader;
    }
    return rawSender ?? 'Unknown';
  }
}
