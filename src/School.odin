package main

import "core:fmt"
import "core:math"
import "core:time"

School :: struct {
	currentSchoolLevel:      SchoolLevel,
	activeSubject:           Subject,
	selectedSubject:         Subject,
	subjectsLevel:           [Subject]int,
	subjectProgression:      [Subject]time.Duration,
	subjectProgressionRatio: [Subject]f64,
	finishedLevel:           bit_set[SchoolLevel],
}

create_school_default :: proc() -> School {
	return {currentSchoolLevel = .ELEMENTARY, activeSubject = .NONE, selectedSubject = .NONE}
}

///////////////////
///    INPUT    //
school_handleInput :: proc(data: ^GameData, input: string) {
	switch input {
	case "\e[A":
		data^.school.selectedSubject = get_selectable_subject(data, true)
	case "\e[B":
		data^.school.selectedSubject = get_selectable_subject(data, false)
	case "\n":
		data^.school.activeSubject = data^.school.selectedSubject
	}
}

get_selectable_subject :: proc(data: ^GameData, prev: bool) -> Subject {
	i := cast(int)data^.school.selectedSubject
	count := len(Subject)

	for step in 1 ..< count {
		next := 0
		if prev == true {
			next = (i - step + count) % count
		} else {
			next = (i + step) % count
		}

		subject := Subject(next)
		if subject in SCHOOL_LEVEL_SUBJECTS[data^.school.currentSchoolLevel] &&
		   is_requirement_met(data, SUBJECT_REQUIREMENTS[subject]) {
			return subject
		}
	}

	//fallback
	return data^.school.selectedSubject
}

////////////////////
///    UPDATE    //
school_update :: proc(data: ^GameData, dt: time.Duration) {
	subject := data^.school.activeSubject
	data^.school.subjectProgression[subject] += dt
	current_level := data^.school.subjectsLevel[subject]
	target_duration := get_subject_duration(current_level)
	data^.school.subjectProgressionRatio[subject] =
		f64(data^.school.subjectProgression[subject]) / f64(target_duration)

	if data^.school.subjectProgression[subject] >= target_duration {
		data^.school.subjectProgression[subject] = 0
		data^.school.subjectsLevel[subject] += 1

		on_trigger(data, SUBJECT_LEVEL_UP[subject])
	}
}

////////////////////
///    RENDER    //
school_render :: proc(data: ^GameData, renderer: ^Renderer) {

	// Draw Subjects and their progression
	y := SCENE_Y
	selector :: "->"
	selectorX :: 2
	subjectNameX :: selectorX + len(selector) + 1
	levelX :: subjectNameX + 16
	progressX :: levelX + 5
	progressWidth :: 16
	buf: [32]u8 = {}
	for subject in Subject {
		if subject in SCHOOL_LEVEL_SUBJECTS[data^.school.currentSchoolLevel] &&
		   is_requirement_met(data, SUBJECT_REQUIREMENTS[subject]) {

			// draw selection
			if subject == data^.school.selectedSubject || subject == data^.school.activeSubject {
				draw_str(renderer, selectorX, y, "->")
			}

			//get subject name, replace '_' to ' '
			enumStr := fmt.enum_value_to_string(subject) or_continue
			length := len(enumStr)
			copy_from_string(buf[:length], enumStr)
			replace(buf[:length], '_', ' ')
			str := string(buf[:length])

			draw_str(renderer, subjectNameX, y, str)

			//level
			draw_str(renderer, levelX, y, data^.school.subjectsLevel[subject])

			//progress bar
			draw_progress_bar(
				renderer,
				progressX,
				y,
				progressWidth,
				data^.school.subjectProgressionRatio[subject],
			)

			y += 1
		}
	}
}
