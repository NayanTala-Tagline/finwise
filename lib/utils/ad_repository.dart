import 'package:ad_manager/ad_manager.dart';

class AdRepository {
  static void showConsentUMP() {
    final params = ConsentRequestParameters(
      /*consentDebugSettings: ConsentDebugSettings(
        testIdentifiers: const ['B3EEABB8EE11C2BE770B684D95219ECB'],
        debugGeography: DebugGeography.debugGeographyEea)*/
    );
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          loadForm();
        }
      },
      (FormError error) {
        // Handle the error
      },
    );
  }

  static void loadForm() {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        var status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show((FormError? formError) {
            loadForm();
          });
        }
      },
      (formError) {
        // Handle the error
      },
    );
  }
}
