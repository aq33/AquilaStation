/// 1 tile up
#define UI_HUMANITY_DISPLAY "WEST:6,CENTER+1:0"
/// 1 tile down
#define UI_BLOOD_DISPLAY "WEST:6,CENTER-1:0"
/// 2 tiles down
#define UI_VAMPRANK_DISPLAY "WEST:6,CENTER-2:-5"
/// 6 pixels to the right, zero tiles & 5 pixels DOWN.
#define UI_SUNLIGHT_DISPLAY "WEST:6,CENTER-0:0"

///Maptext define for Vampire HUDs
#define FORMAT_VAMPIRE_HUD_TEXT(valuecolor, value) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[round(value,1)]</font></div>")
///Maptext define for Vampire Sunlight HUDs
#define FORMAT_VAMPIRE_SUNLIGHT_TEXT(valuecolor, value) MAPTEXT("<div align='center' valign='bottom' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[value]</font></div>")

/atom/movable/screen/vampire
	icon = 'aquila/icons/vampires/actions_vampire.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/vampire/blood_counter
	name = "Licznik krwi"
	icon_state = "blood_display"
	screen_loc = UI_BLOOD_DISPLAY

/atom/movable/screen/vampire/blood_counter/Click()
	. = ..()
	var/list/msg = list()
	var/mob/living/owner_mob = hud.mymob
	var/datum/antagonist/vampire/owner_vamp = IS_VAMPIRE(owner_mob)

	if(!owner_vamp)
		return

	msg += span_cultlarge("To twój licznik krwi.")
	msg += span_cult("Widzisz tu obecny poziom energii krwi. Zasila wszystkie twoje zdolności i podtrzymuje samo twoje istnienie.")
	msg += span_cult("\n<b>Żeby awansować, musisz wypić określoną ilość krwi z żywych, świadomych istot.</b>")
	msg += span_cult("Od niej zależy też twoje leczenie. Pełnię możliwości regeneracji osiągasz przy [BS_BLOOD_VOLUME_MAX_REGEN].")

	var/bloodlevel
	switch(owner_vamp.current_vitae)
		if(0 to 200)
			bloodlevel = "zagłodzony"
		if(201 to 500)
			bloodlevel = "spragniony"
		if(501 to 700)
			bloodlevel = "lekko głodny"
		if(701 to INFINITY)
			bloodlevel = "syty"

	msg += span_cult("Twoje obecne maksimum to: [owner_vamp.max_vitae].")
	msg += span_cult("Na tej zmianie wypiłeś już [owner_vamp.total_blood_drank] j. krwi.")

	msg += span_cultlarge("\n<b>W tej chwili czujesz się: <i>[bloodlevel].</i></b>")

	if(owner_vamp.vitae_goal_progress <= owner_vamp.current_vitae_goal)
		msg += span_cultlarge("\n<b>Postęp do następnego awansu: <i>[owner_vamp.vitae_goal_progress]/[owner_vamp.current_vitae_goal].</i></b>")
	else
		msg += span_cultlarge("\n<b>Piłeś głęboko i łapczywie. Przy następnym Sol awansujesz.</b>")

	to_chat(usr, examine_block(msg.Join("\n")))

/atom/movable/screen/vampire/rank_counter
	name = "Licznik rangi"
	icon_state = "rank"
	screen_loc = UI_VAMPRANK_DISPLAY

/atom/movable/screen/vampire/rank_counter/Click()
	. = ..()
	var/list/msg = list()
	var/mob/living/owner_mob = hud.mymob
	var/datum/antagonist/vampire/owner_vamp = IS_VAMPIRE(owner_mob)

	if(!owner_vamp)
		return

	var/mob/living/carbon/human/vampire_human = owner_mob
	msg += span_cultlarge("To twój licznik rangi.")
	msg += span_cult("Widzisz tu, jak daleko zaszło opanowanie twoich dyscyplin.")
	msg += span_cult("To główna miara twojego rozwoju jako wampira. Jeśli pożywisz się innym wampirem (który złamał Maskaradę), wchłoniesz połowę jego poziomów.")
	msg += span_cult("<b>Z obecną rangą uchodzisz za: [owner_vamp.get_rank_string()].</b>")
	msg += span_cult("\n<b>Obecnie twoja ranga daje ci następujące korzyści:</b>")
	msg += span_cult("Maks. tempo regeneracji: +[owner_vamp.vampire_regen_rate]")
	msg += span_cult("Maks. zapas vitae: +[owner_vamp.max_vitae - 600] ")
	msg += span_cult("Obrażenia bez broni: +[vampire_human.unarmed_damage_bonus]")

	var/list/disciplinestext
	for(var/datum/discipline/discipline in owner_vamp.owned_disciplines)
		disciplinestext += "\n[discipline.name] - "
		disciplinestext += "Poziom:"
		disciplinestext += "[discipline.level - 1]"

	if(disciplinestext)
		msg += span_cult("\n<b>Twoje dyscypliny i ich poziomy:</b>[disciplinestext]")

	to_chat(usr, examine_block(msg.Join("\n")))

