
/// gives us the stack trace from CRASH() without ending the current proc.
/proc/stack_trace(msg)
	// AQ EDIT START - auxmos (generic_fire w citadel.rs) zwraca błąd, gdy gaz przeszedł próg reakcji, ale ma znikome paliwo
	// albo utleniacz: reakcja się nie odbywa i nic więcej się nie dzieje. Przez FFI przychodzi jako pusty runtime, który
	// w testach losowo psuje clean_run.lk i testy liczące runtime'y. Zostaje w logu jako ostrzeżenie.
	if(istext(msg) && (findtext(msg, "Gas has no fuel even though it passed fuel check!") || findtext(msg, "Gas has no oxidizer even though it passed oxidizer check!")))
		warning("auxmos: [replacetext(msg, "\n", " ")]")
		return
	// AQ EDIT END
	CRASH(msg)

/datum/proc/stack_trace(msg)
	CRASH(msg)

GLOBAL_REAL_VAR(list/stack_trace_storage)
/proc/gib_stack_trace()
	stack_trace_storage = list()
	stack_trace()
	stack_trace_storage.Cut(1, min(3,stack_trace_storage.len))
	. = stack_trace_storage
	stack_trace_storage = null
