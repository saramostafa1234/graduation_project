// lib/constants/assessment_data.dart
import '../models/question_model.dart'; // تأكد من المسار الصحيح لنموذج السؤال

// قائمة الأسئلة مع الشرح المدمج
final List<Question> assessmentQuestions = [
  // -------------------- الفرح / السعادة --------------------
  Question(
    id: 1, emotion: "الفرح", dimension: "فهم",
    text: "هل طفلك يفهم أن الفرح شعور إيجابي ومختلف عن المشاعر الأخرى؟",
    explanation: "المقصود هنا هو قدرة الطفل على تمييز أن شعور السعادة يختلف عن شعور الحزن أو الخوف، وأنه شعور مرغوب وجيد."
  ),
  Question(
    id: 2, emotion: "الفرح", dimension: "ادراك للنفس",
    text: "لما يكون فرحان، هل يبدو واعيًا بأنه يشعر بالفرح في هذه اللحظة؟",
    explanation: "هل تلاحظين أنه \"يعيش\" لحظة الفرح ويدرك داخلياً أنه \"مبسوط\"، أم أن الأمر مجرد رد فعل خارجي سريع؟"
  ),
  Question(
    id: 3, emotion: "الفرح", dimension: "ادراك للآخر",
    text: "هل يلاحظ ويفهم عندما يكون شخص آخر أمامه سعيدًا؟",
    explanation: "إذا رأى شخصاً آخر يضحك أو يبدو سعيداً، هل ينتبه ويفهم أن هذا الشخص \"فرحان\"؟ هل يتفاعل إيجابياً مع فرحة الآخرين؟"
  ),
  Question(
    id: 4, emotion: "الفرح", dimension: "ادارة",
    text: "هل يعبر عن فرحته بطريقة مناسبة وواضحة؟",
    explanation: "هل يستخدم تعابير وجه (ابتسامة، ضحك) أو أصوات أو حركات أو كلمات مناسبة لإظهار سعادته بشكل مفهوم ومتناسب مع الموقف؟"
  ),

  // -------------------- الحزن / الزعل --------------------
  Question(
    id: 5, emotion: "الحزن", dimension: "فهم",
    text: "هل طفلك يفهم أن الحزن شعور غير مريح ومختلف؟",
    explanation: "هل يميز طفلك أن شعور \"الزعل\" أو عدم الارتياح يختلف عن كونه سعيداً؟ هل يفهم أنه شعور سلبي أو غير مرغوب؟"
  ),
  Question(
    id: 6, emotion: "الحزن", dimension: "ادراك للنفس",
    text: "لما يكون حزيًنا، هل يبدو واعيًا بأنه يشعر بالحزن؟",
    explanation: "عندما يبكي أو ينعزل، هل تلاحظين أنه مدرك لحالته الشعورية وأنه \"زعلان\" أو \"متضايق\"؟"
  ),
  Question(
    id: 7, emotion: "الحزن", dimension: "ادراك للآخر",
    text: "هل يلاحظ ويفهم عندما يكون شخص آخر أمامه حزيًنا أو يبكي؟",
    explanation: "إذا رأى شخصاً آخر يبكي أو يبدو حزيناً، هل ينتبه ويبدو عليه محاولة فهم الموقف أو يتأثر به؟ هل يظهر تعاطفاً بسيطاً؟"
  ),
  Question(
    id: 8, emotion: "الحزن", dimension: "ادارة",
    text: "هل يحاول توصيل سبب حزنه؟ وهل يطلب المواساة أو يستجيب لها؟",
    explanation: "هل يحاول إخبارك (بالكلام أو الإشارة) لماذا هو حزين؟ هل يبحث عن حضنك أو يتقبل محاولاتك لتهدئته ومواساته؟"
  ),

  // -------------------- الغضب / الضيق --------------------
  Question(
    id: 9, emotion: "الغضب", dimension: "فهم",
    text: "هل طفلك يميز الغضب كشعور قوي ومختلف؟",
    explanation: "هل يفهم أن \"العصبية\" أو \"الضيق الشديد\" هو شعور مختلف وأكثر حدة من مجرد الزعل العادي؟"
  ),
  Question(
    id: 10, emotion: "الغضب", dimension: "ادراك للنفس",
    text: "لما يكون غاضبًا، هل يبدو واعيًا بأنه يشعر بالغضب؟",
    explanation: "في لحظة الغضب، هل يبدو مدركًا لحالة \"الغضب\" التي يمر بها، أم أنه يفقد السيطرة كلياً دون وعي بالشعور؟"
  ),
  Question(
    id: 11, emotion: "الغضب", dimension: "ادراك للآخر",
    text: "هل يلاحظ ويفهم عندما يكون شخص آخر أمامه غاضبًا؟",
    explanation: "إذا رأى شخصاً آخر متعصباً أو يرفع صوته، هل يفهم أو يستنتج أن هذا الشخص \"غضبان\"؟ هل يتأثر سلباً بهذا الموقف؟"
  ),
  Question(
    id: 12, emotion: "الغضب", dimension: "ادارة",
    text: "هل لديه طرق للتعبير عن الغضب غير السلوكيات الحادة (كالصراخ أو الضرب)؟ وهل يمكنه أن يهدأ (بمساعدة أو بدون)؟",
    explanation: "هل يلجأ أحياناً لطرق تعبير أخرى (محاولة كلام، تعابير وجه)؟ الأهم، هل نوبة الغضب تنتهي؟ هل يهدأ تدريجياً بمساعدتك أو لوحده؟"
  ),

  // -------------------- الخوف --------------------
  Question(
    id: 13, emotion: "الخوف", dimension: "فهم",
    text: "هل طفلك يفهم أن الخوف يرتبط عادةً بالخطر أو المجهول؟",
    explanation: "هل يربط شعور الخوف بمواقف معينة (صوت عالي، ظلام، غرباء) ويفهم أن هذا الشعور هو رد فعل لشيء مقلق أو غير آمن؟"
  ),
  Question(
    id: 14, emotion: "الخوف", dimension: "ادراك للنفس",
    text: "لما يكون خائفًا، هل يبدو واعيًا بأنه يشعر بالخوف؟",
    explanation: "عندما تظهر عليه علامات الخوف، هل تلاحظين أنه مدرك داخلياً لهذا الشعور المحدد بأنه \"خوف\"؟"
  ),
  Question(
    id: 15, emotion: "الخوف", dimension: "ادراك للآخر",
    text: "هل يلاحظ ويفهم عندما يكون شخص آخر أمامه خائفًا؟",
    explanation: "إذا رأى شخصاً آخر يبدو خائفاً (في الحقيقة أو كارتون)، هل ينتبه ويتفهم أن هذا الشخص يشعر بالخوف؟"
  ),
  Question(
    id: 16, emotion: "الخوف", dimension: "ادارة",
    text: "هل يعبر عن خوفه بطلب الحماية أو الأمان بطريقة واضحة؟",
    explanation: "عندما يخاف، هل يلجأ إليكِ أو لشخص يثق به؟ هل يطلب الحماية (بالكلام أو الأفعال) بشكل واضح ومباشر؟"
  ),

  // -------------------- الاستحياء / الخجل --------------------
  Question(
    id: 17, emotion: "الخجل", dimension: "فهم",
    text: "هل طفلك يفهم أن الخجل غالبًا ما يحدث في المواقف الاجتماعية؟",
    explanation: "هل يدرك أن شعور \"الكسوف\" يظهر عادةً عند مقابلة أناس جدد أو عندما يكون محط الأنظار؟"
  ),
  Question(
    id: 18, emotion: "الخجل", dimension: "ادراك للنفس",
    text: "لما يتصرف بخجل، هل يبدو واعيًا بأنه يشعر بالخجل؟",
    explanation: "عندما يخفي وجهه أو يرفض الكلام، هل يبدو مدركًا أنه يشعر \"بالكسوف\" أو عدم الارتياح في هذا الموقف؟"
  ),
  Question(
    id: 19, emotion: "الخجل", dimension: "ادراك للآخر",
    text: "هل يلاحظ ويفهم عندما يتصرف شخص آخر أمامه بخجل؟",
    explanation: "هل ينتبه إذا كان طفل آخر أو شخص بالغ يبدو متردداً أو يتجنب التواصل البصري أو الكلام في موقف اجتماعي؟"
  ),
  Question(
    id: 20, emotion: "الخجل", dimension: "ادارة",
    text: "هل يحاول تجاوز خجله ولو قليلاً (خاصة بالتشجيع) أم ينسحب تمامًا؟",
    explanation: "هل يمكن لتشجيعك أن يساعده على التفاعل بشكل بسيط (ابتسامة، كلمة)، أم أن الخجل يجعله يرفض أي تفاعل ويفضل الانسحاب؟"
  ),

  // -------------------- الاندهاش / المفاجأة --------------------
  Question(
    id: 21, emotion: "الاندهاش", dimension: "فهم",
    text: "هل طفلك يفهم أن الاندهاش هو رد فعل لشيء غير متوقع؟",
    explanation: "هل يربط تعابير المفاجأة بحدوث شيء جديد أو غريب أو غير متوقع؟ هل يفهم سبب هذا الشعور؟"
  ),
  Question(
    id: 22, emotion: "الاندهاش", dimension: "ادراك للنفس",
    text: "لما يُفاجأ، هل يبدو واعيًا بأنه يشعر بالدهشة؟",
    explanation: "هل يدرك الشعور بالدهشة بعد حدوث المفاجأة ويستمر معه للحظات، أم هو مجرد رد فعل جسدي سريع؟"
  ),
  Question(
    id: 23, emotion: "الاندهاش", dimension: "ادراك للآخر",
    text: "هل يلاحظ ويفهم عندما يكون شخص آخر أمامه مندهشًا؟",
    explanation: "إذا رأى شخصاً آخر يبدي علامات الدهشة، هل يأخذ باله ويحاول فهم سبب دهشة هذا الشخص؟"
  ),
  Question(
    id: 24, emotion: "الاندهاش", dimension: "ادارة",
    text: "هل تعبيره عن الدهشة واضح؟ وهل يحاول فهم ما حدث بعد ذلك؟",
    explanation: "هل تعابير وجهه أو أصواته تعبر بوضوح عن المفاجأة؟ هل يُظهر فضولاً لمعرفة المزيد حول ما حدث؟"
  ),

  // -------------------- عملية التفكير --------------------
  Question(
    id: 25, emotion: "التفكير", dimension: "فهم",
    text: "عندما يُطلب منه عمل شيء (كلعبة مثلاً)، هل يبدو فاهمًا للمطلوب؟",
    explanation: "هل يستوعب الهدف من المهمة أو اللعبة التي يُطلب منه القيام بها؟ هل يفهم التعليمات البسيطة؟"
  ),
  Question(
    id: 26, emotion: "التفكير", dimension: "ادراك للنفس",
    text: "هل تلاحظين أنه يأخذ وقتًا للتفكير قبل الإقدام على عمل يتطلب تركيزًا؟",
    explanation: "هل يتوقف أحياناً ويبدو عليه التفكير أو التخطيط قبل البدء في مهمة تحتاج تركيز، مثل بناء برج بالمكعبات؟"
  ),
  Question(
    id: 27, emotion: "التفكير", dimension: "ادراك للآخر",
    text: "هل يظهر فهًما (ولو بسيطًا) بأن الآخرين قد يفكرون أو يريدون أشياء مختلفة عنه؟",
    explanation: "هل بدأ يدرك أن رغباتك أو أفكار أخيه قد تكون مختلفة عن رغباته وأفكاره هو؟ (مثلاً في اختيار الألعاب أو الطعام)."
  ),
  Question(
    id: 28, emotion: "التفكير", dimension: "ادارة",
    text: "عندما يواجه صعوبة، هل يحاول إيجاد حلول مختلفة أم يستسلم بسرعة؟",
    explanation: "إذا واجه تحدياً بسيطاً، هل يحاول حله بأكثر من طريقة أم يتركه بسرعة ويطلب المساعدة أو يغضب؟"
  ),
];