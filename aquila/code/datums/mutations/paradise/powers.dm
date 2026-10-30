// AQUILA - port z ParadiseSS13 (code/game/dna/mutations/mutation_powers.dm, disabilities.dm)
// Geny ze zdolnością (/datum/action/cooldown/spell zamiast /datum/spell z Paradise).

/datum/action/cooldown/spell/paradise
	icon_icon = 'aquila/icons/mutations/paradise/actions.dmi'
	spell_requirements = NONE
	antimagic_flags = NONE

// Incendiary Mitochondria - samozapłon

/datum/mutation/immolate
	name = "Zapalające mitochondria"
	desc = "Pacjent potrafi zamieniać nadmiar energii komórkowej w ciepło."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='warning'>Nagle robi ci się dość gorąco.</span>"
	text_lose_indication = "<span class='notice'>Nie jest ci już nieprzyjemnie gorąco.</span>"
	action_path = /datum/action/cooldown/spell/paradise/immolate

/datum/action/cooldown/spell/paradise/immolate
	name = "Zapalające mitochondria"
	desc = "Zamień nadmiar energii komórkowej w ciepło i stań w płomieniach."
	button_icon_state = "genetic_incendiary"
	cooldown_time = 60 SECONDS
	sound = 'sound/effects/bamf.ogg'

/datum/action/cooldown/spell/paradise/immolate/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/paradise/immolate/cast(mob/living/cast_on)
	. = ..()
	cast_on.adjust_fire_stacks(0.5)
	cast_on.visible_message("<span class='danger'><b>[cast_on]</b> nagle staje w płomieniach!</span>")
	cast_on.ignite_mob()

// Empathic Thought - czytanie stanu, nastroju i myśli

/datum/mutation/empath
	name = "Empatyczna myśl"
	desc = "Pacjent potrafi wyczytać z cudzych umysłów pewne informacje."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Nagle zauważasz u innych więcej niż wcześniej.</span>"
	text_lose_indication = "<span class='notice'>Nie wyczuwasz już cudzych zamiarów.</span>"
	instability = 10
	difficulty = 12
	energy_coeff = 1
	action_path = /datum/action/cooldown/spell/pointed/paradise_empath

/datum/action/cooldown/spell/pointed/paradise_empath
	name = "Czytaj w umyśle"
	desc = "Zajrzyj w cudze myśli po kilka informacji."
	icon_icon = 'aquila/icons/mutations/paradise/actions.dmi'
	button_icon_state = "genetic_empath"
	cooldown_time = 18 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN
	antimagic_flags = MAGIC_RESISTANCE_MIND
	active_msg = "Skupiasz się na cudzych myślach..."
	deactive_msg = "Przestajesz się skupiać."

/datum/action/cooldown/spell/pointed/paradise_empath/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return
	if(!iscarbon(cast_on))
		to_chat(owner, "<span class='warning'>Możesz tego użyć tylko na innych istotach organicznych.</span>")
		return FALSE

