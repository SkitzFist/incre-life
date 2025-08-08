package main

import "core:math"
import "core:time"

Subject :: enum {
	NONE,
	//Elemental
	SCRIPTURE, // int
	COUNTING, // int
	FARMING, // con
	MOCK_BATTLE, // str, agi
	COMMON_TONGUE, // char

	/*
	// MID
	FENCING,

	// HIGH
	BATTLE_TACTICS

	// NOT DECIDED
	ALCHEMY,
	DIPLOMACY,
	BEAST_STUDIES,
	HERBAL_LORE,
	LORE,
	RELIGION, // could maybe play into its own branching with church work paths
    */
}

// todo potentially move to SchoolLevel and have each level have it's own duration
// alternatively let it be on subject level, but with option for different algorithms
get_subject_duration :: proc(level: int) -> time.Duration {
	affector := level
	if level == 0 {
		affector = 1
	}

	return time.Second * time.Duration(affector / 2)
}

/////////////////////////
///    Requirement   ///
SUBJECT_REQUIREMENTS: [Subject][]Requirement = {
	.NONE          = {},
	.SCRIPTURE     = scripture_requirements[:],
	.COUNTING      = counting_requirements[:],
	.FARMING       = farming_requirements[:],
	.MOCK_BATTLE   = mock_battle_requirements[:],
	.COMMON_TONGUE = common_tongue_requirements[:],
}


@(private = "file")
scripture_requirements: [1]Requirement = {StatRequirement{.INT, 10}}
@(private = "file")
counting_requirements: [1]Requirement = {StatRequirement{.INT, 0}}
@(private = "file")
farming_requirements: [1]Requirement = {StatRequirement{.CON, 0}}
@(private = "file")
mock_battle_requirements: [2]Requirement = {StatRequirement{.STR, 0}, StatRequirement{.AGI, 0}}
@(private = "file")
common_tongue_requirements: [1]Requirement = {StatRequirement{.CHA, 0}}


/////////////////////////
///    On Level Up   ///
SUBJECT_LEVEL_UP: [Subject][]OnTrigger = {
	.NONE          = {},
	.SCRIPTURE     = scripture_level_up[:],
	.COUNTING      = counting_level_up[:],
	.FARMING       = farming_level_up[:],
	.MOCK_BATTLE   = mock_battle_level_up[:],
	.COMMON_TONGUE = common_tongue_level_up[:],
}

@(private = "file")
scripture_level_up: [2]OnTrigger = {
	SubjectModuloStatGain{.SCRIPTURE, .WIS, 3, 1},
	SubjectModuloStatGain{.SCRIPTURE, .INT, 3, 1},
}
@(private = "file")
counting_level_up: [1]OnTrigger = {SubjectModuloStatGain{.COUNTING, .INT, 2, 1}}
@(private = "file")
farming_level_up: [1]OnTrigger = {SubjectModuloStatGain{.FARMING, .CON, 2, 1}}
@(private = "file")
mock_battle_level_up: [2]OnTrigger = {
	SubjectModuloStatGain{.MOCK_BATTLE, .AGI, 2, 1},
	SubjectModuloStatGain{.MOCK_BATTLE, .STR, 2, 1},
}
@(private = "file")
common_tongue_level_up: [1]OnTrigger = {SubjectModuloStatGain{.COMMON_TONGUE, .INT, 2, 1}}
