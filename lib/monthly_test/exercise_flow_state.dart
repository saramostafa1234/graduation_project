// lib/cubit/exercise_flow_state.dart
import 'package:equatable/equatable.dart';

// --- Helper class to represent an item to be displayed ---
class DisplayItem extends Equatable {
  final String type; // 'Img' or 'Text'
  final String? content; // Asset path for Img, text content for Text
  // Unique identifier for this item, used for selection in choice steps
  // For Img: Asset Path. For Text: The text content itself.
  final String identifier;

  const DisplayItem({
    required this.type,
    required this.content,
    required this.identifier,
  });

  @override
  List<Object?> get props => [type, content, identifier];
}

// --- Enum for how the step should be displayed ---
enum StepDisplayType {
  singleItemWithOptions, // Show item1 + text options
  twoItemsChoice, // Show item1 and item2, user chooses one
}

// Base State
abstract class ExerciseFlowState extends Equatable {
  const ExerciseFlowState();
  @override
  List<Object?> get props => [];
}

// --- Basic States ---
class ExerciseFlowInitial extends ExerciseFlowState {}
class ExerciseFlowLoading extends ExerciseFlowState {}

class ExerciseFlowLoadingDistractor
    extends ExerciseFlowState {} // Specific loading for random asset

class ExerciseFlowError extends ExerciseFlowState {
  final String message;
  const ExerciseFlowError(this.message);
  @override
  List<Object> get props => [message];
}
class ExerciseFlowFinished extends ExerciseFlowState {}
class ExerciseFlowUpdatingSession extends ExerciseFlowState {}

// --- State for displaying a step ---
class ExerciseStepLoaded extends ExerciseFlowState {
  final int currentStepIndex; // 0, 1, 2, 3
  final StepDisplayType displayType;
  final String? question;
  final int? mainSessionId;

  // Data for the items to display
  final DisplayItem item1;
  final DisplayItem? item2; // Only used for twoItemsChoice

  // Options for singleItemWithOptions
  final List<String> answerOptions;

  // The identifier of the correct answer
  // - For singleItemWithOptions: The correct text option string.
  // - For twoItemsChoice: The 'identifier' of the correct DisplayItem.
  final String correctAnswerIdentifier;

  const ExerciseStepLoaded({
    required this.currentStepIndex,
    required this.displayType,
    required this.question,
    required this.mainSessionId,
    required this.item1,
    this.item2, // Nullable
    required this.answerOptions,
    required this.correctAnswerIdentifier,
  });

  @override
  List<Object?> get props => [
    currentStepIndex,
        displayType,
        question,
    mainSessionId,
        item1,
        item2,
        answerOptions,
        correctAnswerIdentifier,
      ];
}

// --- Answer States ---
class ExerciseCorrectAnswer extends ExerciseFlowState {
  final ExerciseStepLoaded previousState;
  const ExerciseCorrectAnswer(this.previousState);
  @override
  List<Object?> get props => [previousState];
}

class ExerciseIncorrectAnswer extends ExerciseFlowState {
  final ExerciseStepLoaded previousState;
  const ExerciseIncorrectAnswer(this.previousState);
  @override
  List<Object?> get props => [previousState];
}