/datum/action/cooldown/spell/pointed/paradise_empath/cast(mob/living/carbon/cast_on)
	. = ..()
	var/mob/living/carbon/M = cast_on
	if(paradise_psy_resistant(M) || M.can_block_magic(antimagic_flags) || istype(M.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/foilhat))
		to_chat(owner, "<span class='warning'>W ogóle nie możesz zajrzeć do umysłu [M]!</span>")
		return
	if(M.stat == DEAD)
		to_chat(owner, "<span class='warning'>[M] nie żyje, nie da się czytać jego myśli.</span>")
		return
	if(M.health < 0)
		to_chat(owner, "<span class='warning'>[M] umiera, jego myśli są zbyt poszarpane, żeby je odczytać.</span>")
		return

	to_chat(owner, "<span class='notice'>Odczyt myśli <b>[M]:</b></span>")

	var/pain_condition = M.health / M.maxHealth
	var/list/random_thoughts = list("tym, co zjeść na obiad", "przyszłości", "przeszłości", "pieniądzach",
		"swoich włosach", "tym, co robić dalej", "swojej pracy", "kosmosie", "zabawnych rzeczach", "smutnych rzeczach",
		"irytujących rzeczach", "szczęśliwych rzeczach", "czymś niespójnym", "czymś, co zrobił źle")
	var/thoughts = "myśli o [pick(random_thoughts)]"

	if(M.fire_stacks > 0)
		pain_condition -= 0.5
		thoughts = "jest zaprzątnięty ogniem"
	if(M.radiation)
		pain_condition -= 0.25

	switch(pain_condition)
		if(0.81 to INFINITY)
			to_chat(owner, "<span class='notice'><b>Stan</b>: [M] czuje się dobrze.</span>")
		if(0.61 to 0.8)
			to_chat(owner, "<span class='notice'><b>Stan</b>: [M] odczuwa lekki ból.</span>")
		if(0.41 to 0.6)
			to_chat(owner, "<span class='notice'><b>Stan</b>: [M] odczuwa znaczny ból.</span>")
		if(0.21 to 0.4)
			to_chat(owner, "<span class='notice'><b>Stan</b>: [M] odczuwa silny ból.</span>")
		else
			to_chat(owner, "<span class='notice'><b>Stan</b>: [M] odczuwa nieznośny ból.</span>")
			thoughts = "jest nawiedzany przez własną śmiertelność"

	// u nas combat mode zamiast samych intencji: poza trybem walki zamiary są dobre
	var/mood_intent = M.combat_mode ? M.a_intent : INTENT_HELP
	switch(mood_intent)
		if(INTENT_HELP)
			to_chat(owner, "<span class='notice'><b>Nastrój</b>: Wyczuwasz u [M] życzliwe myśli.</span>")
		if(INTENT_DISARM)
			to_chat(owner, "<span class='notice'><b>Nastrój</b>: Wyczuwasz u [M] ostrożne myśli.</span>")
		if(INTENT_GRAB)
			to_chat(owner, "<span class='notice'><b>Nastrój</b>: Wyczuwasz u [M] wrogie myśli.</span>")
		if(INTENT_HARM)
			to_chat(owner, "<span class='notice'><b>Nastrój</b>: Wyczuwasz u [M] okrutne myśli.</span>")
			for(var/mob/living/L in view(7, M))
				if(L == M)
					continue
				thoughts = "myśli o tym, żeby przywalić [L]"
				break
		else
			to_chat(owner, "<span class='notice'><b>Nastrój</b>: Wyczuwasz u [M] dziwne myśli.</span>")

	// u nas konta nie mają PIN-u: zamiast niego numer konta i saldo
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/bank_account/account = paradise_find_account(H)
		if(account)
			to_chat(owner, "<span class='notice'><b>Liczby</b>: Wyczuwasz, że ważne są dla [M] liczby [account.account_id] i [account.account_balance] kr.</span>")
	to_chat(owner, "<span class='notice'><b>Myśli</b>: [M] właśnie [thoughts].</span>")

	if(M.dna?.check_mutation(/datum/mutation/empath))
		to_chat(M, "<span class='warning'>Wyczuwasz, że [owner] czyta twoje myśli.</span>")
	else if(prob(5) || M.mind?.assigned_role == "Chaplain")
		to_chat(M, "<span class='warning'>Wyczuwasz, że ktoś wdziera się do twoich myśli...</span>")

/// Konto osobiste: najpierw to, z którym przyszedł na rundę, potem to z karty ID
/datum/action/cooldown/spell/pointed/paradise_empath/proc/paradise_find_account(mob/living/carbon/human/H)
	if(H.account_id)
		for(var/datum/bank_account/account as anything in SSeconomy.bank_accounts)
			if(account.account_id == H.account_id)
				return account
	var/datum/bank_account/id_account = H.get_bank_account()
	return id_account || null

// Polymorphism - przybranie wyglądu kogoś obok

/datum/mutation/polymorph
	name = "Polimorfizm"
	desc = "Pacjent potrafi zmienić wygląd tak, żeby przypominać inne osoby."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Jakoś nie czujesz się do końca sobą.</span>"
	text_lose_indication = "<span class='notice'>Czujesz się pewnie we własnej tożsamości.</span>"
	instability = 25
	difficulty = 16
	energy_coeff = 1
	action_path = /datum/action/cooldown/spell/pointed/paradise_polymorph

