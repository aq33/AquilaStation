// Dzwonek na ladę (tg desk_bell) i dzwonki działów z Monkestation (code/modules/paperwork/department_bell.dm).
// Różnice: bez przyczepiania do wózka inwalidzkiego, a miejsce w komunikacie to domyślnie nazwa obszaru.

/obj/structure/desk_bell
	name = "dzwonek na ladę"
	desc = "Podstawa każdej pracy z klientem. Czujesz nieodpartą chęć, żeby w niego zadzwonić."
	icon = 'aquila/icons/obj/monke/desk_bell.dmi'
	icon_state = "desk_bell"
	layer = OBJ_LAYER
	anchored = FALSE
	pass_flags = PASSTABLE
	max_integrity = 5000
	/// Ile razy już dzwoniono, od tego zależy szansa na urwanie serca dzwonka
	var/times_rang = 0
	/// Czy serce dzwonka jest urwane
	var/broken_ringer = FALSE
	COOLDOWN_DECLARE(ring_cooldown)
	/// Odstęp między dzwonieniami, 0 wyłącza ograniczenie
	var/ring_cooldown_length = 0.3 SECONDS
	var/ring_sound = 'sound/machines/microwave/microwave-end.ogg'

/obj/structure/desk_bell/add_context_self(datum/screentip_context/context, mob/user)
	context.add_left_click_tool_action("[anchored ? "Odkręć" : "Przykręć"]", TOOL_WRENCH)
	if(broken_ringer)
		context.add_left_click_tool_action("Napraw", TOOL_SCREWDRIVER)
	else
		context.add_attack_hand_action(prob(1) ? "Zirytuj" : "Zadzwoń")

/obj/structure/desk_bell/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!COOLDOWN_FINISHED(src, ring_cooldown) && ring_cooldown_length)
		return TRUE
	if(!ring_bell(user))
		to_chat(user, "<span class='notice'>[src] milczy. Jakiś idiota go zepsuł.</span>")
	if(ring_cooldown_length)
		COOLDOWN_START(src, ring_cooldown, ring_cooldown_length)
	return TRUE

/obj/structure/desk_bell/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/desk_bell/attackby(obj/item/weapon, mob/living/user, params)
	. = ..()
	times_rang += weapon.force
	ring_bell(user)

/obj/structure/desk_bell/screwdriver_act(mob/living/user, obj/item/tool)
	if(!broken_ringer)
		return ..()
	balloon_alert(user, "naprawiam...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 5 SECONDS))
		balloon_alert_to_viewers("naprawiony")
		playsound(user, 'sound/items/change_drill.ogg', 50, TRUE)
		broken_ringer = FALSE
		times_rang = 0
	return TRUE

/obj/structure/desk_bell/wrench_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "[anchored ? "odkręcam" : "przykręcam"]...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 10 SECONDS))
		balloon_alert(user, "[anchored ? "odkręcony" : "przykręcony"]")
		setAnchored(!anchored)
		tool.play_tool_sound(src)
	return TRUE

/obj/structure/desk_bell/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(drop_location(), broken_ringer ? 1 : 2)
	qdel(src)

/// Sprawdza, czy serce dzwonka się urwało
/obj/structure/desk_bell/proc/check_clapper(mob/living/user)
	if(((times_rang >= 10000) || prob(times_rang / 100)) && ring_cooldown_length)
		to_chat(user, "<span class='notice'>Słyszysz, jak serce [src] spada z zawiasu. Brawo, zepsułeś go.</span>")
		broken_ringer = TRUE

/obj/structure/desk_bell/proc/ring_bell(mob/living/user)
	if(broken_ringer)
		return FALSE
	check_clapper(user)
	playsound(src, ring_sound, 70, broken_ringer, SHORT_RANGE_SOUND_EXTRARANGE)
	flick("desk_bell_ring", src)
	times_rang++
	return TRUE

/obj/structure/desk_bell/speed_demon
	desc = "Podstawa każdej pracy z klientem. Ten został podrasowany pod maksymalną wydajność."
	ring_cooldown_length = 0

/datum/crafting_recipe/desk_bell
	name = "Dzwonek na ladę"
	result = /obj/structure/desk_bell
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/iron = 2)
	tools = list(TOOL_SCREWDRIVER)
	category = CAT_MISC

