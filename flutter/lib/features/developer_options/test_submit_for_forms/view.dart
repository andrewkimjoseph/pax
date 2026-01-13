// import 'package:flutter/material.dart' show InkWell;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shadcn_flutter/shadcn_flutter.dart' hide Consumer;
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:flutter_svg/svg.dart' show SvgPicture;
// import 'package:pax/theming/colors.dart';
// import 'package:pax/widgets/optimized_webview.dart';

// class TestSubmitForFormsView extends ConsumerStatefulWidget {
//   const TestSubmitForFormsView({super.key});

//   @override
//   ConsumerState<TestSubmitForFormsView> createState() =>
//       _TestSubmitForFormsViewState();
// }

// class _TestSubmitForFormsViewState
//     extends ConsumerState<TestSubmitForFormsView> {
//   late final WebViewController controller;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize the WebViewController
//     controller =
//         WebViewController()
//           ..setJavaScriptMode(JavaScriptMode.unrestricted)
//           ..setBackgroundColor(PaxColors.white)
//           ..setUserAgent(
//             'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
//           )
//           ..addJavaScriptChannel(
//             'FormSubmitDetector',
//             onMessageReceived: (JavaScriptMessage message) {
//               // Show dialog when form submit is detected
//               _showSubmitDetectedDialog();
//             },
//           )
//           ..setNavigationDelegate(
//             NavigationDelegate(
//               onPageStarted: (String url) {
//                 setState(() {
//                   isLoading = true;
//                 });
//               },
//               onPageFinished: (String url) {
//                 setState(() {
//                   isLoading = false;
//                 });
//                 // Inject JavaScript to detect form submissions
//                 // Use multiple attempts to catch dynamically loaded content
//                 _injectFormSubmitDetection();
//                 Future.delayed(Duration(milliseconds: 500), () {
//                   _injectFormSubmitDetection();
//                 });
//                 Future.delayed(Duration(milliseconds: 1500), () {
//                   _injectFormSubmitDetection();
//                 });
//               },
//               onNavigationRequest: (NavigationRequest request) {
//                 // Allow all navigation - we only detect button clicks
//                 return NavigationDecision.navigate;
//               },
//             ),
//           );

//     // Load the test form URL after first frame is rendered
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadTestFormUrl();
//     });
//   }

//   void _loadTestFormUrl() {
//     // Load the Google Form URL for testing
//     // const testFormUrl = 'https://forms.gle/n97Mra9cCM7Cgo8aA';
//     const testFormUrl = 'https://tally.so/r/Gx9Ebj';

//     controller.loadRequest(Uri.parse(testFormUrl));
//   }

//   void _injectFormSubmitDetection() {
//     // Universal JavaScript injection to detect form submissions across all providers
//     controller.runJavaScript('''
//       (function() {
//         // Prevent duplicate initialization
//         if (window._formSubmitDetectorInitialized) {
//           return;
//         }
//         window._formSubmitDetectorInitialized = true;
        
//         console.log('Form submit detection initializing...');
        
//         // Helper function to check if element is a submit button (strict detection)
//         function isSubmitButton(element) {
//           if (!element || !element.tagName) return false;
          
//           var tagName = element.tagName.toUpperCase();
//           var type = (element.type || '').toLowerCase();
          
//           // PRIMARY CHECK: Must have type="submit"
//           if (type === 'submit') {
//             // Additional verification: must be inside a form
//             var form = element.closest('form');
//             if (form) {
//               return true;
//             }
//             // Or if it's an input/button with submit type, it's definitely a submit button
//             if (tagName === 'INPUT' || tagName === 'BUTTON') {
//               return true;
//             }
//           }
          
//           // SECONDARY CHECK: Button inside a form with submit-related text
//           // Only if it's clearly a button element
//           var form = element.closest('form');
//           if (form && (tagName === 'BUTTON' || tagName === 'INPUT')) {
//             var text = (element.textContent || element.innerText || '').toLowerCase().trim();
//             var ariaLabel = (element.getAttribute('aria-label') || '').toLowerCase();
            