/datum/action/cooldown/spell/pointed/paradise_polymorph
	name = "Polimorfia"
	desc = "Przybierz wygląd kogoś, kto stoi obok."
	icon_icon = 'aquila/icons/mutations/paradise/actions.dmi'
	button_icon_state = "genetic_poly"
	cooldown_time = 180 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN
	antimagic_flags = NONE
	cast_range = 1
	active_msg = "Twoje ciało staje się niestabilne. Kliknij kogoś, żeby przybrać jego wygląd."
	deactive_msg = "Twoje ciało znów się uspokaja."

/datum/action/cooldown/spell/pointed/paradise_polymorph/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/target = cast_on
	if(!istype(target) || !target.has_dna())
		to_chat(owner, "<span class='warning'>Możesz skopiować tylko wygląd człowieka!</span>")
		return FALSE

/datum/action/cooldown/spell/pointed/paradise_polymorph/cast(mob/living/carbon/human/cast_on)
	. = ..()
	owner.visible_message("<span class='warning'>Ciało [owner] wygina się i skręca.</span>")
	addtimer(CALLBACK(src, PROC_REF(transform), cast_on), 1 SECONDS)

/datum/action/cooldown/spell/pointed/paradise_polymorph/proc/transform(mob/living/carbon/human/target)
	var/mob/living/carbon/human/user = owner
	if(QDELETED(target) || !istype(user) || user.stat == DEAD || !target.has_dna() || !user.has_dna())
		return
	playsound(get_turf(user), 'sound/misc/splort.ogg', 50, TRUE)
	user.dna.uni_identity = target.dna.uni_identity
	if(user.dna.species.type == target.dna.species.type)
		user.dna.features = target.dna.features.Copy()
	user.gender = target.gender
	user.updateappearance(mutcolor_update = TRUE, mutations_overlay_update = TRUE)
	user.real_name = target.real_name
	user.name = target.name

// Morphism - dowolna zmiana wyglądu z menu (jak magiczne lustro, bez zmiany rasy i imienia)

/datum/mutation/morph
	name = "Morfizm"
	desc = "Pacjent potrafi zmienić wygląd na wygląd dowolnego człowieka."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Czujesz, że twoje ciało potrafi zmieniać wygląd.</span>"
	text_lose_indication = "<span class='notice'>Twoje ciało nie potrafi już zmieniać wyglądu.</span>"
	instability = 25
	difficulty = 16
	energy_coeff = 1
	action_path = /datum/action/cooldown/spell/paradise/morph

/datum/action/cooldown/spell/paradise/morph
	name = "Przemiana"
	desc = "Zmień swój wygląd według uznania."
	button_icon_state = "genetic_morph"
	cooldown_time = 180 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN
	/// Czy ostatnie użycie coś zmieniło
	var/morphed = FALSE

