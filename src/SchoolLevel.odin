package main


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
