package main

EventEnum :: enum {
	INTRO,
}

EVENT_CHAINS: [EventEnum]^Event = {
	.INTRO = &EVENT_INTRO,
}


EVENT_TODO: Event = {
	type = NarrativeEvent{header = "TODO", options = {}},
}

/////////////////
//   INTRO    //
EVENT_INTRO: Event = {
	type = NarrativeEvent {
		header = "Intro",
		text = get_u8(
			"At the age of ten you were approached by a strange man, talking about strange things. About a curse, different lifetimes, the burden of life and how everyone dies in the end. " +
			"He told you the burden was yours now. A chuckle pacing towards the laughter of a madman. 'I have blood on my hands! Now that blood is yours boy!'.",
		),
		options = {
			{
				text = get_u8("*Hold your breath*"),
				triggers = {},
				requirements = {},
				chainedEvent = {&EVENT_INTRO_HOLD_BREATH},
			},
			{
				text = get_u8("Question his sanity"),
				triggers = {},
				requirements = {},
				chainedEvent = {&EVENT_INTRO_QUESTION_SANITY},
			},
			{
				text = get_u8("Ask him how to break the time loop"),
				triggers = {},
				requirements = {StatRequirement{.INT, 20}},
				chainedEvent = {&EVENT_TODO},
			},
		},
	},
	requirements = {},
	triggers = {SceneUnlock{.MARKET}},
	chainedEvent = {},
}

EVENT_INTRO_HOLD_BREATH: Event = {
	type = NarrativeEvent {
		header = "Intro",
		text = get_u8(
			"You stare in awe as the man fades away into nothing. 'Finally...Rest'. The words cling in your ear as you stand left in silence.",
		),
		options = {},
	},
	requirements = {},
	triggers = {},
	chainedEvent = {&EVENT_OUTRO},
}

EVENT_INTRO_QUESTION_SANITY: Event = {
	type = NarrativeEvent {
		header = "Intro",
		text = get_u8(
			"'Are you daft boy?' the man utters in irritation. The man fades away with a deep sigh. " +
			"You can't help thinking, maybe the man was daft. He obviously tried to tell you something, but only " +
			"managed to talk rubbish. +1 to Intelligence",
		),
		options = {},
	},
	requirements = {},
	triggers = {StatGain{type = .INT, gain = 1}},
	chainedEvent = {&EVENT_OUTRO},
}

EVENT_OUTRO: Event = {
	type = NarrativeEvent {
		header = "Intro",
		text = get_u8(
			"Two years has passed since your encounter with the strange man. You've felt no " +
			"curse. The man must've been mad. A new law was recently announced, the king pronounced that every man and woman in his realm " +
			"shall be given education. To learn about plants, farming, reading and counting.",
		),
		options = {
			{
				text = get_u8("Enroll to school"),
				requirements = {},
				triggers = {SceneUnlock{.SCHOOL}},
				chainedEvent = {&EVENT_TODO},
			},
			{
				text = get_u8("Skip school - it's better to get a job"),
				requirements = {},
				triggers = {},
				chainedEvent = {&EVENT_TODO},
			},
		},
	},
	requirements = {},
	triggers = {AgeGain{years = 2}},
	chainedEvent = {},
}
