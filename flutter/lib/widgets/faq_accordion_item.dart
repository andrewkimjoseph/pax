import 'package:pax/exports/shadcn.dart';
import 'package:pax/models/faq.dart';

class FAQAccordionItem extends StatelessWidget {
  final FAQ faq;

  const FAQAccordionItem({super.key, required this.faq});

  @override
  Widget build(BuildContext context) {
    return AccordionItem(
      trigger: AccordionTrigger(
        child: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      content: Text(faq.answer),
    );
  }
}
