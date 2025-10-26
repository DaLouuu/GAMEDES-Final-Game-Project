extends Node

var candles: Array[bool] = [false, false, false] # 3 slots 
var correct_candles_collected := 0 

func collect_candle(is_correct: bool) -> bool: 
	for i in range(candles.size()): 
		if not candles[i]: 
			candles[i] = true 
			EventBus.candle_collected.emit(i, is_correct) 
			if is_correct: 
				correct_candles_collected += 1 
				if correct_candles_collected == 3: 
					EventBus.ritual_completed.emit() 
			return true 
	return false # Inventory full 

func use_candle(index: int): 
	if index < candles.size() and candles[index]: 
		candles[index] = false 
		EventBus.candle_used.emit(index) 
