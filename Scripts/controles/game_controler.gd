extends Node


@export var quiz: QuizTheme
@export var color_right: Color
@export var color_wrong: Color

var buttons: Array[Button]
var index: int
var correct: int

var current_quiz: QuizQuestion:
	get: return quiz.theme[index]
	
@onready var question_texts = $Content/QuestionInfo/QuestionText
@onready var question_video = $Content/QuestionInfo/ImageHolder/QuestionVideo
@onready var question_audio = $Content/QuestionInfo/ImageHolder/QuestionAudio
@onready var question_image = $Content/QuestionInfo/ImageHolder/QuestionImage



func _ready():
	correct = 0
	for button in $Content/QuestionHolder.get_children():
		buttons.append(button)
	load_quiz()	
		
func load_quiz():
	if index >= quiz.theme.size():
		_game_over()
		return
	question_texts.text = current_quiz.question_info
	
	var options = current_quiz.options
	for i in buttons.size():
		buttons[i].text = options[i]
		buttons[i].pressed.connect(_buttons_answer.bind(buttons[i]))
	match current_quiz.type:
		Enum.QuestionType.TEXT:
			$Content/QuestionInfo/ImageHolder.hide()
			
		Enum.QuestionType.IMAGE:
			$Content/QuestionInfo/ImageHolder.show()
			question_image.texture = current_quiz.question_image
			
		Enum.QuestionType.AUDIO:
			$Content/QuestionInfo/ImageHolder.show()
			question_image.texture = current_quiz.question_image
			question_audio.stream = current_quiz.question_audio
			question_audio.play()
func _buttons_answer(button):
	if current_quiz.correct == button.text:
		button.modulate = color_right
		$AudioCorrect.play()
		correct += 1
		
	else:
		button.modulate = color_wrong
		$AudioIncorrect.play()
		
	_next_question()	
func _next_question():
	for bt in buttons:
		bt.pressed.disconnect(_buttons_answer)
	
	await get_tree().create_timer(1).timeout
	
	for bt in buttons:
		bt.modulate = Color.WHITE
		
	question_audio.stop()
	question_audio.stream = null
	
	index += 1
	
	load_quiz()
func _game_over():
	$Content/GameOver.show()
	$Content/GameOver/Score.text = str(correct, "/",quiz.theme.size())
	

	



func _on_button_pressed():
	get_tree().reload_current_scene()