/atom/movable/screen/vampire/sunlight_counter
	name = "Licznik słońca"
	icon_state = "sunlight"
	screen_loc = UI_SUNLIGHT_DISPLAY

/atom/movable/screen/vampire/sunlight_counter/Click()
	. = ..()
	var/list/msg = list()
	var/mob/living/owner_mob = hud.mymob
	var/datum/antagonist/vampire/owner_vamp = IS_VAMPIRE(owner_mob)

	if(!owner_vamp)
		return

	msg += span_cultlarge("To wskaźnik Sol.")
	msg += span_cult("Widzisz tu obecny stan Sol, częstych rozbłysków słonecznych pobliskiej gwiazdy.")
	msg += span_cult("Choć wampiry od dawna dobrze się miewają na kosmicznych instalacjach, nieprzewidywalne zachowanie słońca Auri-Geminae grozi Ostateczną Śmiercią nawet na osłoniętym statku.")

	var/normal_humanity_divisor = min(2, 1 + (owner_vamp.humanity / 10))
	var/divisor_turned_percentage = ((normal_humanity_divisor - 1) * 200) / 4
	msg += span_cult("\n<b>Twoje obecne Człowieczeństwo daje ci [divisor_turned_percentage]% odporności na spustoszenia Sol.</b>")

	msg += span_cult("\n<b>Gdy nadejdzie Sol, nie daj się złapać na korytarzu. Spłoniesz i ściągniesz na siebie uwagę. Osłoni cię szafka albo technicznie.</b>")

	msg += span_cult("\nNajlepszą ochronę daje oczywiście tylko straszliwy nieśmiertelny sen, torpor.")

	to_chat(usr, examine_block(msg.Join("\n")))

/atom/movable/screen/vampire/humanity_counter
	name = "Licznik Człowieczeństwa"
	icon_state = "humanity"
	screen_loc = UI_HUMANITY_DISPLAY

/atom/movable/screen/vampire/humanity_counter/Click()
	. = ..()
	var/list/msg = list()
	var/mob/living/owner_mob = hud.mymob
	var/datum/antagonist/vampire/owner_vamp = IS_VAMPIRE(owner_mob)

	msg += span_cultlarge("To twój poziom Człowieczeństwa.")
	msg += span_cult("Człowieczeństwo pokazuje, jak mocno wampir trzyma się moralności i wartości śmiertelnego życia, a co za tym idzie, jak dobrze opiera się żądzom Bestii.")
	msg += span_cult("Ma ono realny wpływ na klątwę wszystkich Kainitów. Wampirom o niskim Człowieczeństwie trudniej czuwać za dnia czy budzić się z długiego torporu. Jeśli twoje Człowieczeństwo jest wyjątkowo niskie, możesz nawet stanąć w płomieniach w obecności boskiego światła.")

	var/humanitylevel
	switch(owner_vamp.humanity)
		if(0)
			humanitylevel = "potworny"
		if(1)
			humanitylevel = "przerażający"
		if(2)
			humanitylevel = "zwierzęcy"
		if(3)
			humanitylevel = "zimny"
		if(4)
			humanitylevel = "nieczuły"
		if(5)
			humanitylevel = "obojętny"
		if(6)
			humanitylevel = "zdystansowany"
		if(7)
			humanitylevel = "zwyczajny"
		if(8)
			humanitylevel = "troskliwy"
		if(9)
			humanitylevel = "współczujący"
		if(10)
			humanitylevel = "święty"

	// Pardon me for my math, i was never good at this.

	var/normal_humanity_divisor = min(2, 1 + (owner_vamp.humanity / 10))
	var/divisor_turned_percentage = ((normal_humanity_divisor - 1) * 200) / 4

	msg += span_cult("\n<b>W tej chwili inni opisaliby cię jako <i>'[humanitylevel]'</i>, co daje ci [divisor_turned_percentage]% odporności na spustoszenia Sol.</b>")
	if(owner_vamp.humanity > 7)
		msg += span_cult("Dzięki więzi z własną ludzką duszą zyskujesz moc Maskarady.")

	msg += span_cult("\n<b>Człowieczeństwo możesz odzyskać, robiąc ludzkie rzeczy, na przykład:</b>")
	msg += span_cult("Przytulanie różnych śmiertelników: [length(owner_vamp.humanity_trackgain_hugged)] z [owner_vamp.humanity_hugging_goal].")
	msg += span_cult("Głaskanie różnych zwierząt: [length(owner_vamp.humanity_trackgain_petted)] z [owner_vamp.humanity_petting_goal].")
	msg += span_cult("Oglądanie sztuki: [length(owner_vamp.humanity_trackgain_art)] z [owner_vamp.humanity_art_goal].")

	var/frenzy_modifier = owner_vamp.get_frenzy_humanity_modifier()
	var/frenzy_enter = FRENZY_THRESHOLD_ENTER + frenzy_modifier
	var/frenzy_exit = FRENZY_THRESHOLD_EXIT + frenzy_modifier
	msg += span_cult("\n<b>Przez obecny poziom Człowieczeństwa progi Szału wyglądają tak:</b>")
	msg += span_cult("\nWpadniesz w Szał, gdy spadniesz poniżej <b>[frenzy_enter]</b>, a zaspokoisz głód dopiero powyżej <b>[frenzy_exit]</b>.")
	if(owner_vamp.humanity < 7)
		msg += span_cult("<i>Brak Człowieczeństwa utrudnia panowanie nad Bestią. (+[frenzy_modifier] za niskie Człowieczeństwo)</i>")

	to_chat(usr, examine_block(msg.Join("\n")))

