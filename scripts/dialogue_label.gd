extends RichTextLabel

const TIME_BETWEEN_LETTERS: float = .1

var wait_time: float
var typing: bool = false
var waiting: bool = false
var typing_timer = TIME_BETWEEN_LETTERS

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
			var t = get_tree().create_tween()
			t.tween_property(self, "modulate", Color(1, 1, 1, 0), wait_time)
