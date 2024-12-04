import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.blue, // Customize color as needed
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Your Privacy Policy Here\n\n'
          'This Privacy Policy describes how your personal information is collected, used, and shared when you visit or make a purchase from example.com (the “Site”).\n\n'
          'PERSONAL INFORMATION WE COLLECT\n\n'
          'When you visit the Site, we automatically collect certain information about your device, including information about your web browser, IP address, time zone, and some of the cookies that are installed on your device. Additionally, as you browse the Site, we collect information about the individual web pages or products that you view, what websites or search terms referred you to the Site, and information about how you interact with the Site. We refer to this automatically-collected information as “Device Information.”\n\n'
          'We collect Device Information using the following technologies: \n'
          '- “Cookies” are data files that are placed on your device or computer and often include an anonymous unique identifier. \n'
          '- “Log files” track actions occurring on the Site, and collect data including your IP address, browser type, Internet service provider, referring/exit pages, and date/time stamps. \n'
          '- “Web beacons,” “tags,” and “pixels” are electronic files used to record information about how you browse the Site.\n\n'
          'HOW DO WE USE YOUR PERSONAL INFORMATION?\n\n'
          'We use the Order Information that we collect generally to fulfill any orders placed through the Site (including processing your payment information, arranging for shipping, and providing you with invoices and/or order confirmations). Additionally, we use this Order Information to: \n'
          '- Communicate with you;\n'
          '- Screen our orders for potential risk or fraud; and\n'
          '- When in line with the preferences you have shared with us, provide you with information or advertising relating to our products or services.\n\n'
          'SHARING YOUR PERSONAL INFORMATION\n\n'
          'We share your Personal Information with third parties to help us use your Personal Information, as described above. For example, we use Shopify to power our online store--you can read more about how Shopify uses your Personal Information here: https://www.shopify.com/legal/privacy.\n\n'
          'Finally, we may also share your Personal Information to comply with applicable laws and regulations, to respond to a subpoena, search warrant or other lawful request for information we receive, or to otherwise protect our rights.\n\n'
          'CHANGES\n\n'
          'We may update this privacy policy from time to time in order to reflect, for example, changes to our practices or for other operational, legal, or regulatory reasons.\n\n'
          'CONTACT US\n\n'
          'For more information about our privacy practices, if you have questions, or if you would like to make a complaint, please contact us by e-mail at privacy@example.com or by mail using the details provided below:\n\n'
          '123 Example St., City, State, Zip Code\n\n'
          '--- End of Privacy Policy ---',
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
