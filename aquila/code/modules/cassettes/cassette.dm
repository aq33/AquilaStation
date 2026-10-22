// AQUILA - kaseta z Monkestation (code/modules/cassettes/cassette.dm).
// Kaseta trzyma do 7 utworów na stronę (linki do YouTube, SoundCloud, Bandcamp...). Gra w jukeboxie i walkmanie.

GLOBAL_LIST_INIT(cassette_icons, list(
	"Czysta" = "cassette_flip",
	"Niebieska naklejka" = "cassette_gray",
	"Zielona naklejka" = "cassette_green",
	"Pomarańczowa naklejka" = "cassette_orange",
	"Różowe paski" = "cassette_pink_stripe",
	"Fioletowa naklejka" = "cassette_purple",
	"Tęcza" = "cassette_rainbow",
	"Czerwień i czerń" = "cassette_red_black",
	"Czerwone paski" = "cassette_red_stripe",
	"Moro" = "cassette_camo",
	"Wschodzące słońce" = "cassette_rising_sun",
	"Ocean" = "cassette_ocean",
	"Estetyczna" = "cassette_aesthetic",
))

GLOBAL_LIST_INIT(cassette_asmr_sounds, list(
	'aquila/sound/cassettes/tape_asmr1.ogg', 'aquila/sound/cassettes/tape_asmr2.ogg', 'aquila/sound/cassettes/tape_asmr3.ogg',
	'aquila/sound/cassettes/tape_asmr4.ogg', 'aquila/sound/cassettes/tape_asmr5.ogg', 'aquila/sound/cassettes/tape_asmr6.ogg',
	'aquila/sound/cassettes/tape_asmr7.ogg', 'aquila/sound/cassettes/tape_asmr8.ogg', 'aquila/sound/cassettes/tape_asmr9.ogg',
	'aquila/sound/cassettes/tape_asmr10.ogg'))
GLOBAL_LIST_INIT(cassette_put_in_sounds, list(
	'aquila/sound/cassettes/tape_put_in1.ogg', 'aquila/sound/cassettes/tape_put_in2.ogg', 'aquila/sound/cassettes/tape_put_in3.ogg',
	'aquila/sound/cassettes/tape_put_in4.ogg', 'aquila/sound/cassettes/tape_put_in5.ogg', 'aquila/sound/cassettes/tape_put_in6.ogg'))
GLOBAL_LIST_INIT(cassette_take_out_sounds, list(
	'aquila/sound/cassettes/tape_take_out1.ogg', 'aquila/sound/cassettes/tape_take_out2.ogg', 'aquila/sound/cassettes/tape_take_out3.ogg',
	'aquila/sound/cassettes/tape_take_out4.ogg', 'aquila/sound/cassettes/tape_take_out5.ogg', 'aquila/sound/cassettes/tape_take_out6.ogg'))
/// Otwarcie kieszeni, włożenie kasety, zamknięcie
GLOBAL_LIST_INIT(cassette_insert_sounds, list(
	'aquila/sound/cassettes/machine_open_put_in_andclose1.ogg', 'aquila/sound/cassettes/machine_open_put_in_andclose2.ogg',
	'aquila/sound/cassettes/machine_open_put_in_andclose3.ogg', 'aquila/sound/cassettes/machine_open_put_in_andclose4.ogg',
	'aquila/sound/cassettes/machine_open_put_in_andclose5.ogg'))
/// Otwarcie kieszeni, wyjęcie kasety, zamknięcie
GLOBAL_LIST_INIT(cassette_eject_sounds, list(
	'aquila/sound/cassettes/machine_open_takeout_andclose1.ogg', 'aquila/sound/cassettes/machine_open_takeout_andclose2.ogg',
	'aquila/sound/cassettes/machine_open_takeout_andclose3.ogg', 'aquila/sound/cassettes/machine_open_takeout_andclose4.ogg'))
GLOBAL_LIST_INIT(cassette_play_sounds, list(
	'aquila/sound/cassettes/machine_play1.ogg', 'aquila/sound/cassettes/machine_play2.ogg', 'aquila/sound/cassettes/machine_play3.ogg',
	'aquila/sound/cassettes/machine_play4.ogg', 'aquila/sound/cassettes/machine_play5.ogg', 'aquila/sound/cassettes/machine_play6.ogg'))
GLOBAL_LIST_INIT(cassette_stop_sounds, list(
	'aquila/sound/cassettes/machine_stop1.ogg', 'aquila/sound/cassettes/machine_stop2.ogg', 'aquila/sound/cassettes/machine_stop3.ogg'))

