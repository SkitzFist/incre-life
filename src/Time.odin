package main

import "core:fmt"
import "core:time"

DAYS_IN_A_YEAR :: 365

Time :: struct {
	age:         int,
	year:        int,
	day:         int,
	elapsed:     time.Duration,
	dayDuration: time.Duration,
	active:      bool,
}

create_default_time :: proc() -> Time {
	return {age = 10, year = 1, day = 0, dayDuration = time.Millisecond * 1500, active = true}
}

elapse_time :: proc(t: ^Time, dt: time.Duration) {
	if t^.active == false {
		return
	}

	t^.elapsed += dt

	if t^.elapsed >= t^.dayDuration {
		t^.elapsed = 0.0

		t^.day += 1

		if t^.day == DAYS_IN_A_YEAR {
			t^.year += 1
			t^.day = 0
			t^.age += 1
		}
	}
}

draw_time :: proc(renderer: ^Renderer, t: ^Time, y: int) {
	buf: [32]u8

	spacing :: 2
	x := 1
	yearStr := fmt.bprint(buf[:], "Year: ", t^.year, sep = "")
	draw_str(renderer, x, y, yearStr)
	x += len(yearStr) + spacing

	dayStr := fmt.bprint(buf[:], "Day: ", t^.day, sep = "")
	draw_str(renderer, x, y, dayStr)
	x += len(dayStr) + spacing

	ageStr := fmt.bprint(buf[:], "Age: ", t^.age, sep = "")
	draw_str(renderer, x, y, ageStr)
}