/// Update Blood Counter + Rank Counter
/datum/antagonist/vampire/proc/update_hud()
	var/valuecolor
	switch(current_vitae)
		if(0 to 200)
			valuecolor = "#560808"
		if(201 to 300)
			valuecolor = "#a32a2a"
		if(301 to 500)
			valuecolor = "#d55c5c"
		if(501 to 700)	// This isn't janky, a tiny bit lenience is baked in.
			valuecolor = "#ffc2c2"
		if(701 to INFINITY)
			valuecolor = "#ffffff"

	blood_display?.maptext = FORMAT_VAMPIRE_HUD_TEXT(valuecolor, current_vitae)

	if(vamprank_display)
		if(vampire_level_unspent > 0)
			vamprank_display.icon_state = "[initial(vamprank_display.icon_state)]_up"
		else
			vamprank_display.icon_state = initial(vamprank_display.icon_state)
		vamprank_display.maptext = FORMAT_VAMPIRE_HUD_TEXT("#ffd8d8", vampire_level)

	if(humanity_display)
		var/humanityvaluecolor
		switch(humanity)
			if(0 to 2)
				humanityvaluecolor = "#600000"
			if(3 to 4)
				humanityvaluecolor = "#a71c1c"
			if(4 to 5)
				humanityvaluecolor = "#db4646"
			if(6 to 8)	// same here
				humanityvaluecolor = "#e8adad"
			if(9 to 10)
				humanityvaluecolor = "#ffffff"

		humanity_display.maptext = FORMAT_VAMPIRE_HUD_TEXT(humanityvaluecolor, humanity)

	if(sunlight_display)
		var/sunlightvaluecolor = "#ffffff"
		if(SSsunlight.sunlight_active)
			sunlightvaluecolor = "#FF5555"
			sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_day"
		else
			switch(round(SSsunlight.time_til_cycle, 1))
				if(0 to 30)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_30"
					sunlightvaluecolor = "#FFCCCC"
				if(31 to 60)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_60"
					sunlightvaluecolor = "#FFE6CC"
				if(61 to 90)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_90"
					sunlightvaluecolor = "#FFFFCC"
				else
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_night"
					sunlightvaluecolor = "#FFFFFF"

		sunlight_display.maptext = FORMAT_VAMPIRE_SUNLIGHT_TEXT( \
			sunlightvaluecolor, \
			(SSsunlight.time_til_cycle >= 60) ? "[round(SSsunlight.time_til_cycle / 60, 1)] m" : "[round(SSsunlight.time_til_cycle, 1)] s" \
		)

/// 1 tile up
#undef UI_HUMANITY_DISPLAY
/// 1 tile down
#undef UI_BLOOD_DISPLAY
/// 2 tiles down
#undef UI_VAMPRANK_DISPLAY
/// 6 pixels to the right, zero tiles & 5 pixels DOWN.
#undef UI_SUNLIGHT_DISPLAY

///Maptext define for Vampire HUDs
#undef FORMAT_VAMPIRE_HUD_TEXT
///Maptext define for Vampire Sunlight HUDs
#undef FORMAT_VAMPIRE_SUNLIGHT_TEXT
