package main

import "core:fmt"
import "core:math"

MAX_EVENTS_IN_QUEUE :: 32
MAX_EVENT_OPTIONS :: 4

NarrativeEvent :: struct {
	header:  string,
	text:    []u8,
	options: []EventOption,
}

EventOption :: struct {
	text:         []u8,
	triggers:     []OnTrigger,
	requirements: []Requirement,
	chainedEvent: []^Event,
}

TriggerEvent :: struct {}

EventType :: union {
	NarrativeEvent,
	TriggerEvent,
}

Event :: struct {
	type:         EventType,
	requirements: []Requirement,
	triggers:     []OnTrigger,
	chainedEvent: []^Event,
	isFired:      bool,
}

EventQueue :: struct {
	activeIndex: bit_set[0 ..< MAX_EVENTS_IN_QUEUE],
	events:      [MAX_EVENTS_IN_QUEUE]^Event,
}

EventChoiceMap :: struct {
	indexMap: [MAX_EVENT_OPTIONS]int,
	length:   int,
}

OngoingEventInput :: struct {
	selectedOption: int,
}

EMPTY_OPTION: [1]EventOption = {{text = get_u8("Continue")}}

create_event_queue_default :: proc() -> EventQueue {
	return {}
}

add_event_to_queue :: proc(data: ^GameData, event: ^Event) {
	queue: ^EventQueue = &data.eventQueue
	for i in 0 ..< MAX_EVENTS_IN_QUEUE {
		if i not_in queue.activeIndex {
			prepare_event(data, event)
			queue.events[i] = event
			queue.activeIndex += {i}
			return
		}
	}
}

add_event_to_queue_by_id :: proc(data: ^GameData, id: EventEnum) {
	queue: ^EventQueue = &data.eventQueue
	event := EVENT_CHAINS[id]
	for i in 0 ..< MAX_EVENTS_IN_QUEUE {
		if i not_in queue.activeIndex {
			prepare_event(data, event)
			queue.events[i] = event
			queue.activeIndex += {i}
			return
		}
	}
}

prepare_event :: proc(data: ^GameData, event: ^Event) {
	data.ongoingEventInput.selectedOption = 0
	prepare_requirement(data, event.requirements)

	#partial switch &type in event.type {
	case NarrativeEvent:
		if len(type.options) == 0 {
			type.options = EMPTY_OPTION[:]
		}
	}
}

add_event :: proc {
	add_event_to_queue,
	add_event_to_queue_by_id,
}

// returns index of next fireable event or -1 if no event is ready
get_fireable_event :: proc(data: ^GameData) -> int {
	for i in 0 ..< MAX_EVENTS_IN_QUEUE {
		if i in data^.eventQueue.activeIndex {
			if is_requirement_met(data, data.eventQueue.events[i].requirements) {
				set_event_choice_map(data, i)
				return i
			}
		}
	}

	return -1
}

fire_event :: proc(data: ^GameData) -> bool {
	event := data.eventQueue.events[data.activeEventIndex]

	if event.isFired {return true}

	on_trigger(data, event.triggers)
	event.isFired = true

	#partial switch &type in event.type {
	case TriggerEvent:
		close_event(data, data.activeEventIndex)
		return false
	}

	return true
}

close_event :: proc(data: ^GameData, eventIndex: int) {
	// options chained events will have higher priority by adding events, before resetting 
	// active event index
	for chainedEvent in data.eventQueue.events[eventIndex].chainedEvent {
		add_event_to_queue(data, chainedEvent)
	}

	data.eventQueue.activeIndex -= {eventIndex}
	data.activeEventIndex = -1
}

set_event_choice_map :: proc(data: ^GameData, eventIndex: int) {

	#partial switch &event in data.eventQueue.events[eventIndex].type {
	case NarrativeEvent:
		choiceMap: ^EventChoiceMap = &data^.eventChoiceMap

		currentChoiceMapIndex := 0
		choiceMap^.length = 0

		for &option, i in event.options {
			if is_requirement_met(data, option.requirements) {
				choiceMap^.indexMap[currentChoiceMapIndex] = i
				currentChoiceMapIndex += 1
				choiceMap^.length += 1
			} else {
				//todo, maybe display why an option isn't available.
			}
		}
	}
}

