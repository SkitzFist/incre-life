package main

/* 
    Not satisfied with this solution, might be to generic.
    mayeb let each scene build their own queue of events. Or something simpler. 
    
    GraduateEvent might be stupid. Maybe it's better to let a SchoolLevel decide how many
    years it should take, and at the end, it can just do whatever steps are necessary to start
    the next. 

    and in story content, story elements could be it's own scene, also letting it control its
    own events, in similar fashion as above mentioned GraduateEvent.
*/

GraduateEvent :: struct {
	elegiblePaths: []SchoolLevel,
	atYear:        int,
}

TimelineEvent :: union {
	GraduateEvent,
}

TimeLineYear :: struct {
	events: []TimelineEvent,
	year:   int,
}

TimeLine :: struct {
	yearlyEvents: []TimeLineYear,
	atIndex:      int,
}
