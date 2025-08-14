package main


StatRequirement :: struct {
	type:  StatType,
	level: int,
}

SubjectRequirement :: struct {
	type:  Subject,
	level: int,
}

MinAgeRequirement :: struct {
	age: int,
}

FinishedSchoolLevelRequirement :: struct {
	level: SchoolLevel,
}

YearRequirement :: struct {
	year: int,
}

YearDynamicRequirement :: struct {
	inYears: int,
	year:    int,
}

Requirement :: union {
	StatRequirement,
	SubjectRequirement,
	MinAgeRequirement,
	FinishedSchoolLevelRequirement,
	YearRequirement,
	YearDynamicRequirement,
}

is_requirement_met :: proc(data: ^GameData, reqs: []Requirement) -> bool {
	for &req in reqs {

		switch &r in req {

		case StatRequirement:
			if data^.stats.level[r.type] < r.level {
				return false
			}

		case SubjectRequirement:
			if data^.school.subjectsLevel[r.type] < r.level {
				return false
			}

		case MinAgeRequirement:
			if data^.time.age < r.age {
				return false
			}

		case FinishedSchoolLevelRequirement:
			if r.level not_in data^.school.finishedLevel {
				return false
			}

		case YearRequirement:
			if r.year != data.time.year {
				return false
			}

		case YearDynamicRequirement:
			if r.year != data.time.year {
				return false
			}
		}

	}

	return true
}

prepare_requirement :: proc(data: ^GameData, reqs: []Requirement) {
	for &req in reqs {
		#partial switch &r in req {
		case YearDynamicRequirement:
			r.year = data.time.year + r.inYears
		}
	}
}
