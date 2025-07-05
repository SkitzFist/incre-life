package terminal_utility

import "core:sys/posix"

//Debug
import "core:fmt"

enable_raw_mode :: proc() -> (old_termios: posix.termios, ok: bool) {
    fd : posix.FD = 0 // stdin
    
    if posix.tcgetattr(fd, &old_termios) == .FAIL {
        return old_termios, false
    }
    new_termios := old_termios

	flags_to_clear := bit_set[posix.CLocal_Flag_Bits; posix.tcflag_t]{posix.CLocal_Flag_Bits.ICANON, posix.CLocal_Flag_Bits.ECHO}
	new_termios.c_lflag &~= flags_to_clear
    
    
    // Cast VMIN and VTIME to Control_Char (u8) for c_cc array
    new_termios.c_cc[posix.Control_Char.VTIME] = 0
    new_termios.c_cc[posix.Control_Char.VMIN] = 0

    if posix.tcsetattr(fd, .TCSANOW, &new_termios) == .FAIL {
        return old_termios, false
    }

    // Set stdin to non-blocking
    flags := posix.fcntl(fd, .GETFL, 0)
    if flags == -1 {
        return old_termios, false
    }
    
    if posix.fcntl(fd, .SETFL, flags | posix.O_NONBLOCK) == -1 {
        return old_termios, false
    }

    return old_termios, true
}

// Restore terminal settings
disable_raw_mode :: proc(old_termios: ^posix.termios) {
    posix.tcsetattr(0, .TCSANOW, old_termios)
}

// Read a single keypress non-blockingly
read_keypress :: proc() -> (rune, int) {
    buf: [1]u8
    n := posix.read(0, &buf[0], 1)

    return rune(buf[0]), n
}

