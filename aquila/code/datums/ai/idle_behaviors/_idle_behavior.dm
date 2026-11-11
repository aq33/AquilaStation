// AQUILA: port of BeeStation/BeeStation-Hornet code/datums/ai/idle_behaviors/_idle_behavior.dm (bee/master 0adf0fe9ae)
/datum/idle_behavior

/datum/idle_behavior/proc/perform_idle_behavior(delta_time, datum/ai_controller/controller)
	set waitfor = FALSE
	SHOULD_CALL_PARENT(TRUE)
