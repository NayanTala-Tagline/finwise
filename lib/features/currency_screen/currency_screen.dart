// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../extension/ext_context.dart';
// import '../../utils/app_size.dart';
// import '../../utils/navigation_helper.dart';
// import '../../widgets/app_button.dart';
// import '../../widgets/common_appbar.dart';
// import '../tools_module/widgets/section_title.dart';
// import 'model/currency_item.dart';
// import 'provider/currency_provider.dart';
//
// class CurrencyScreen extends StatefulWidget {
//   const CurrencyScreen({super.key});
//
//   @override
//   State<CurrencyScreen> createState() => _CurrencyScreenState();
// }
//
// class _CurrencyScreenState extends State<CurrencyScreen> {
//   late CurrencyItem _pending;
//
//   @override
//   void initState() {
//     super.initState();
//     _pending = context.read<CurrencyProvider>().selected;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.themeColors;
//     final textColors = context.themeTextColors;
//
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, _) {
//         if (didPop) return;
//         NavigationHelper().handleBackPress(context);
//       },
//       child: Scaffold(
//       backgroundColor: const Color(0xffFFFAF9),
//       appBar: CommonAppBar(titleText: context.l10n.currencyTitle),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.fromLTRB(
//                 AppSize.w20,
//                 AppSize.h20,
//                 AppSize.w20,
//                 AppSize.h12,
//               ),
//               children: [
//                 SectionTitle(title: context.l10n.currencyListTitle),
//                 SizedBox(height: AppSize.h16),
//                 ...CurrencyItem.all.map((item) {
//                   final isSelected = item.code == _pending.code;
//                   return Padding(
//                     padding: EdgeInsets.only(bottom: AppSize.h10),
//                     child: GestureDetector(
//                       onTap: () => setState(() => _pending = item),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: AppSize.w16,
//                           vertical: AppSize.h14,
//                         ),
//                         decoration: BoxDecoration(
//                           color: colors.whiteColor,
//                           borderRadius: BorderRadius.circular(AppSize.r12),
//                           border: Border.all(
//                             color: isSelected
//                                 ? colors.primary
//                                 : Colors.transparent,
//                             width: 1.5,
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: const Color(0xffFF8F4A)
//                                   .withValues(alpha: 0.15),
//                               blurRadius: AppSize.r16,
//                               spreadRadius: AppSize.sp1,
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             // Symbol
//                             SizedBox(
//                               width: AppSize.w48,
//                               child: Text(
//                                 item.symbol,
//                                 style: context.textTheme.titleMedium?.copyWith(
//                                   fontSize: AppSize.sp16,
//                                   fontWeight: FontWeight.w600,
//                                   color: textColors.textColor,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: AppSize.w12),
//                             // Country name
//                             Expanded(
//                               child: Text(
//                                 item.country,
//                                 style: context.textTheme.bodyMedium?.copyWith(
//                                   fontSize: AppSize.sp14,
//                                   fontWeight: FontWeight.w400,
//                                   color: textColors.textColor,
//                                 ),
//                               ),
//                             ),
//                             // Radio indicator
//                             if (isSelected)
//                               _RadioDot(color: colors.primary)
//                             else
//                               SizedBox(width: AppSize.w20),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ),
//           // Done button
//           SafeArea(
//             top: false,
//             child: Padding(
//               padding: EdgeInsets.fromLTRB(
//                 AppSize.w20,
//                 AppSize.h8,
//                 AppSize.w20,
//                 AppSize.h16,
//               ),
//               child: AppButton(
//                 text: context.l10n.currencyDone,
//                 onPressed: () {
//                   context.read<CurrencyProvider>().setCurrency(_pending);
//                   NavigationHelper().handleBackPress(context);
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//       ),
//     );
//   }
// }
//
// class _RadioDot extends StatelessWidget {
//   const _RadioDot({required this.color});
//
//   final Color color;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: AppSize.w20,
//       height: AppSize.h20,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(color: color, width: 1.5),
//       ),
//       child: Center(
//         child: Container(
//           width: AppSize.w10,
//           height: AppSize.h10,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: color,
//           ),
//         ),
//       ),
//     );
//   }
// }