/obj/item/cassette_tape
	name = "czysta kaseta"
	desc = "Pusta kaseta magnetofonowa, czeka na muzykę."
	icon = 'aquila/icons/obj/cassettes/walkman.dmi'
	icon_state = "cassette_flip"
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NOBLUDGEON
	drop_sound = 'aquila/sound/cassettes/tape_asmr1.ogg'
	pickup_sound = 'aquila/sound/cassettes/tape_asmr2.ogg'
	/// Odwrócona = gra tylna strona
	var/flipped = FALSE
	var/datum/cassette/cassette_data
	/// Losowa zatwierdzona kaseta
	var/random = FALSE
	/// ID zatwierdzonej kasety do skopiowania przy tworzeniu
	var/id

/obj/item/cassette_tape/Initialize(mapload, spawned_id)
	. = ..()
	if(spawned_id)
		id = spawned_id
	var/datum/cassette/source
	if(id)
		source = SScassettes.load_cassette(id)
	else if(random)
		var/list/picked = SScassettes.unique_random_cassettes(1)
		if(length(picked))
			source = picked[1]
	cassette_data = source ? source.copy() : new /datum/cassette
	update_cassette_appearance()

/obj/item/cassette_tape/Destroy(force)
	QDEL_NULL(cassette_data)
	return ..()

/obj/item/cassette_tape/proc/update_cassette_appearance()
	name = cassette_data.name || initial(name)
	desc = cassette_data.desc || initial(desc)
	icon_state = get_current_side()?.design || initial(icon_state)

/obj/item/cassette_tape/attack_self(mob/user)
	. = ..()
	flipped = !flipped
	balloon_alert(user, "odwrócono kasetę")
	playsound(src, pick(GLOB.cassette_asmr_sounds), 50, FALSE)
	update_cassette_appearance()

/obj/item/cassette_tape/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Strona [flipped ? "B" : "A"]: [length(get_current_side()?.songs)] z [MAX_SONGS_PER_CASSETTE_SIDE] utworów. Użyj w dłoni, żeby odwrócić.</span>"
	switch(cassette_data.status)
		if(CASSETTE_STATUS_UNAPPROVED)
			. += "<span class='warning'>To nieoficjalne nagranie, jakość nie jest gwarantowana.</span>"
			. += "<span class='notice'>Żeby trafiła do biblioteki kaset, wrzuć ją do skrzynki Kosmicznej Rady Muzycznej.</span>"
		if(CASSETTE_STATUS_REVIEWING)
			. += "<span class='warning'>Kosmiczna Rada Muzyczna wciąż ją ocenia.</span>"
		if(CASSETTE_STATUS_APPROVED)
			. += "<span class='info'>Zatwierdzona przez Kosmiczną Radę Muzyczną.</span>"
		if(CASSETTE_STATUS_DENIED)
			. += "<span class='warning'>Kosmiczna Rada Muzyczna ją odrzuciła. Może coś zmienić i zgłosić ponownie?</span>"
	if(cassette_data.author.name)
		. += "<span class='info'>Zmiksowane przez: <b>[cassette_data.author.name]</b></span>"

/obj/item/cassette_tape/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I, /obj/item/pen))
		return ..()
	if(cassette_data.status == CASSETTE_STATUS_APPROVED || cassette_data.status == CASSETTE_STATUS_REVIEWING)
		to_chat(user, "<span class='warning'>Opis tej kasety jest już oficjalny, nie da się go zmienić.</span>")
		return TRUE
	var/choice = tgui_input_list(user, "Co chcesz zmienić?", "Kaseta", list("Nazwa", "Opis"))
	if(!choice || !user.canUseTopic(src, BE_CLOSE))
		return TRUE
	if(choice == "Nazwa")
		var/new_name = reject_bad_text(tgui_input_text(user, "Nowa nazwa kasety:", "Kaseta", cassette_data.name, MAX_NAME_LEN), MAX_NAME_LEN, ascii_only = FALSE)
		if(!new_name || !user.canUseTopic(src, BE_CLOSE))
			return TRUE
		cassette_data.name = new_name
	else
		var/new_desc = tgui_input_text(user, "Nowy opis kasety:", "Kaseta", cassette_data.desc, 180)
		if(!new_desc || !user.canUseTopic(src, BE_CLOSE))
			return TRUE
		cassette_data.desc = new_desc
	update_cassette_appearance()
	return TRUE

/obj/item/cassette_tape/proc/get_current_side()
	RETURN_TYPE(/datum/cassette_side)
	return cassette_data?.get_side(!flipped)

/obj/item/cassette_tape/blank

/obj/item/cassette_tape/friday
	id = "friday"

/obj/item/cassette_tape/random
	random = TRUE
