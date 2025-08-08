package main

import "core:fmt"
import "core:math"

MAX_EVENTS_IN_QUEUE :: 32
MAX_EVENT_OPTIONS :: 4
EVENT_CHOICE_INPUT: [MAX_EVENT_OPTIONS][1]u8 = {'q', 'w', 'e', 'r'}

Event :: struct {
	data:         EventData,
	requirements: []Requirement,
}

EventData :: struct {
	header:  string,
	text:    []u8,
	options: []EventOption,
	//chainedEvent: ^Event, // could be useful if an event is guaranteed to add a new
}

EventOption :: struct {
	text:         string,
	triggerList:  []OnTrigger,
	requirements: []Requirement,
	chainedEvent: ^Event,
}

EventQueue :: struct {
	activeIndex: bit_set[0 ..< MAX_EVENTS_IN_QUEUE],
	events:      [MAX_EVENTS_IN_QUEUE]^Event,
}

EventChoiceMap :: struct {
	indexMap: [MAX_EVENT_OPTIONS]int,
	length:   int,
}

create_event_queue_default :: proc() -> EventQueue {
	return {}
}

add_event_to_queue :: proc(data: ^GameData, event: ^Event) {
	queue: ^EventQueue = &data.eventQueue
	for i in 0 ..< MAX_EVENTS_IN_QUEUE {
		if i not_in queue.activeIndex {
			prepare_requirement(data, event.requirements)
			queue.events[i] = event
			queue.activeIndex += {i}
			return
		}
	}
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

set_event_choice_map :: proc(data: ^GameData, eventIndex: int) {
	event: ^EventData = &data.eventQueue.events[eventIndex].data
	choiceMap: ^EventChoiceMap = &data^.eventChoiceMap

	currentChoiceMapIndex := 0
	choiceMap^.length = 0
	for &option, i in event^.options {
		if is_requirement_met(data, option.requirements) {
			choiceMap^.indexMap[currentChoiceMapIndex] = i
			currentChoiceMapIndex += 1
			choiceMap^.length += 1
		} else {
			//todo, maybe display why an option isn't available.
		}
	}
}

event_handle_input :: proc(data: ^GameData, input: string) {

	eventIndex := data.activeEventIndex
	event: ^EventData = &data.eventQueue.events[eventIndex].data
	eventChoiceMap := &data.eventChoiceMap

	for i in 0 ..< eventChoiceMap.length {
		choiceStr := string(EVENT_CHOICE_INPUT[i][:])

		if input == choiceStr {
			choiceIndex := eventChoiceMap.indexMap[i]
			option := event.options[choiceIndex]

			on_trigger(data, option.triggerList)
			data.eventQueue.activeIndex -= {data.activeEventIndex}
			data.activeEventIndex = -1

			if option.chainedEvent != nil {
				add_event_to_queue(data, option.chainedEvent)
			}

			return
		}
	}
}

get_longest_option_text :: proc(data: ^GameData) -> int {
	eventData := &data.eventQueue.events[data.activeEventIndex].data

	length := 0
	for &option in eventData.options {
		textLen := len(option.text)
		if textLen > length {
			length = textLen
		}
	}

	return length
}

event_render :: proc(data: ^GameData, renderer: ^Renderer) {
	y := SCENE_Y

	eventData := data.eventQueue.events[data.activeEventIndex].data

	headerToTextSpacing :: 2
	edgeSpacing :: 2

	optionInputLength :: 2
	choiceBoxHeight :: 3 // could go with dynamic for multiline options
	choicesInRow :: 2
	choicesInColumn :: 2
	choiceXSpacing :: 2
	textToChoiceSpacing :: 2

	choiceBoxWidth := get_longest_option_text(data) + 2 + optionInputLength + 1
	width := math.max(choiceBoxWidth, renderer.width / 3) + 1 // quick hack need to redo this properly
	frameWidth := width + edgeSpacing * 2
	maxTextWidth := width

	rowsOfText := len(eventData.text) / maxTextWidth

	frameHeight :=
		(edgeSpacing * 2) +
		rowsOfText +
		choicesInColumn +
		headerToTextSpacing +
		choiceBoxHeight +
		textToChoiceSpacing


	frameX := renderer.width / 2 - frameWidth / 2
	draw_rect(renderer, frameX, y, frameWidth, frameHeight, fill = ' ')
	y += 1

	headerX := frameX + (frameWidth / 2 - len(eventData.header) / 2)
	// draw header
	draw_str(renderer, headerX, y, eventData.header)
	y += headerToTextSpacing

	// draw text
	lastI := 0
	for i in 0 ..< rowsOfText {
		lastI = (i * maxTextWidth) + maxTextWidth
		rowStr := string(eventData.text[i * maxTextWidth:lastI])
		draw_str(renderer, frameX + edgeSpacing, y, rowStr)
		y += 1
	}

	if lastI != len(eventData.text) - 1 {
		rowStr := string(eventData.text[lastI:])
		draw_str(renderer, frameX + edgeSpacing, y, rowStr)
		y += 1
	}

	y += textToChoiceSpacing

	// draw options
	choiceBuf: [4]u8
	for i in 0 ..< data.eventChoiceMap.length {
		optY := i < 2 ? y : y + choiceBoxHeight
		optX :=
			i % 2 == 0 ? frameX + edgeSpacing : frameX + edgeSpacing + choiceBoxWidth + choiceXSpacing

		draw_rect(renderer, optX, optY, choiceBoxWidth, choiceBoxHeight)
		choiceIndex := data.eventChoiceMap.indexMap[i]

		optionInput := fmt.bprint(choiceBuf[:], string(EVENT_CHOICE_INPUT[i][:]), ")", sep = "")
		draw_str(renderer, optX + 1, optY + 1, optionInput)
		draw_str(
			renderer,
			optX + optionInputLength + 2,
			optY + 1,
			eventData.options[choiceIndex].text,
		)
	}
}


/////////////////////////////
////     Test Events      ///
TEST_EVENT: Event = {
	data = {
		header = "Test Event",
		text = get_u8(
			"This is a test event mf. And the text migth not be long enough, but it's also hard to write super duper long texts, when there's nothing to actually write about.",
		),
		options = {
			{
				text = "Option INT",
				triggerList = {StatGain{type = .INT, gain = 1}},
				requirements = {},
				chainedEvent = &TEST_CHAIN_1,
			},
			{
				text = "Option STR",
				triggerList = {StatGain{type = .STR, gain = 1}},
				requirements = {},
				chainedEvent = &TEST_CHAIN_1,
			},
			{
				text = "Option AGI",
				triggerList = {StatGain{type = .AGI, gain = 1}},
				requirements = {},
				chainedEvent = &TEST_CHAIN_1,
			},
			{
				text = "Option CHA",
				triggerList = {StatGain{type = .CHA, gain = 1}},
				requirements = {},
				chainedEvent = &TEST_CHAIN_1,
			},
		},
	},
	requirements = {},
}

TEST_CHAIN_1: Event = {
	data = {
		header = "Test Event",
		text = get_u8(
			"This is a test event mf. And the text migth not be long enough," +
			"but it's also hard to write super duper long texts, when there's nothing to actually write about. This is a test event mf. And the text migth not be long enough, but it's also hard to write super duper long texts, when there's nothing to actually write about.",
		),
		options = {
			{
				text = "Option INT",
				triggerList = {SceneUnlock{type = .SCHOOL}},
				requirements = {},
				chainedEvent = nil,
			},
			{
				text = "Option STR",
				triggerList = {StatGain{type = .STR, gain = 1}},
				requirements = {},
				chainedEvent = nil,
			},
			{
				text = "Option AGI",
				triggerList = {StatGain{type = .AGI, gain = 1}},
				requirements = {},
				chainedEvent = nil,
			},
			{
				text = "Option CHA",
				triggerList = {StatGain{type = .CHA, gain = 1}},
				requirements = {},
				chainedEvent = nil,
			},
		},
	},
	requirements = {},
}

DYNAMIC_YEAR_EVENT_TEST: Event = {
	data = {
		header = "Years has passed...",
		text = get_u8(
			"So many years has passed, it's almost ridicilous, but now the time has come. you are now a man",
		),
		options = {
			{
				text = "Get Market",
				triggerList = {SceneUnlock{type = .MARKET}},
				requirements = {},
				chainedEvent = nil,
			},
		},
	},
	requirements = {YearDynamicRequirement{inYears = 1}},
}
