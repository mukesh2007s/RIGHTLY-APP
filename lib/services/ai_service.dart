import 'dart:async';

/// AI Service for Legal Assistance
/// Provides intelligent responses to legal queries
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  bool _isOnlineMode = true;
  String _selectedLanguage = 'en';
  AIResponseMode _responseMode = AIResponseMode.balanced;

  // AI Response Mode
  void setResponseMode(AIResponseMode mode) => _responseMode = mode;
  AIResponseMode get responseMode => _responseMode;

  // Online/Offline Mode
  void setOnlineMode(bool value) => _isOnlineMode = value;
  bool get isOnlineMode => _isOnlineMode;

  // Language
  void setLanguage(String languageCode) => _selectedLanguage = languageCode;
  String get language => _selectedLanguage;

  /// Get AI response for a legal query
  Future<AIResponse> getResponse(String query) async {
    try {
      // Simulate network delay
      await Future.delayed(Duration(milliseconds: _isOnlineMode ? 1500 : 800));

      // Analyze query intent
      final intent = _analyzeIntent(query);
      
      // Get response based on intent
      final response = _generateResponse(query, intent);
      
      return AIResponse(
        success: true,
        message: response,
        intent: intent,
        confidence: 0.95,
        sources: _getSourcesForIntent(intent),
      );
    } catch (e) {
      return AIResponse(
        success: false,
        message: 'I apologize, but I encountered an error. Please try again.',
        intent: QueryIntent.unknown,
        confidence: 0.0,
        sources: [],
      );
    }
  }

  QueryIntent _analyzeIntent(String query) {
    final lowercaseQuery = query.toLowerCase();
    
    if (lowercaseQuery.contains('arrest') || lowercaseQuery.contains('police')) {
      return QueryIntent.criminalRights;
    } else if (lowercaseQuery.contains('consumer') || 
               lowercaseQuery.contains('refund') || 
               lowercaseQuery.contains('product')) {
      return QueryIntent.consumerRights;
    } else if (lowercaseQuery.contains('fundamental') || 
               lowercaseQuery.contains('constitution')) {
      return QueryIntent.fundamentalRights;
    } else if (lowercaseQuery.contains('property') || 
               lowercaseQuery.contains('rent') ||
               lowercaseQuery.contains('tenant')) {
      return QueryIntent.propertyRights;
    } else if (lowercaseQuery.contains('women') || 
               lowercaseQuery.contains('harassment') ||
               lowercaseQuery.contains('domestic')) {
      return QueryIntent.womenRights;
    } else if (lowercaseQuery.contains('labor') || 
               lowercaseQuery.contains('wage') ||
               lowercaseQuery.contains('employment')) {
      return QueryIntent.laborRights;
    } else if (lowercaseQuery.contains('bail')) {
      return QueryIntent.bail;
    } else if (lowercaseQuery.contains('fir') || lowercaseQuery.contains('complaint')) {
      return QueryIntent.fir;
    }
    
    return QueryIntent.general;
  }

  String _generateResponse(String query, QueryIntent intent) {
    switch (intent) {
      case QueryIntent.criminalRights:
        return _getCriminalRightsResponse();
      case QueryIntent.consumerRights:
        return _getConsumerRightsResponse();
      case QueryIntent.fundamentalRights:
        return _getFundamentalRightsResponse();
      case QueryIntent.propertyRights:
        return _getPropertyRightsResponse();
      case QueryIntent.womenRights:
        return _getWomenRightsResponse();
      case QueryIntent.laborRights:
        return _getLaborRightsResponse();
      case QueryIntent.bail:
        return _getBailResponse();
      case QueryIntent.fir:
        return _getFIRResponse();
      default:
        return _getGeneralResponse();
    }
  }

  String _getCriminalRightsResponse() {
    if (_responseMode == AIResponseMode.concise) {
      return 'During arrest: Right to know grounds, right to lawyer, right to magistrate within 24 hours, right to inform family.';
    } else if (_responseMode == AIResponseMode.comprehensive) {
      return '''Your rights during arrest under Indian law include:

1. Right to Know Grounds of Arrest (Article 22(1)):
   - Police must inform you why you are being arrested
   - They cannot arrest without valid reason

2. Right to Legal Counsel (Article 22(1)):
   - You can consult a lawyer of your choice
   - Free legal aid is available if you cannot afford one

3. Right Against Illegal Detention (Section 57 CrPC):
   - Must be produced before magistrate within 24 hours
   - Detention beyond this is unconstitutional

4. Right to Inform Someone (Section 50A CrPC):
   - Police must inform your family or friend
   - You can make one phone call

5. Right Against Self-Incrimination (Article 20(3)):
   - You cannot be forced to give evidence against yourself
   - You have the right to remain silent

6. Right to Medical Examination:
   - You can request medical examination
   - Any injuries must be documented

Remember: Stay calm, do not resist, and immediately contact a lawyer.''';
    }
    return '''Your key rights during arrest include:

• Right to know the grounds of arrest (Article 22)
• Right to consult a lawyer of your choice
• Right to be produced before a magistrate within 24 hours
• Right to inform a relative or friend (Section 50A CrPC)
• Right against self-incrimination
• Right to medical examination

If arrested, stay calm and exercise these rights. You can contact legal aid services if needed.''';
  }

  String _getConsumerRightsResponse() {
    return '''Under the Consumer Protection Act 2019, you have these rights:

1. Right to Safety - Protection from dangerous goods
2. Right to Information - Know product details
3. Right to Choose - Access to variety of goods
4. Right to be Heard - Voice concerns at forums
5. Right to Redressal - Seek remedy for issues
6. Right to Consumer Education

For complaints, you can approach:
• District Consumer Forum (up to ₹1 crore)
• State Consumer Commission (₹1-10 crore)
• National Consumer Commission (above ₹10 crore)

File online at: consumerhelpline.gov.in''';
  }

  String _getFundamentalRightsResponse() {
    return '''Fundamental Rights under the Indian Constitution (Part III):

1. Right to Equality (Articles 14-18)
   • Equal protection of laws
   • No discrimination

2. Right to Freedom (Articles 19-22)
   • Speech, expression, assembly
   • Movement, residence, profession

3. Right Against Exploitation (Articles 23-24)
   • No forced labor
   • No child labor in hazardous jobs

4. Right to Freedom of Religion (Articles 25-28)
   • Practice any religion
   • Manage religious affairs

5. Cultural & Educational Rights (Articles 29-30)
   • Protect culture and language
   • Minorities can run institutions

6. Right to Constitutional Remedies (Article 32)
   • Approach Supreme Court directly''';
  }

  String _getPropertyRightsResponse() {
    return '''Property rights in India are governed by various laws:

1. Transfer of Property Act 1882
   • Sale, mortgage, lease, gift rules
   • Registration requirements

2. Tenant Rights (Rent Control Acts)
   • Protection against eviction
   • Fair rent determination
   • Right to essential services

3. Registration Act 1908
   • Mandatory for property above ₹100
   • Within 4 months of execution

4. Succession Laws
   • Hindu Succession Act for Hindus
   • Indian Succession Act for Christians
   • Muslim Personal Law for Muslims

Tip: Always verify property title and get legal opinion before purchase.''';
  }

  String _getWomenRightsResponse() {
    return '''Key laws protecting women's rights in India:

1. Protection of Women from Domestic Violence Act 2005
   • Protection orders, residence rights
   • Monetary relief, custody rights

2. Sexual Harassment at Workplace (POSH) Act 2013
   • Internal Complaints Committee mandatory
   • Complaint within 3 months

3. Maternity Benefit Act 1961
   • 26 weeks paid leave
   • Work from home option
   • Crèche facility

4. Dowry Prohibition Act 1961
   • Giving/taking dowry is illegal
   • Imprisonment up to 5 years

5. IPC Section 498A
   • Against cruelty by husband/relatives

Helplines: Women Helpline 181, NCW 7827-170-170''';
  }

  String _getLaborRightsResponse() {
    return '''Your labor rights under Indian law:

1. Minimum Wages Act 1948
   • Cannot be paid below minimum wage
   • Varies by state and skill level

2. Payment of Wages Act 1936
   • Timely payment (before 7th/10th)
   • Limited deductions allowed

3. Payment of Gratuity Act 1972
   • After 5 years of service
   • Formula: 15/26 × last salary × years

4. EPF Act 1952
   • 12% contribution (employee + employer)
   • Retirement security

5. Employees' State Insurance Act 1948
   • Medical benefits
   • Maternity, disability coverage

For complaints: Labour Commissioner or Shram Suvidha Portal''';
  }

  String _getBailResponse() {
    return '''Bail provisions under CrPC:

1. Bailable Offences (Section 436)
   • Bail as a matter of right
   • Police can grant bail

2. Non-Bailable Offences (Section 437)
   • Court's discretion
   • Factors: Nature of offence, evidence, flight risk

3. Anticipatory Bail (Section 438)
   • Before arrest
   • Apply in High Court/Sessions Court
   • Valid reason of apprehension needed

4. Default Bail (Section 167)
   • If chargesheet not filed in 60/90 days
   • Automatic right

Documents needed: ID proof, address proof, surety documents.
Contact a lawyer immediately for bail application.''';
  }

  String _getFIRResponse() {
    return '''FIR (First Information Report) Guide:

1. What is FIR?
   • First step in criminal investigation
   • For cognizable offences

2. How to File:
   • Visit nearest police station
   • Give written or oral complaint
   • Get acknowledgment with FIR number

3. Your Rights:
   • Free copy of FIR
   • Can file Zero FIR anywhere
   • E-FIR for certain offences

4. If Police Refuses:
   • Complain to SP/Commissioner
   • Approach Magistrate under Section 156(3)
   • File online complaint

5. Time Limit:
   • No time limit for filing
   • But delays need explanation

Remember: Keep all evidence safe and note witness details.''';
  }

  String _getGeneralResponse() {
    return '''Thank you for your query. I'm Rightly, your AI legal assistant.

I can help you with:
• Fundamental Rights (Constitution)
• Criminal Law & Police Rights
• Consumer Protection
• Women's Rights & Safety
• Property & Tenant Laws
• Labor & Employment Laws
• Bail & FIR Procedures

Please ask a specific question about any of these topics, and I'll provide detailed guidance based on Indian law.

Remember: This is general legal information, not legal advice. For specific cases, please consult a qualified lawyer.''';
  }

  List<String> _getSourcesForIntent(QueryIntent intent) {
    switch (intent) {
      case QueryIntent.criminalRights:
        return ['Article 20-22 Constitution', 'CrPC Section 41-60'];
      case QueryIntent.consumerRights:
        return ['Consumer Protection Act 2019'];
      case QueryIntent.fundamentalRights:
        return ['Constitution Part III', 'Articles 12-35'];
      case QueryIntent.propertyRights:
        return ['Transfer of Property Act 1882', 'Registration Act 1908'];
      case QueryIntent.womenRights:
        return ['DV Act 2005', 'POSH Act 2013', 'IPC Section 498A'];
      case QueryIntent.laborRights:
        return ['Labour Codes 2020', 'EPF Act 1952'];
      case QueryIntent.bail:
        return ['CrPC Section 436-450'];
      case QueryIntent.fir:
        return ['CrPC Section 154-157'];
      default:
        return ['Indian Constitution', 'Indian Penal Code'];
    }
  }
}


/// AI Response Model
class AIResponse {
  final bool success;
  final String message;
  final QueryIntent intent;
  final double confidence;
  final List<String> sources;

  AIResponse({
    required this.success,
    required this.message,
    required this.intent,
    required this.confidence,
    required this.sources,
  });
}


/// Query Intent Types
enum QueryIntent {
  criminalRights,
  consumerRights,
  fundamentalRights,
  propertyRights,
  womenRights,
  laborRights,
  bail,
  fir,
  general,
  unknown,
}


/// AI Response Mode
enum AIResponseMode {
  concise,
  balanced,
  comprehensive,
}