// =====================================================
// Dzwonki działów
// =====================================================

/obj/structure/desk_bell/departmental
	name = "dzwonek działu"
	desc = "Podstawa każdej pracy z klientem. Dzwonienie wysyła wezwanie na kanał radiowy działu."
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// Odstęp między wezwaniami przez radio
	var/announce_cooldown_length = 60 SECONDS
	COOLDOWN_DECLARE(announce_cooldown)
	/// Wewnętrzne radio do wezwań
	var/obj/item/radio/radio
	var/radio_channel = FREQ_COMMON
	/// Miejsce podawane w wezwaniu; puste = nazwa obszaru, w którym dzwonek zaczął rundę
	var/bell_location
	/// Czy włączyła się ochrona przed kradzieżą
	var/antitheft = FALSE
	var/area/starting_location

/obj/structure/desk_bell/departmental/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.canhear_range = 0
	radio.listening = FALSE
	radio.set_frequency(radio_channel)
	radio.freerange = TRUE
	radio.freqlock = TRUE
	radio.command = TRUE
	radio.use_command = TRUE
	starting_location = get_area(src)
	if(!bell_location)
		bell_location = get_area_name(src, TRUE)

/obj/structure/desk_bell/departmental/Destroy()
	QDEL_NULL(radio)
	starting_location = null
	return ..()

/obj/structure/desk_bell/departmental/add_context_self(datum/screentip_context/context, mob/user)
	if(broken_ringer)
		context.add_left_click_tool_action("Napraw", TOOL_SCREWDRIVER)
	else
		context.add_attack_hand_action("Wezwij dział")

// Dzwonka działu nie da się odkręcić ani rozebrać
/obj/structure/desk_bell/departmental/wrench_act(mob/living/user, obj/item/tool)
	return FALSE

/obj/structure/desk_bell/departmental/check_clapper(mob/living/user)
	return

/obj/structure/desk_bell/departmental/ring_bell(mob/living/user)
	. = ..()
	if(!. || !announce_cooldown_length || !COOLDOWN_FINISHED(src, announce_cooldown))
		return
	COOLDOWN_START(src, announce_cooldown, announce_cooldown_length)
	balloon_alert(user, "dział wezwany")
	var/message = "Proszę o pomoc: [bell_location]."
	if(!antitheft && get_area(src) != starting_location)
		antitheft = TRUE
		visible_message("<span class='warning'>[src] zaczyna migać na czerwono i wyć alarmem!</span>")
		message += " Ochrona przed kradzieżą aktywna, nadajnik GPS włączony."
		AddComponent(/datum/component/gps, "DBELL-[radio_channel]")
		add_atom_colour("#ff4040", FIXED_COLOUR_PRIORITY)
	radio.talk_into(src, message, radio_channel)

/obj/structure/desk_bell/departmental/security
	name = "dzwonek ochrony"
	radio_channel = FREQ_SECURITY

/obj/structure/desk_bell/departmental/engineering
	name = "dzwonek inżynierii"
	radio_channel = FREQ_ENGINEERING

/obj/structure/desk_bell/departmental/command
	name = "dzwonek dowództwa"
	radio_channel = FREQ_COMMAND

/obj/structure/desk_bell/departmental/command/hop
	name = "dzwonek biura personelu"
	bell_location = "biuro Szefa Personelu"

/obj/structure/desk_bell/departmental/science
	name = "dzwonek działu naukowego"
	radio_channel = FREQ_SCIENCE

/obj/structure/desk_bell/departmental/medical
	name = "dzwonek medyczny"
	radio_channel = FREQ_MEDICAL

/obj/structure/desk_bell/departmental/supply
	name = "dzwonek zaopatrzenia"
	radio_channel = FREQ_SUPPLY

/obj/structure/desk_bell/departmental/service
	name = "dzwonek obsługi"
	radio_channel = FREQ_SERVICE

/obj/structure/desk_bell/departmental/munitions
	name = "dzwonek amunicji"
	radio_channel = FREQ_MUNITIONS

/obj/structure/desk_bell/departmental/syndicate
	name = "dzwonek Syndykatu"
	radio_channel = FREQ_SYNDICATE
