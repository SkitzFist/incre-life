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

get_subject_duration :: proc(level: int) -> time.Duration {
	return math.max(time.Second * time.Duration(level), time.Second * 1)
}

SUBJECT_REQUIREMENTS: [Subject]RequirementList = {
	.NONE          = {},
	.SCRIPTURE     = {scripture_requirements[:]},
	.COUNTING      = {counting_requirements[:]},
	.FARMING       = {farming_requirements[:]},
	.MOCK_BATTLE   = {mock_battle_requirements[:]},
	.COMMON_TONGUE = {common_tongue_requirements[:]},
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
