extends Node2D
@onready var marker2d_H1 = $"House1/Marker2D-OutFromP"
@onready var marker2d_H2 = $"House2/Marker2D-OutFromP"


func _ready() -> void:
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.H1] = marker2d_H1
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.H2] = marker2d_H2
		
		
func getCustomMarker(type :EnumsRef.LOCAL_FROM_TYPE) -> Marker2D:
	return GameState.dict_TPs[type]
	
