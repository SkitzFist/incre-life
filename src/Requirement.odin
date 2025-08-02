package main


StatRequirement :: struct {
	type:  StatType,
	level: int,
}

SubjectRequirement :: struct {
	type:  Subject,
	level: int,
}

Requirement :: union {
	StatRequirement,
	SubjectRequirement,
}

RequirementList :: struct {
	reqs: []Requirement,
}

is_requirement_met :: proc(data: ^GameData, reqList: ^RequirementList) -> bool {
	for req in reqList.reqs {

		switch r in req {

		case StatRequirement:
			if data^.stats.level[r.type] < r.level {
				return false
			}

		case SubjectRequirement:
			if data^.school.subjectsLevel[r.type] < r.level {
				return false
			}
		}

	}

	return true
}