//             // Very specific keywords that indicate submission
//             var submitKeywords = ['submit', 'submit form', 'send form'];
//             var hasSubmitText = submitKeywords.some(function(keyword) {
//               return text === keyword || text.includes(keyword) || ariaLabel.includes(keyword);
//             });
            
//             if (hasSubmitText) {
//               return true;
//             }
            
//             // If it's the only button in the form AND has action-like text
//             var buttons = form.querySelectorAll('button, input[type="button"], input[type="submit"]');
//             if (buttons.length === 1 && buttons[0] === element) {
//               var actionKeywords = ['submit', 'send', 'done', 'finish'];
//               var hasActionText = actionKeywords.some(function(keyword) {
//                 return text.includes(keyword) || ariaLabel.includes(keyword);
//               });
//               if (hasActionText) {
//                 return true;
//               }
//             }
//           }
          
//           return false;
//         }
        
//         // Track if we've already notified for this submission
//         var notificationSent = false;
//         var notificationTimeout = null;
        
//         // Function to check if form is valid/complete
//         function isFormValid(form) {
//           if (!form) {
//             console.log('No form provided');
//             return false;
//           }
          
//           console.log('Checking form validity...');
          
//           // Try HTML5 validation first (if available)
//           if (typeof form.checkValidity === 'function') {
//             var isValid = form.checkValidity();
//             if (!isValid) {
//               console.log('Form validation failed (checkValidity returned false)');
//               return false;
//             }
//             console.log('Form passed checkValidity');
//           }
          
//           // Check for required fields that are empty
//           var requiredFields = form.querySelectorAll('[required]');
//           console.log('Found', requiredFields.length, 'required fields');
          
//           for (var i = 0; i < requiredFields.length; i++) {
//             var field = requiredFields[i];
//             var value = field.value;
//             var isChecked = field.checked;
//             var hasFiles = field.files && field.files.length > 0;
            
//             // Skip hidden or disabled fields
//             if (field.type === 'hidden' || field.disabled) {
//               continue;
//             }
            
//             // Check if field has a value
//             var hasValue = false;
//             if (field.type === 'checkbox' || field.type === 'radio') {
//               hasValue = isChecked;
//             } else if (field.type === 'file') {
//               hasValue = hasFiles;
//             } else {
//               hasValue = value && value.trim() !== '';
//             }
            
//             if (!hasValue) {
//               console.log('Required field is empty:', field.name || field.id || field.type);
//               return false;
//             }
//           }
          
//           // Check for invalid fields (if :invalid selector is supported)
//           try {
//             var invalidFields = form.querySelectorAll(':invalid');
//             if (invalidFields.length > 0) {
//               console.log('Form has', invalidFields.length, 'invalid fields');
//               return false;
//             }
//           } catch(e) {
//             // :invalid selector might not be supported, skip this check
//             console.log('Could not check :invalid selector');
//           }
          
//           console.log('Form is valid!');
//           return true;
//         }
        
//         // Function to notify Flutter (only once per submission)
//         function notifySubmit(form) {
//           // Reset notification flag after 2 seconds
//           if (notificationTimeout) {
//             clearTimeout(notificationTimeout);
//           }
          
//           if (notificationSent) {
//             console.log('Notification already sent for this submission');
//             return;
//           }
          
//           // Check if form is valid before notifying
//           var isValid = false;
//           if (form) {
//             try {
//               isValid = isFormValid(form);
//             } catch(err) {
//               console.error('Error checking form validity:', err);
//               // If we can't determine validity, assume it's valid (form submit event fired)
//               isValid = true;
//             }
//           } else {
//             // No form found, but submit event fired, so assume valid
//             console.log('No form found, but submit event fired - assuming valid');
//             isValid = true;
//           }
          
