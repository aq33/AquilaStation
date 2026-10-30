/obj/effect/proc_holder/spell/voice_of_god
	name = "Głos Boga"
	desc = "Mówisz niezwykle przekonującym głosem, zmuszając słuchaczy do wykonywania twoich poleceń."
	charge_max = 1200 //variable
	cooldown_min = 0
	level_max = 1
	clothes_req = FALSE
	antimagic_allowed = TRUE
	action_icon = 'icons/mob/actions/actions_items.dmi'
	action_icon_state = "voice_of_god"
	var/command
	var/cooldown_mod = 1
	var/power_mod = 1
	var/list/spans = list("colossus","yell")
	var/invoke_sound = 'sound/magic/clockwork/invoke_general.ogg' // AQ EDIT (speech_sound -> invoke_sound)

/obj/effect/proc_holder/spell/voice_of_god/can_cast(mob/user = usr)
	if(!user.can_speak())
		to_chat(user, "<span class='warning'>Nie możesz mówić!</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/voice_of_god/choose_targets(mob/user = usr)
	perform(user=user)
/obj/effect/proc_holder/spell/voice_of_god/perform(list/targets, recharge = 1, mob/user = usr)
	command = input(user, "Przemów Głosem Boga", "Rozkaz")
	if(QDELETED(src) || QDELETED(user))
		return
	if(!command)
		revert_cast(user)
		return
	..()

/obj/effect/proc_holder/spell/voice_of_god/cast(list/targets, mob/user = usr)
	playsound(get_turf(user), invoke_sound, 300, 1, 5)
	var/cooldown = voice_of_god(uppertext(command), user, spans, base_multiplier = power_mod)
	charge_max = (cooldown * cooldown_mod)

/obj/effect/proc_holder/spell/voice_of_god/clown
	name = "Głos Klauna"
	desc = "Mówisz niezwykle zabawnym głosem, zaskakując ludzi tak, że przez chwilę cię słuchają."
	power_mod = 0.1
	cooldown_mod = 0.5
	spans = list("clown")
	invoke_sound = 'sound/spookoween/scary_horn2.ogg'
