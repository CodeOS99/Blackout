extends RichTextLabel

const TIME_BETWEEN_LETTERS: float = .1
var wait_time: float
var typing: bool = false
var waiting: bool = false
var typing_timer = TIME_BETWEEN_LETTERS
var fade_tween: Tween

func _process(delta: float) -> void:
	if typing:
		typing_timer -= delta
		if typing_timer <= 0:
			typing_timer = TIME_BETWEEN_LETTERS
			visible_characters += 1 
			if visible_characters == len(text):
				typing = false
				waiting = true
	elif waiting:
		if wait_time > 0:
			wait_time -= delta 
		else:
			waiting = false
			fade_out()

func start_dialogue(new_text: String, new_wait_time: float, new_font_size: int = 24):
	if fade_tween:
		fade_tween.kill()
	
	add_theme_font_size_override("normal_font_size", new_font_size)
	
	text = new_text
	wait_time = new_wait_time
	visible_characters = 0
	typing_timer = TIME_BETWEEN_LETTERS
	modulate = Color(1, 1, 1, 1)
	
	typing = true
	waiting = false
func fade_out():
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.0)