event_handle_input :: proc(data: ^GameData, input: string) {

	eventIndex := data.activeEventIndex
	choiceMap := data.eventChoiceMap

	#partial switch &event in data.eventQueue.events[eventIndex].type {
	case NarrativeEvent:
		eventChoiceMap := &data.eventChoiceMap

		switch input {
		case "\e[A":
			data.ongoingEventInput.selectedOption =
				data.ongoingEventInput.selectedOption - 1 %% choiceMap.length
		case "\e[B":
			data.ongoingEventInput.selectedOption =
				data.ongoingEventInput.selectedOption + 1 %% choiceMap.length

		case "\n":
			choiceIndex := eventChoiceMap.indexMap[data.ongoingEventInput.selectedOption]
			option := event.options[choiceIndex]
			on_trigger(data, option.triggers)

			for chainedEvent in option.chainedEvent {
				add_event_to_queue(data, chainedEvent)
			}

			close_event(data, data.activeEventIndex)
		}
	}
}

get_longest_option_text :: proc(options: []EventOption) -> int {
	length := 0
	for &option in options {
		textLen := len(option.text)
		if textLen > length {
			length = textLen
		}
	}

	return length
}

event_render :: proc(data: ^GameData, renderer: ^Renderer) {

	event := data.eventQueue.events[data.activeEventIndex]
	choiceMap := &data.eventChoiceMap

	#partial switch &type in event.type {
	case NarrativeEvent:
		// y spacing
		edgeToheaderSpacing :: 1
		headerHeight :: 1
		headerToTextSpacing :: 2
		textToOptionSpacing :: 2
		optionToBottomSpacing :: 2

		// x spacing
		edgeToTextSpacing :: 4
		optionFrameToOptionTextSpacing :: 2

		frameWidth := renderer.width / 2
		textWidth := frameWidth - 2 * edgeToTextSpacing

		textHeight := (len(type.text) + textWidth - 1) / textWidth

		optionLength := choiceMap.length
		optionHeight: [MAX_EVENT_OPTIONS]int
		maxOptionFrameWidth := textWidth
		maxOptionTextWidth := maxOptionFrameWidth - (optionFrameToOptionTextSpacing * 2)

		totalOptionHeight := 0

		for i in 0 ..< optionLength {
			choiceIndex := choiceMap.indexMap[i]
			choice := type.options[choiceIndex]

			width := len(choice.text)
			height := (width + maxOptionTextWidth - 1) / maxOptionTextWidth
			optionHeight[i] = height
			totalOptionHeight += height
		}

		frameHeight :=
			edgeToheaderSpacing +
			headerHeight +
			headerToTextSpacing +
			textHeight +
			textToOptionSpacing +
			totalOptionHeight +
			optionToBottomSpacing

		frameX := (renderer.width / 2) - (frameWidth / 2)
		y := SCENE_Y + 1

		//frame
		draw_rect(renderer, frameX, y, frameWidth, frameHeight, fill = ' ')
		y += 1

		//header
		headerX := frameX + (frameWidth / 2 - len(type.header) / 2)
		draw_str(renderer, headerX, y, type.header)
		y += 1

		//text
		for i in 0 ..< textHeight {
			start := i * textWidth
			end := start + textWidth < len(type.text) ? start + textWidth : len(type.text)

			txtStr := string(type.text[start:end])
			draw_str(renderer, frameX + edgeToTextSpacing, y, txtStr)
			y += 1
		}

		y += textToOptionSpacing

		//options
		for i in 0 ..< optionLength {
			choiceIndex := choiceMap.indexMap[i]
			option := &type.options[choiceIndex]

			if data.ongoingEventInput.selectedOption == choiceIndex {
				draw_rect(
					renderer,
					frameX + edgeToTextSpacing,
					y,
					maxOptionFrameWidth,
					optionHeight[i] + 2,
				)
			}

			y += 1

			for row in 0 ..< optionHeight[i] {
				start := row * maxOptionTextWidth
				end :=
					start + maxOptionTextWidth < len(option.text) ? start + maxOptionTextWidth : len(option.text)
				optionStr := string(option.text[start:end])

				draw_str(renderer, frameX + edgeToTextSpacing + 2, y, optionStr)
				y += 1
			}
		}

	}


}
