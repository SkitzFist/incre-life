package main

StatGain :: struct {
	type:  StatType,
	every: int,
	gain:  int,
}

OnLevelUp :: union {
	StatGain,
}

OnlevelUpList :: struct {
	gains: []OnLevelUp,
}

on_level_up :: proc(data: ^GameData, list: ^OnlevelUpList, level: int) {
	for gain in list.gains {

		switch g in gain {
		case StatGain:
			if level % g.every == 0 {
				data.stats.level[g.type] += g.gain
			}
		}
	}
}
