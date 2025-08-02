package main
// maybe redo into paths instead.
// Mandatory first two, then it branches. Like warrior, farmer, mage paths.
SchoolLevel :: enum {
	ELEMENTARY,
}

SCHOOL_LEVEL_SUBJECTS: [SchoolLevel]bit_set[Subject] = {
	.ELEMENTARY = elementarySubjects,
}

@(private = "file")
elementarySubjects: bit_set[Subject] = {
	.SCRIPTURE,
	.COUNTING,
	.FARMING,
	.MOCK_BATTLE,
	.COMMON_TONGUE,
}