//           if (!isValid) {
//             console.log('Form is not valid/complete, not notifying');
//             return;
//           }
          
//           console.log('Submit detected! Form is valid. Notifying Flutter...');
//           notificationSent = true;
          
//           try {
//             if (typeof FormSubmitDetector !== 'undefined') {
//               FormSubmitDetector.postMessage('submit');
//               console.log('Message sent to FormSubmitDetector');
//             } else {
//               console.error('FormSubmitDetector channel not available');
//             }
//           } catch(err) {
//             console.error('Error posting message:', err);
//           }
          
//           // Reset after 2 seconds to allow new submissions
//           notificationTimeout = setTimeout(function() {
//             notificationSent = false;
//           }, 2000);
//         }
        
//         // Intercept form submit events (detect but don't prevent) - this is the main detection point
//         function interceptFormSubmit(e) {
//           var form = e.target;
//           console.log('Form submit event detected!', form);
          
//           // If form is not the target, try to find it
//           if (!form || form.tagName !== 'FORM') {
//             form = e.target.closest('form');
//             console.log('Found form via closest:', form);
//           }
          
//           // Always try to notify, but check validity inside notifySubmit
//           notifySubmit(form);
          
//           // Allow the form to submit normally
//           return;
//         }
        
//         // Add listener for form submit events (main detection point)
//         document.addEventListener('submit', interceptFormSubmit, true);
        
//         // Also attach to all existing forms
//         function attachToForms() {
//           var forms = document.querySelectorAll('form');
//           forms.forEach(function(form) {
//             if (!form.dataset._submitListener) {
//               form.dataset._submitListener = 'true';
//               form.addEventListener('submit', interceptFormSubmit, true);
//               console.log('Attached listener to form:', form);
//             }
//           });
          
//         }
        
//         // Attach immediately
//         if (document.readyState === 'loading') {
//           document.addEventListener('DOMContentLoaded', attachToForms);
//         } else {
//           attachToForms();
//         }
        
//         // Use MutationObserver for dynamically added content
//         var observer = new MutationObserver(function(mutations) {
//           attachToForms();
//         });
        
//         observer.observe(document.body || document.documentElement, {
//           childList: true,
//           subtree: true,
//           attributes: true,
//           attributeFilter: ['type', 'role', 'class']
//         });
        
//         console.log('Form submit detection initialized successfully');
//       })();
//     ''');
//   }

//   bool _dialogShown = false;

//   void _showSubmitDetectedDialog() {
//     if (!mounted || _dialogShown) return;
//     _dialogShown = true;

//     // Use Future.microtask to ensure dialog shows even if called during navigation
//     Future.microtask(() {
//       if (!mounted) {
//         _dialogShown = false;
//         return;
//       }

//       showDialog(
//         context: context,
//         barrierDismissible: true,
//         builder: (dialogContext) {
//           return AlertDialog(
//             title: Text('Form Submit Detected'),
//             content: Text('Submit JavaScript detected'),
//             actions: [
//               OutlineButton(
//                 onPressed: () {
//                   _dialogShown = false;
//                   dialogContext.pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       ).then((_) {
//         _dialogShown = false;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       headers: [
//         AppBar(
//           padding: EdgeInsets.all(8),
//           backgroundColor: PaxColors.white,
//           child: Row(
//             children: [
//               InkWell(
//                 onTap: () {
//                   context.pop();
//                 },
//                 child: SvgPicture.asset('lib/assets/svgs/arrow_left_long.svg'),
//               ),
//               Spacer(),
//               Text(
//                 "Test Submit Form",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 20),
//               ).withPadding(right: 16),
//               Spacer(),
//             ],
//           ),
//         ).withPadding(top: 16),
//         Divider(color: PaxColors.lightGrey),
//       ],
//       child: Stack(
//         children: [
//           OptimizedWebView(controller: controller, isLoading: isLoading),
//           if (isLoading) Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }
