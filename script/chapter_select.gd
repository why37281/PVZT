extends CanvasLayer

func _ready() -> void:
	create_buttons()
	
func _process(delta: float) -> void:
	pass

func create_buttons():
	

func on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/StartMenu.tscn")
