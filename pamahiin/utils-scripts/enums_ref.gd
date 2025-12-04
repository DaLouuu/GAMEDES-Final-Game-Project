extends Node
# name under Globals: EnumsRef

enum LOCAL_FROM_TYPE {H1, H2, CAVE, 
CHAPEL_ENTER1,CHAPEL_ENTER2, CHAPEL_ENTER3, 
CHAPEL_EXIT1, CHAPEL_EXIT2, CHAPEL_EXIT3}

enum SceneLoadState {
	VISIBLE, # All data and memory present
	DELETE, # All data is gone with the scene
	HIDE, # scene data is both present and running, not visible
	REMOVE_HIDDEN # scene is just in memory, not running.
}


enum NPCState{
	IDLE,
	MOVE
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
enum HitEffectType{
	HitEffectDamage,
	HitEffectPoison,
	HitEffectCustom # Controlled by another component
}
enum LocationType {
	MOTEL,
	GRAVEYARD,
	HOME,
	GARDEN,
	CHAPEL,
	CAVE,
	WORLD
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
	PUZZLE,
	DESTRUCTIBLE,
	ENVIRONMENT,
	UTIL
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
enum EndingType {
	GOOD,
	NEUTRAL,
	BAD
}

enum GamePhase { PROLOGUE, 
				ROSARY, 
				HOLY_WATER, 
				SALT, 
				WALIS_TINGTING, 
				CANDLE, 
				FINAL_RITUAL }
