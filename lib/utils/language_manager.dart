import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, telugu }

class LanguageManager extends ValueNotifier<AppLanguage> {
  LanguageManager._() : super(AppLanguage.english) {
    _loadSavedLanguage();
  }

  static final LanguageManager instance = LanguageManager._();

  static const String _prefKey = 'app_language';

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == 'telugu') {
        value = AppLanguage.telugu;
      }
    } catch (_) {
      // If SharedPreferences fails, default to English
    }
  }

  void toggleLanguage() {
    final newLang = value == AppLanguage.english
        ? AppLanguage.telugu
        : AppLanguage.english;
    setLanguage(newLang);
  }

  void setLanguage(AppLanguage language) {
    value = language;
    _persist(language);
  }

  Future<void> _persist(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefKey,
        language == AppLanguage.telugu ? 'telugu' : 'english',
      );
    } catch (_) {}
  }

  bool get isTelugu => value == AppLanguage.telugu;

  String getText(String key) {
    if (isTelugu) {
      return _teluguStrings[key] ?? _englishStrings[key] ?? key;
    }
    return _englishStrings[key] ?? key;
  }

  static const Map<String, String> _englishStrings = {
    'app_title': 'RationTrack',
    'scan_qr': 'SCAN QR',
    'home': 'Home',
    'search': 'Search',
    'reports': 'Reports',
    'total_cards': 'Total Cards',
    'received': 'Received',
    'pending': 'Pending',
    'import_excel': 'Import Excel Data',
    'add_beneficiary': 'Add Beneficiary',
    'search_card': 'Search Ration Card',
    'pending_list': 'Pending Beneficiary List',
    'reports_export': 'Reports & Exports',
    'backup_restore': 'Backup & Restore',
    'cycle_open': 'Distribution Open',
    'cycle_closed': 'Distribution Closed',
    'align_qr': 'Align QR code inside box',
    'manual_entry': 'Enter Card Number Manually',
    'card_number': 'Rice Card Number',
    'head_name': 'Head of Family',
    'relation': 'Relation',
    'mobile': 'Mobile Number',
    'category': 'Card Category',
    'units': 'Family Units',
    'rice_quota': 'Rice Quota (kg)',
    'mark_received': 'MARK AS RECEIVED',
    'already_received': 'RATION ALREADY RECEIVED',
    'history': 'Distribution History',
    'card_not_found': 'Card Not Found',
    'language': 'Language / భాష',
    'select_language': 'Select Language / భాషను ఎంచుకోండి',
    'english': 'English',
    'telugu': 'తెలుగు (Telugu)',
    'history_dashboard': 'Monthly History',
    'monthly_distribution': 'Monthly Distribution',
    'month_details': 'Month-wise Details',
    'total_distributed': 'Distributed',
    'total_rice_kg': 'Rice (kg)',
    'active_months': 'Active Months',
    'rice_distributed': 'Rice Distributed',
    'no_history_data': 'No distribution data yet',
  };

  static const Map<String, String> _teluguStrings = {
    'app_title': 'రేషన్ హాజరు వ్యవస్థ',
    'scan_qr': 'క్యూఆర్‌ స్కాన్ చేయండి',
    'home': 'హోమ్',
    'search': 'శోధన',
    'reports': 'నివేదికలు',
    'total_cards': 'మొత్తం కార్డ్‌లు',
    'received': 'పంపిణీ చేసినవి',
    'pending': 'పెండింగ్‌లో ఉన్నవి',
    'import_excel': 'ఎక్సెల్ డేటా ఇంపోర్ట్',
    'add_beneficiary': 'కొత్త లబ్ధిదారుని జోడించు',
    'search_card': 'రైస్ కార్డ్ శోధన',
    'pending_list': 'పెండింగ్ లబ్ధిదారుల జాబితా',
    'reports_export': 'నివేదికలు & ఎగుమతి',
    'backup_restore': 'డేటా బ్యాకప్ & పునరుద్ధరణ',
    'cycle_open': 'రేషన్ పంపిణీ ప్రారంభమైంది',
    'cycle_closed': 'రేషన్ పంపిణీ ముగిసింది',
    'align_qr': 'క్యూఆర్ కోడ్‌ను బాక్స్‌లో సరిపోల్చండి',
    'manual_entry': 'కార్డ్ సంఖ్య నమోదు చేయండి',
    'card_number': 'రైస్ కార్డ్ సంఖ్య',
    'head_name': 'కుటుంబ యజమాని పేరు',
    'relation': 'సంబంధం',
    'mobile': 'ఫోన్ సంఖ్య',
    'category': 'కార్డ్ రకం',
    'units': 'కుటుంబ సభ్యుల సంఖ్య',
    'rice_quota': 'బియ్యం కోటా (కిలోలు)',
    'mark_received': 'రేషన్ పంపిణీ నమోదు చేయండి',
    'already_received': 'ఈ నెల రేషన్ ఇప్పటికే అందించబడింది',
    'history': 'పంపిణీ చరిత్ర',
    'card_not_found': 'రైస్ కార్డ్ కనుగొనబడలేదు',
    'language': 'భాష / Language',
    'select_language': 'భాషను ఎంచుకోండి / Select Language',
    'english': 'English',
    'telugu': 'తెలుగు (Telugu)',
    'history_dashboard': 'నెలవారీ చరిత్ర',
    'monthly_distribution': 'నెలవారీ పంపిణీ',
    'month_details': 'నెలవారీ వివరాలు',
    'total_distributed': 'పంపిణీ',
    'total_rice_kg': 'బియ్యం (కిలో)',
    'active_months': 'యాక్టివ్ నెలలు',
    'rice_distributed': 'పంపిణీ చేసిన బియ్యం',
    'no_history_data': 'ఇంకా పంపిణీ డేటా లేదు',
  };
}
