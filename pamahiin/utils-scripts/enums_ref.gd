extends Node
# name under Globals: EnumsRef


enum SceneLoadState {
	VISIBLE, # All data and memory present
	DELETE, # All data is gone with the scene
	HIDE, # scene data is both present and running, not visible
	REMOVE_HIDDEN # scene is just in memory, not running.
}

enum EnemyState {
	IDLE,
	FOLLOW,
	ATTACK,
	RETREAT,
	CUSTOM1,
	CUSTOM2,
	CUSTOM3
}

enum LocationType {
	MOTEL,
	GRAVEYARD,
	HOME,
	GARDEN,
	CHAPEL,
	SARI_SARI_STORE
}


enum DialogueOutcome {
	NONE,
	GAIN_ITEM,
	LOSE_SANITY,
	TRIGGER_EVENT,
	DEATH,
}

enum ItemType {
	ARTIFACT,
	DESTRUCTIBLE,
	ENVIRONMENT
}
enum ArtifactType {
	ROSARY,
	HOLY_WATER,
	SALT,
	WALIS_TINGTING,
	CANDLE,
}


enum EventTrigger {
	ON_ENTER_AREA,
	ON_INTERACT,
	ON_TIMER,
	ON_SANITY_LOW,
	ON_ITEM_USE,
}


enum GamePhase { PROLOGUE, 
				ROSARY, 
				HOLY_WATER, 
				SALT, 
				WALIS_TINGTING, 
				CANDLE, 
				FINAL_RITUAL }