/datum/action/cooldown/spell/paradise/morph/before_cast(atom/cast_on)
	. = ..()
	if(ismob(owner.loc))
		to_chat(owner, "<span class='warning'>Nie możesz teraz zmienić wyglądu!</span>")
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/paradise/morph/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !H.has_dna())
		return
	var/changed = FALSE
	while(TRUE)
		var/list/options = list("Kolor oczu", "Fryzura", "Kolor włosów", "Zarost", "Kolor zarostu")
		if(H.dna.species.sexes)
			options.Insert(1, "Płeć")
		if(H.dna.species.use_skintones)
			options += "Odcień skóry"
		if(MUTCOLORS in H.dna.species.species_traits)
			options += "Kolor ciała"
		var/choice = input(H, "Co chcesz zmienić?", "Przemiana") as null|anything in options
		if(!choice || QDELETED(H) || H.stat != CONSCIOUS || owner != H)
			break
		switch(choice)
			if("Płeć")
				var/new_gender = alert(H, "Wybierz płeć.", "Przemiana", "Mężczyzna", "Kobieta")
				if(!new_gender)
					continue
				H.gender = (new_gender == "Mężczyzna") ? MALE : FEMALE
				H.dna.update_ui_block(DNA_GENDER_BLOCK)
			if("Kolor oczu")
				var/new_eyes = input(H, "Wybierz kolor oczu.", "Przemiana", "#" + H.eye_color) as color|null
				if(!new_eyes)
					continue
				H.eye_color = sanitize_hexcolor(new_eyes)
				H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
			if("Fryzura")
				var/new_style = input(H, "Wybierz fryzurę.", "Przemiana", H.hair_style) as null|anything in GLOB.hair_styles_list
				if(!new_style)
					continue
				H.hair_style = new_style
				H.dna.update_ui_block(DNA_HAIR_STYLE_BLOCK)
			if("Kolor włosów")
				var/new_hair = input(H, "Wybierz kolor włosów.", "Przemiana", "#" + H.hair_color) as color|null
				if(!new_hair)
					continue
				H.hair_color = sanitize_hexcolor(new_hair)
				H.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
			if("Zarost")
				var/new_style = input(H, "Wybierz zarost.", "Przemiana", H.facial_hair_style) as null|anything in GLOB.facial_hair_styles_list
				if(!new_style)
					continue
				H.facial_hair_style = new_style
				H.dna.update_ui_block(DNA_FACIAL_HAIR_STYLE_BLOCK)
			if("Kolor zarostu")
				var/new_facial = input(H, "Wybierz kolor zarostu.", "Przemiana", "#" + H.facial_hair_color) as color|null
				if(!new_facial)
					continue
				H.facial_hair_color = sanitize_hexcolor(new_facial)
				H.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)
			if("Odcień skóry")
				var/new_tone = input(H, "Wybierz odcień skóry.", "Przemiana", H.skin_tone) as null|anything in GLOB.skin_tones
				if(!new_tone)
					continue
				H.skin_tone = new_tone
				H.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)
			if("Kolor ciała")
				var/new_color = input(H, "Wybierz kolor ciała.", "Przemiana", "#" + H.dna.features["mcolor"]) as color|null
				if(!new_color)
					continue
				// jak w magicznym lustrze: kolor musi być dość jasny
				if(ReadHSV(RGBtoHSV(new_color))[3] < ReadHSV("#7F7F7F")[3])
					to_chat(H, "<span class='notice'>Nieprawidłowy kolor. Twój kolor nie jest wystarczająco jasny.</span>")
					continue
				H.dna.features["mcolor"] = sanitize_hexcolor(new_color)
		changed = TRUE
		H.update_body()
		H.update_hair()
		H.update_body_parts(TRUE)
		H.update_mutations_overlay()
	morphed = changed
	if(changed && !QDELETED(H))
		H.visible_message("<span class='notice'>[H] przemienia się i zmienia wygląd!</span>", \
			"<span class='notice'>Zmieniasz swój wygląd!</span>", \
			"<span class='warning'>O Boże! Co to było? Brzmiało jak miażdżone ciało i kości szlifowane w nowy kształt!</span>")

/datum/action/cooldown/spell/paradise/morph/after_cast(atom/cast_on)
	. = ..()
	// nic nie zmieniono - bez odnowienia
	if(!morphed)
		reset_spell_cooldown()

// Remote Viewing - podgląd innych zdalnych widzów z dowolnej odległości

/datum/mutation/remote_view
	name = "Zdalne widzenie"
	desc = "Pacjent może z dowolnej odległości przenieść swój wzrok do umysłów innych zdalnych obserwatorów."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twój umysł widzi rzeczy z daleka.</span>"
	text_lose_indication = "<span class='notice'>Twój umysł nie widzi już rzeczy z daleka.</span>"
	instability = 15
	difficulty = 12
	action_path = /datum/action/cooldown/spell/paradise/remote_view

/datum/mutation/remote_view/on_life()
	var/datum/action/cooldown/spell/paradise/remote_view/view = action_power
	if(istype(view))
		view.check_view()

