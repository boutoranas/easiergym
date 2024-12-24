import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/snack_bar.dart';

class PoliciesPage extends StatelessWidget {
  final String policy;
  const PoliciesPage({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    String policyText = '';
    if (policy == 'Privacy policy') {
      policyText = '''Privacy Policy for Easier Gym Mobile App

Effective Date: June 14th 2023

This Privacy Policy describes how Easier Gym ("we," "our," or "us") collects, uses, and discloses personal information when you use our mobile application ("Easier Gym" or the "App"). By accessing or using the App, you agree to the terms and conditions of this Privacy Policy. Please read this Privacy Policy carefully.

1. Information We Collect

1.1 Personal Information:
When you use the Easier Gym App, we may collect the following personal information:

- Information you provide during account registration, such as your name, email address, and contact details.
- Information you provide when using the App's features, such as fitness goals, exercise preferences, and workout history.
- Information you provide if you contact us for support or feedback.

1.2 Usage Information:
We may collect non-personal information about how you interact with the App, including:

- App usage data, such as the features you use, the time and duration of your activities, and crash logs.
- Device information, including device type, operating system, unique device identifiers, and mobile network information.
- Log data, such as your IP address, browser type, and pages visited.

1.3 Payment Information:
If you choose to subscribe to our premium service, we may collect payment information, including credit card details, necessary to process your subscription.

2. How We Use Your Information

2.1 Provide and Improve Services:
We use the collected information to provide and improve the Easier Gym App, personalize your experience, and enhance its features. This includes analyzing usage patterns, delivering tailored content, and optimizing the App's performance.

2.2 User Support and Communication:
We may use your information to respond to your inquiries, provide customer support, and communicate important updates, such as changes to our terms or policies.

2.3 Subscription Processing:
If you subscribe to our premium service, we may use your payment information to process and manage your subscription, including renewals and cancellations.

2.4 Legal Compliance:
We may use your information to comply with applicable laws, regulations, and legal processes, such as responding to a court order or governmental request.

3. How We Share Your Information

3.1 Service Providers:
We may share your personal information with third-party service providers that assist us in providing and improving the App. These service providers are obligated to protect your information and are prohibited from using it for any other purpose.

3.2 Aggregated or Anonymized Data:
We may share aggregated or anonymized data that does not identify you personally, for statistical analysis, research, or other purposes.

3.3 Business Transfers:
If Easier Gym is involved in a merger, acquisition, or sale of assets, your personal information may be transferred as part of that transaction. We will notify you via email or through a prominent notice on the App if any such event occurs.

3.4 Legal Requirements:
We may disclose your information if we believe it is necessary to comply with applicable laws, regulations, legal processes, or enforceable governmental requests.

4. Data Security

We take appropriate technical and organizational measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction. However, please note that no method of transmission over the internet or electronic storage is completely secure. Therefore, we cannot guarantee absolute security of your information.

5. Third-Party Links and Services

The App may contain links to third-party websites, products, or services that are not owned or controlled by us. This Privacy Policy does not apply to any third-party websites, products, or services. We encourage you to review the privacy policies of those third parties before providing any personal information.

6. Children's Privacy

The Easier Gym App is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If we discover that we have collected personal information from a child under 13, we will promptly delete that information.

7. Changes to this Privacy Policy

We reserve the right to modify or update this Privacy Policy at any time. We will notify you of any material changes by posting the updated Privacy Policy within the App or by sending you an email. Your continued use of the App after the effective date of the revised Privacy Policy constitutes your acceptance of the changes.

8. Contact Us

If you have any questions or concerns regarding this Privacy Policy or our data practices, please contact us at easiergym@gmail.com or by clicking on the mail icon above.

Please note that this Privacy Policy is provided for informational purposes only and does not constitute legal advice. For legal advice regarding privacy matters, please consult with a qualified attorney.''';
    } else if (policy == 'Terms of use') {
      policyText = '''Terms of Use for Easier Gym Mobile App

Effective Date: June 14th 2023

These Terms of Use ("Terms") govern your use of the Easier Gym mobile application ("Easier Gym" or the "App") provided by the app developer ("we," "us," or "our"). By accessing or using the App, you agree to be bound by these Terms. If you do not agree with these Terms, you should not use the App.

1. App Usage

1.1 Eligibility:
You must be at least 13 years old to use the Easier Gym App. By using the App, you represent and warrant that you are at least 13 years old.

1.2 Account Creation:
To access certain features of the App, you may be required to create an account. You are responsible for providing accurate and complete information during the account registration process. You are also responsible for maintaining the confidentiality of your account credentials and for any activities or actions that occur under your account. You agree to notify us immediately of any unauthorized use of your account.

1.3 Prohibited Activities:
When using the Easier Gym App, you agree not to:

- Violate any applicable laws, regulations, or third-party rights.
- Use the App for any unlawful, unauthorized, or fraudulent purposes.
- Engage in any activity that could interfere with or disrupt the operation or security of the App.
- Upload or transmit any content that is unlawful, defamatory, obscene, or infringing upon intellectual property rights.
- Attempt to gain unauthorized access to any portion of the App or its related systems or networks.
- Use the App to solicit or promote any commercial activities without our prior written consent.

2. Intellectual Property

2.1 Ownership:
The Easier Gym App, including its content, features, and design, is owned by the app developer and protected by intellectual property laws. You acknowledge and agree that all rights, title, and interest in the App are and will remain the exclusive property of the app developer.

2.2 Limited License:
Subject to your compliance with these Terms, the app developer grants you a limited, non-exclusive, non-transferable, and revocable license to use the App for personal, non-commercial purposes.

2.3 Restrictions:
You may not copy, modify, distribute, sell, lease, reverse engineer, or create derivative works of the App or any part thereof without the app developer's prior written consent.

3. Privacy

Your privacy is important to us. Please refer to our Privacy Policy to understand how we collect, use, and disclose your personal information when you use the App.

4. Subscriptions

4.1 Subscription Service:
Easier Gym offers a subscription service that provides access to additional features and content within the App. The subscription details, including the pricing, duration, and payment terms, are specified within the App's subscription section.

4.2 Billing and Payment:
If you choose to subscribe to the premium service, you authorize us to charge the applicable subscription fees to your selected payment method. You agree to provide accurate and up-to-date billing information and promptly update it if any changes occur. All payments are non-refundable, and any unused portion of a free trial period, if offered, will be forfeited upon subscription purchase.

4.3 Subscription Cancellation:
You may cancel your subscription at any time by following the cancellation process provided within the App. Cancellation will be effective at the end of the current billing cycle, and you will retain access to the premium features until that time.

5. Third-Party Links and Services

The Easier Gym App may contain links to third-party websites, products, or services that are not owned or controlled by us. We do not endorse or assume any responsibility for the content, privacy practices, or actions of these third parties. You acknowledge and agree that we shall not be liable for any damages or losses arising from your use of any third-party websites, products, or services.

6. Disclaimer of Warranties

THE EASIER GYM APP IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS, WITHOUT ANY WARRANTIES OF ANY KIND, WHETHER EXPRESS OR IMPLIED. TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, WE DISCLAIM ALL WARRANTIES, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.

7. Limitation of Liability

TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, WE SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES ARISING OUT OF OR IN CONNECTION WITH YOUR USE OF THE EASIER GYM APP, WHETHER BASED ON CONTRACT, TORT, NEGLIGENCE, STRICT LIABILITY, OR OTHERWISE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

8. Modifications and Termination

We reserve the right to modify or terminate the Easier Gym App at any time without prior notice. We may also update these Terms from time to time. Your continued use of the App after the effective date of the revised Terms constitutes your acceptance of the changes.

9. Governing Law and Jurisdiction

These Terms shall be governed by and construed in accordance with the laws of Morocco. Any disputes arising out of or relating to these Terms or your use of the Easier Gym App shall be exclusively resolved in the courts of Morocco.

10. Contact Us

If you have any questions or concerns regarding these Terms, please contact us at easiergym@gmail.com or by clicking on the mail icon above.

Please note that these Terms are provided for informational purposes only and do not constitute legal advice. For legal advice regarding terms of use, please consult with a qualified attorney.''';
    }
    return Scaffold(
      appBar: customAppBar(
          title: policy,
          leading: null,
          actions: [
            IconButton(
                tooltip: 'Contact',
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(),
                onPressed: () async {
                  String? encodeQueryParameters(Map<String, String> params) {
                    return params.entries
                        .map((MapEntry<String, String> e) =>
                            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                        .join('&');
                  }

                  final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: 'easiergym@gmail.com',
                      query: encodeQueryParameters(<String, String>{
                        'subject': 'Questions/queries about the $policy',
                        'body': '',
                      }));
                  if (await canLaunchUrl(emailUri)) {
                    try {
                      launchUrl(emailUri);
                    } catch (e) {
                      showSnackBar(context,
                          "Could not launch url, please try to contact us at easiergym@gmail.com");
                    }
                  } else {
                    showSnackBar(context,
                        "Could not launch url, please try to contact us at easiergym@gmail.com");
                  }
                },
                icon: const Icon(Icons.mail)),
          ],
          context: context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Const.horizontalPagePadding,
            vertical: 15,
          ),
          child: Column(
            children: [
              Text(policyText),
            ],
          ),
        ),
      ),
    );
  }
}
