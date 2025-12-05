extends Node2D
@onready var marker2d_H1 = $"House1/Marker2D-OutFromP"
@onready var marker2d_H2 = $"House2/Marker2D-OutFromP"



		
func getCustomMarker(type :EnumsRef.LOCAL_FROM_TYPE) -> StringName:
	return GameState.dict_TPs[type]
	
