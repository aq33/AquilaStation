/// AQUILA - język zmienia mowę (syk, akcent) przez tę prockę, nie wprost przez handle_speech().
/// Moduł infiltracyjny hardsuitu odpowiada na COMSIG_TRY_MODIFY_SPEECH i wtedy mowa zostaje bez zmian (jak w tg).
/obj/item/organ/tongue/proc/try_handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	if(SEND_SIGNAL(source, COMSIG_TRY_MODIFY_SPEECH) & PREVENT_MODIFY_SPEECH)
		return
	return handle_speech(source, speech_args)
