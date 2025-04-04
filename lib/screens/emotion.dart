import 'package:flutter/cupertino.dart';

//import 'package:gp1/widgets/SectionScreen.dart';

import '../widgets/SectionScreen.dart';

class EmotionScreen extends StatelessWidget {
  EmotionScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> emotions = [
    {
      'title': 'الفرح',
      'description':
          'يتعلم كيف يتعرف على الفرح، ويدرك مشاعره الذاتية ومشاعر الآخرين، كما يتعلم كيفية إدارة هذا الشعور بشكل صحيح.'
    },
    {
      'title': 'الحزن',
      'description':
          'يتعلم كيف يتعرف على الحزن، ويدرك مشاعره الذاتية ومشاعر الآخرين، كما يتعلم كيفية إدارة هذا الشعور بشكل صحيح.'
    },
    {
      'title': 'المفاجأة',
      'description':
          'يتعلم كيف يتعرف على  المفاجأة، ويدرك مشاعره الذاتية ومشاعر الآخرين، كما يتعلم كيفية إدارة هذا الشعور بشكل صحيح.'
    },
    {
      'title': 'الخجل',
      'description':
          'يتعلم كيف يتعرف على  الخجل، ويدرك مشاعره الذاتية ومشاعر الآخرين، كما يتعلم كيفية إدارة هذا الشعور بشكل صحيح.'
    },
    {
      'title': 'الخوف',
      'description':
          'يتعلم كيف يتعرف على  الخوف، ويدرك مشاعره الذاتية ومشاعر الآخرين، كما يتعلم كيفية إدارة هذا الشعور بشكل صحيح.'
    },
    {
      'title': 'الغضب',
      'description':
          'يتعلم كيف يتعرف على  الغضب، ويدرك مشاعره الذاتية ومشاعر الآخرين، كما يتعلم كيفية إدارة هذا الشعور بشكل صحيح.'
    },
    {
      'title': 'النفكير',
      'description':
          'يتعلم كيف يتعرف على  التغكير، ويدرك مشاعره الذاتية ومشاعر الآخرين، كما يتعلم كيفية إدارة هذا الشعور بشكل صحيح.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CategoryScreen(title: 'الانفعالات', items: emotions);
  }
}
