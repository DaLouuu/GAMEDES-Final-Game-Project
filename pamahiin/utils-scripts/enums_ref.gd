extends Node
# name under Globals: EnumsRef
enum LocationType {
	MOTEL,
	GRAVEYARD,
	HOME,
	GARDEN,
	CHAPEL,
	SARI_SARI_STORE,
	NIGHTMARE_REALM,
}


enum DialogueOutcome {
	NONE,
	GAIN_ITEM,
	LOSE_SANITY,
	TRIGGER_EVENT,
	DEATH,
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
