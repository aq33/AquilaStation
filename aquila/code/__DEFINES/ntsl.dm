///If something is an 'object' to NTSL scripting.
#define IS_OBJECT(thing) (istype(thing, /datum) || istype(thing, /list) || istype(thing, /savefile) || istype(thing, /client) || (thing==world))
