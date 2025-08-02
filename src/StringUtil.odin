package main

to_lower :: proc(buf: []u8) {
	for r, i in buf {
		if buf[i] >= 'A' && buf[i] <= 'Z' {
			buf[i] += 32
		}
	}
}

to_upper :: proc(buf: []u8) {
	for r, i in buf {
		if buf[i] >= 'a' && buf[i] <= 'z' {
			buf[i] -= 32
		}
	}
}

replace :: proc(buf: []u8, from: u8, to: u8) {
	for &r in buf {
		if r == from {
			r = to
		}
	}
}
