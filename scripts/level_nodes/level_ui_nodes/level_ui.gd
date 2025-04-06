extends CanvasLayer
class_name LevelUI


func _ready() -> void:
	EventBus.queue_turn_start.connect(_turn_start)



func _turn_start(group_name: String, group_index: int):
	var wipe_animation := TurnStartAnimation.create(group_name, Constants.get_team_color(group_index))
	
	add_child(wipe_animation)
	
	await wipe_animation.play()
	
	remove_child(wipe_animation)
	wipe_animation.queue_free()
	EventBus.turn_start_ready.emit()