/datum/action/cooldown/spell/paradise/remote_view
	name = "Zdalny podgląd"
	desc = "Podglądaj ludzi z dowolnej odległości. Użyj ponownie, żeby wrócić do siebie."
	button_icon_state = "genetic_view"
	cooldown_time = 10 SECONDS
	antimagic_flags = MAGIC_RESISTANCE_MIND
	/// Jak w Paradise: można podglądać tylko innych z Remote Viewing
	var/only_remote_viewers = TRUE
	/// Kogo teraz podglądamy
	var/mob/living/view_target

/datum/action/cooldown/spell/paradise/remote_view/Destroy()
	stop_view()
	return ..()

/datum/action/cooldown/spell/paradise/remote_view/Remove(mob/remove_from)
	stop_view()
	return ..()

/datum/action/cooldown/spell/paradise/remote_view/is_action_active()
	return !!view_target

/datum/action/cooldown/spell/paradise/remote_view/before_cast(atom/cast_on)
	. = ..()
	// drugie użycie wraca do własnego ciała bez odnowienia
	if(view_target)
		stop_view()
		return . | SPELL_CANCEL_CAST
	if(istype(owner.get_active_held_item(), /obj/item/tk_grab) || istype(owner.get_inactive_held_item(), /obj/item/tk_grab))
		to_chat(owner, "<span class='warning'>Twój umysł jest zbyt zajęty telekinetycznym chwytem.</span>")
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/paradise/remote_view/cast(atom/cast_on)
	. = ..()
	var/list/viewers = list()
	for(var/mob/living/M as anything in GLOB.alive_mob_list)
		if(M == owner || !M.ckey && !M.mind)
			continue
		if(paradise_psy_resistant(M))
			continue
		if(only_remote_viewers)
			var/mob/living/carbon/C = M
			if(!istype(C) || !C.dna?.check_mutation(/datum/mutation/remote_view))
				continue
		viewers += M
	if(!length(viewers))
		to_chat(owner, "<span class='warning'>Nie wyczuwasz żadnego umysłu, w który dałoby się zajrzeć.</span>")
		return
	var/mob/living/target = input(owner, "Kogo chcesz podglądać?", "Zdalne widzenie") as null|anything in viewers
	if(QDELETED(target) || QDELETED(owner) || owner.stat != CONSCIOUS || paradise_psy_resistant(target))
		return
	start_view(target)

/datum/action/cooldown/spell/paradise/remote_view/proc/start_view(mob/living/target)
	view_target = target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_target_deleted))
	owner.reset_perspective(target)
	UpdateButtonIcon()

/datum/action/cooldown/spell/paradise/remote_view/proc/stop_view()
	if(!view_target)
		return
	UnregisterSignal(view_target, COMSIG_PARENT_QDELETING)
	var/mob/living/old_target = view_target
	view_target = null
	if(owner?.client?.eye == old_target)
		owner.reset_perspective()
	UpdateButtonIcon()

/datum/action/cooldown/spell/paradise/remote_view/proc/on_target_deleted(datum/source)
	SIGNAL_HANDLER
	stop_view()

/// Co tick życia: przerywa podgląd, gdy cel padł, zamknął umysł albo kamera klienta poszła gdzie indziej
/datum/action/cooldown/spell/paradise/remote_view/proc/check_view()
	if(!view_target)
		return
	if(!owner?.client || owner.client.eye != view_target || owner.stat != CONSCIOUS || view_target.stat != CONSCIOUS || paradise_psy_resistant(view_target))
		stop_view()

// Jumpy - wielki skok

/datum/mutation/jumpy
	name = "Skoczność"
	desc = "Pacjent potrafi skakać na duże odległości."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Mięśnie twoich nóg są napięte i silne.</span>"
	text_lose_indication = "<span class='notice'>Mięśnie twoich nóg wracają do normy.</span>"
	instability = 20
	difficulty = 12
	power_coeff = 1
	energy_coeff = 1
	action_path = /datum/action/cooldown/spell/paradise/leap

/datum/mutation/jumpy/modify()
	. = ..()
	var/datum/action/cooldown/spell/paradise/leap/leap = action_power
	if(istype(leap))
		leap.leap_distance = round(initial(leap.leap_distance) * GET_MUTATION_POWER(src))

