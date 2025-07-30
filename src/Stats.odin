package main

import "core:fmt"

StatType :: enum {
	INT,
	AGI,
	STR,
	WIS,
	CHAR,
}

Stats :: struct {
	available: bit_set[StatType],
	level:     [len(StatType)]int,
}

create_stats_full :: proc() -> Stats {
	return Stats{available = ~bit_set[StatType]{}}
}

create_stats_partial :: proc(stats: ..StatType) -> Stats {
	rv: Stats

	for stat in stats {
		rv.available += {stat}
	}

	return rv
}

set_stat_available :: proc(stats: ^Stats, type: StatType) {
	stats^.available += {type}
}

set_stat_unavailable :: proc(stats: ^Stats, type: StatType) {
	stats^.available -= {type}
}

draw_stats :: proc(renderer: ^Renderer, stats: ^Stats, x: int, y: int) {

	currX := x
	spacing :: 2
	buf: [8]u8
	for type in StatType {
		if type in stats^.available {
			e_str := fmt.enum_value_to_string(type) or_continue
			f_str := fmt.bprint(buf[:], e_str, ":", stats^.level[type], sep = "")
			draw_str(renderer, currX, y, f_str)

			currX += len(f_str) + spacing
		}
	}
}
