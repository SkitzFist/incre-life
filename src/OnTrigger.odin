package main

StatGain :: struct {
	type: StatType,
	gain: int,
}

SubjectModuloStatGain :: struct {
	subject: Subject,
	type:    StatType,
	level:   int,
	gain:    int,
}

SceneUnlock :: struct {
	type: SceneType,
}

AgeGain :: struct {
	years: int,
}

OnTrigger :: union {
	StatGain,
	SubjectModuloStatGain,
	SceneUnlock,
	AgeGain,
}

on_trigger :: proc(data: ^GameData, gains: []OnTrigger) {
	for gain in gains {

		switch g in gain {
		case StatGain:
			data.stats.level[g.type] += g.gain

		case SubjectModuloStatGain:
			if data.school.subjectsLevel[g.subject] % g.level == 0 {
				data.stats.level[g.type] += g.gain
			}

		case SceneUnlock:
			set_scene_available(&data.scene, g.type)
			data.scene.active = g.type

		case AgeGain:
			data.time.year += g.years
			data.time.age += g.years
		}
	}
}