/datum/action/cooldown/spell/paradise/leap
	name = "Skok"
	desc = "Skocz bardzo daleko w kierunku, w którym patrzysz!"
	button_icon_state = "genetic_jump"
	cooldown_time = 6 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_STUN | AB_CHECK_LYING
	var/leap_distance = 10

/datum/action/cooldown/spell/paradise/leap/before_cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(ismob(user.loc) || user.buckled || !(user.mobility_flags & MOBILITY_STAND))
		to_chat(user, "<span class='warning'>Nie możesz teraz skoczyć!</span>")
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/paradise/leap/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(isobj(user.loc))
		slam_container(user, user.loc)
		return
	if(!isturf(user.loc))
		return

	// skuty i trzymany przez kogoś stojącego nie ucieknie
	var/failure = FALSE
	if(user.restrained())
		for(var/mob/living/M in range(1, user))
			if(M.pulling != user)
				continue
			if(!M.restrained() && M.stat == CONSCIOUS && (M.mobility_flags & MOBILITY_STAND) && user.Adjacent(M))
				failure = TRUE
			else
				M.stop_pulling()

	user.visible_message("<span class='danger'><b>[user]</b> wykonuje potężny skok!</span>")
	playsound(get_turf(user), 'sound/weapons/thudswoosh.ogg', 50, TRUE)
	if(failure)
		user.Paralyze(10 SECONDS)
		user.visible_message("<span class='warning'>[user] próbuje odskoczyć, ale zostaje przygnieciony z powrotem do ziemi!</span>", \
			"<span class='warning'>Próbujesz odskoczyć, ale nagle ktoś przygniata cię z powrotem do ziemi!</span>", \
			"<span class='notice'>Słyszysz napinanie potężnych mięśni, a zaraz potem łomot ciała o podłogę.</span>")
		return

	var/turf/target = get_ranged_target_turf(user, user.dir, leap_distance)
	if(!target)
		return
	var/old_pass = user.pass_flags
	var/old_layer = user.layer
	var/base_pixel_y = user.pixel_y
	user.pass_flags |= PASSTABLE
	user.layer = ABOVE_MOB_LAYER
	animate(user, pixel_y = base_pixel_y + 16, time = 3, easing = SINE_EASING | EASE_OUT)
	animate(pixel_y = base_pixel_y, time = 3, easing = SINE_EASING | EASE_IN)
	var/datum/callback/landing = CALLBACK(src, PROC_REF(land), user, old_pass, old_layer, base_pixel_y)
	if(!user.throw_at(target, leap_distance, 1, user, FALSE, callback = landing))
		land(user, old_pass, old_layer, base_pixel_y)

/datum/action/cooldown/spell/paradise/leap/proc/land(mob/living/user, old_pass, old_layer, base_pixel_y)
	if(QDELETED(user))
		return
	user.pass_flags = old_pass
	user.layer = old_layer
	user.pixel_y = base_pixel_y
	if(HAS_TRAIT(user, TRAIT_FAT) && prob(66))
		user.visible_message("<span class='danger'><b>[user]</b> rozbija się przez swoją dużą wagę!</span>")
		user.Paralyze(20 SECONDS)

/datum/action/cooldown/spell/paradise/leap/proc/slam_container(mob/living/user, obj/container)
	to_chat(user, "<span class='warning'>Skaczesz i walisz głową w ścianę [container]! Auć!</span>")
	user.Unconscious(6 SECONDS)
	user.Paralyze(10 SECONDS)
	container.visible_message("<span class='danger'>[container] wydaje głośne łupnięcie i lekko się trzęsie.</span>")
	playsound(get_turf(container), 'sound/effects/bang.ogg', 50, TRUE)
	var/old_x = container.pixel_x
	var/old_y = container.pixel_y
	animate(container, pixel_x = old_x + rand(-3, 3), pixel_y = old_y + rand(-3, 3), time = 1)
	for(var/i in 1 to 5)
		animate(pixel_x = old_x + rand(-3, 3), pixel_y = old_y + rand(-3, 3), time = 1)
	animate(pixel_x = old_x, pixel_y = old_y, time = 1)
