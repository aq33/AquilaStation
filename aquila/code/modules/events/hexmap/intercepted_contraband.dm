// AQUILA - Przechwycona przemytnicza paczka: celnicy kierują do ładowni przechwyconą paczkę z drobną kontrabandą i zaszyfrowaną notką o skrytce w tunelach technicznych; w skrytce kasetka z gotówką i notesem przemytnika, który ochrona rejestruje jako dowód (port z BlueMoon-Labs/BlueMoon-Station modular_bluemoon/code/modules/events/minor_incidents/intercepted_contraband.dm)
// BlueMoon delivers the parcel to cargo, puts a forged blank ID in it, leaves the accomplice's fingerprints on every
// piece, radios security and seizes the stash cash from whoever registers the ledger (with change on a holochip).
// Ours lands the parcel in a supply pod without explosion in the cargo bay (any safe room when it has no free floor)
// and keeps the rest simple: no forged ID and no fingerprints, the note is in a Polish Caesar cipher (shift 3) that
// a pen decodes, the stash is a loose floor tile in maintenance opened with a crowbar, the strongbox opens with
// security access or a crowbar, and registering the ledger at a security records console with armory access pays
// the security budget once. The loot is small: a few cigarettes, a bottle, a poster and 250 credits, no guns or emag.

#define AQUILA_CONTRABAND_LEDGER_REWARD 300
#define AQUILA_CONTRABAND_CIPHER_SHIFT 3

/datum/round_event_control/aquila_hex_intercepted_contraband
	name = "Przechwycona przemytnicza paczka"
	typepath = /datum/round_event/aquila_hex_intercepted_contraband
	weight = 10
	min_players = 5
	max_occurrences = 1
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_intercepted_contraband
	fakeable = FALSE
	startWhen = 1
	announceWhen = 2
	/// Fałszywe nazwisko adresata
	var/smuggler_name
	/// Pomieszczenie, do którego leci paczka
	var/parcel_area_name

/datum/round_event/aquila_hex_intercepted_contraband/start()
	var/turf/drop_spot = cargo_bay_turf()
	var/turf/hideout = aquila_hex_maint_turf()
	if(!drop_spot || !hideout)
		log_game("Intercepted Contraband: no free cargo floor or maintenance turf, cancelling the event.")
		return kill()
	smuggler_name = aquila_hex_smuggler_name()
	new /obj/structure/aquila_smuggler_stash(hideout, smuggler_name)
	var/obj/structure/closet/supplypod/pod = new(null, STYLE_STANDARD)
	pod.explosionSize = list(0, 0, 0, 0)
	new /obj/item/aquila_smuggler_parcel(pod, smuggler_name, aquila_hex_hideout_hint(hideout))
	var/obj/effect/pod_landingzone/marker = new(drop_spot, pod)
	parcel_area_name = get_area_name(drop_spot, TRUE)
	announce_to_ghosts(marker)
	log_game("Intercepted Contraband: parcel for [smuggler_name] landing at [AREACOORD(drop_spot)], stash at [AREACOORD(hideout)].")

/datum/round_event/aquila_hex_intercepted_contraband/announce(fake)
	if(!parcel_area_name)
		return
	priority_announce("Posterunek celny Nanotrasen przy polu minowym przechwycił paczkę zaadresowaną do byłego członka waszej załogi, [smuggler_name], zwolnionego trzy zmiany temu. Paczka leci do: [parcel_area_name] do kontroli. Notatki o przemycie prosimy przekazać naczelnikowi więzienia albo szefowi ochrony; za notes przemytnika budżet ochrony dostanie [AQUILA_CONTRABAND_LEDGER_REWARD] kredytów.", "Służba Celna Nanotrasen")

/// Wolne bezpieczne pole w ładowni, a gdy jej nie ma, w dowolnym bezpiecznym pomieszczeniu
/datum/round_event/aquila_hex_intercepted_contraband/proc/cargo_bay_turf()
	for(var/area_type in list(/area/quartermaster/storage, /area/quartermaster/warehouse, /area/quartermaster))
		var/area/cargo = GLOB.areas_by_type[area_type]
		if(!cargo)
			continue
		var/list/turfs = list()
		for(var/turf/T in cargo)
			if(aquila_hex_free_safe_turf(T))
				turfs += T
		if(length(turfs))
			return pick(turfs)
	var/list/room = aquila_hex_room_turfs(1)
	return length(room) ? room[1] : null

/// Wymyślone imię i nazwisko, którego nie nosi nikt z załogi
/proc/aquila_hex_smuggler_name()
	var/list/taken = list()
	for(var/mob/living/carbon/human/crew in GLOB.carbon_list)
		if(crew.real_name)
			taken[crew.real_name] = TRUE
	for(var/attempt in 1 to 10)
		var/candidate = "[pick(GLOB.first_names_male)] [pick(GLOB.last_names_male)]"
		if(!taken[candidate])
			return candidate
	return "Zdzisław Przemytnik"

/// Opis skrytki do notki: pomieszczenie i strona okrętu
/proc/aquila_hex_hideout_hint(turf/hideout)
	var/area/A = get_area(hideout)
	return "[A ? A.name : "tunele techniczne"], pod obluzowaną płytką podłogi"

/// Szyfr Cezara: litery polskiego alfabetu (małe i wielkie osobno) przesunięte o shift
/proc/aquila_hex_caesar(text, shift)
	var/static/list/alphabets = list(
		"aąbcćdeęfghijklłmnńoóprsśtuwyzźż",
		"AĄBCĆDEĘFGHIJKLŁMNŃOÓPRSŚTUWYZŹŻ",
	)
	var/list/result = list()
	for(var/position in 1 to length_char(text))
		var/symbol = copytext_char(text, position, position + 1)
		for(var/alphabet in alphabets)
			var/index = findtextEx_char(alphabet, symbol)
			if(!index)
				continue
			var/size = length_char(alphabet)
			var/shifted = (((index - 1 + shift) % size) + size) % size + 1
			symbol = copytext_char(alphabet, shifted, shifted + 1)
			break
		result += symbol
	return jointext(result, "")

/// Przechwycona paczka: drobna kontrabanda i zaszyfrowana notka; otwiera się w ręce
/obj/item/aquila_smuggler_parcel
	name = "opieczętowana paczka"
	desc = "Gruby pakunek w szarym papierze, oklejony taśmą posterunku celnego Nanotrasen z pieczątką „PRZECHWYCONO”."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverypackage3"
	w_class = WEIGHT_CLASS_NORMAL
	/// Adresat
	var/recipient_name

/obj/item/aquila_smuggler_parcel/Initialize(mapload, recipient, hideout_hint)
	. = ..()
	recipient_name = recipient || "nieznany"
	name = "opieczętowana paczka ([recipient_name])"
	new /obj/item/storage/fancy/cigarettes/cigpack_syndicate(src)
	new /obj/item/reagent_containers/food/drinks/bottle/absinthe(src)
	new /obj/item/poster/random_contraband(src)
	var/obj/item/paper/aquila_smuggler_note/note = new(src)
	note.set_message("[recipient_name], towar przejęty, reszta niesprzedana. Skrytka: [hideout_hint || "tam, gdzie się umawialiśmy"]. Płytkę podważ łomem. Kasetki beze mnie nie otwieraj. G.")

/obj/item/aquila_smuggler_parcel/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Adresat: [recipient_name]. Taśmę można zerwać, używając paczki w ręce.</span>"

/obj/item/aquila_smuggler_parcel/attack_self(mob/user)
	unwrap(user)

/// Zrywa taśmę i wysypuje zawartość
/obj/item/aquila_smuggler_parcel/proc/unwrap(mob/user)
	var/turf/spot = get_turf(src)
	if(!spot)
		return
	for(var/obj/item/content as anything in contents)
		content.forceMove(spot)
	playsound(spot, 'sound/items/poster_ripped.ogg', 50, TRUE)
	if(user)
		to_chat(user, "<span class='notice'>Zrywasz taśmę celną.</span>")
		log_game("Intercepted Contraband: [key_name(user)] opened the parcel for [recipient_name] at [AREACOORD(spot)].")
	qdel(src)

/// Zaszyfrowana notka przemytnika; pióro i chwila namysłu ją odszyfrowują
/obj/item/paper/aquila_smuggler_note
	name = "kartka z szyfrem"
	icon_state = "scrap"
	/// Odszyfrowana treść
	var/plain_text
	var/decoded = FALSE

/// Zapisuje na kartce zaszyfrowaną treść
/obj/item/paper/aquila_smuggler_note/proc/set_message(text)
	plain_text = text
	decoded = FALSE
	clear_paper()
	add_raw_text(aquila_hex_caesar(plain_text, AQUILA_CONTRABAND_CIPHER_SHIFT))
	update_appearance()

/obj/item/paper/aquila_smuggler_note/examine(mob/user)
	. = ..()
	if(!decoded)
		. += "<span class='notice'>Litery są poprzesuwane prostym szyfrem. Z piórem w ręce i chwilą namysłu da się go złamać.</span>"

/obj/item/paper/aquila_smuggler_note/attackby(obj/item/attacking_item, mob/living/user, params)
	if(decoded || !plain_text || !istype(attacking_item, /obj/item/pen))
		return ..()
	to_chat(user, "<span class='notice'>Wypisujesz litery w słupku i szukasz przesunięcia...</span>")
	if(do_after(user, 4 SECONDS, src))
		decode(user)
	return TRUE

/// Zamienia szyfr na jawny tekst
/obj/item/paper/aquila_smuggler_note/proc/decode(mob/user)
	if(decoded || !plain_text)
		return FALSE
	decoded = TRUE
	SStgui.close_uis(src)
	clear_paper()
	add_raw_text(plain_text)
	name = "odszyfrowana kartka"
	update_appearance()
	if(user)
		to_chat(user, "<span class='notice'>Szyfr pęka: każda litera jest przesunięta o [AQUILA_CONTRABAND_CIPHER_SHIFT] dalej w alfabecie.</span>")
	return TRUE

/// Skrytka przemytnika w tunelach: obluzowana płytka podłogi, pod nią kasetka
/obj/structure/aquila_smuggler_stash
	name = "płytka podłogi"
	desc = "Zwykła płytka podłogi."
	icon = 'icons/obj/tiles.dmi'
	icon_state = "tile"
	anchored = TRUE
	density = FALSE
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	var/opened = FALSE

/obj/structure/aquila_smuggler_stash/Initialize(mapload, owner_name)
	. = ..()
	var/obj/item/storage/lockbox/aquila_smuggler/box = new(src)
	var/obj/item/aquila_smuggler_ledger/ledger = locate() in box
	ledger?.smuggler_name = owner_name

/obj/structure/aquila_smuggler_stash/Destroy()
	var/turf/spot = get_turf(src)
	for(var/atom/movable/content as anything in contents)
		if(spot)
			content.forceMove(spot)
		else
			qdel(content)
	return ..()

/obj/structure/aquila_smuggler_stash/examine(mob/user)
	. = ..()
	if(!opened && get_dist(user, src) <= 1)
		. += "<span class='notice'>Krawędź tej płytki jest lekko uniesiona, a fugi wokół świeżo wyczyszczone. Można ją podważyć łomem.</span>"

/obj/structure/aquila_smuggler_stash/crowbar_act(mob/living/user, obj/item/tool)
	if(opened)
		to_chat(user, "<span class='notice'>Wnęka pod płytką jest już pusta.</span>")
		return TRUE
	to_chat(user, "<span class='notice'>Podważasz krawędź płytki...</span>")
	if(tool.use_tool(src, user, 4 SECONDS, volume = 50))
		open_stash(user)
	return TRUE

/// Odsłania wnękę i wykłada kasetkę na podłogę
/obj/structure/aquila_smuggler_stash/proc/open_stash(mob/user)
	if(opened)
		return FALSE
	opened = TRUE
	name = "podważona płytka podłogi"
	desc = "Zdjęta płytka podłogi, pod nią ciasna wnęka."
	for(var/atom/movable/content as anything in contents)
		content.forceMove(loc)
	if(user)
		user.visible_message("<span class='notice'>[user] podważa płytkę podłogi: pod nią jest skrytka.</span>", "<span class='notice'>Płytka ustępuje. Pod nią jest ciasna wnęka z kasetką.</span>")
		log_game("Intercepted Contraband: [key_name(user)] opened the stash at [AREACOORD(src)].")
	return TRUE

/// Kasetka przemytnika: otwiera ją karta ochrony albo łom
/obj/item/storage/lockbox/aquila_smuggler
	name = "obita kasetka"
	desc = "Pogięta stalowa kasetka z zamkiem szyfrowym. Szyfru nikt nie zna, ale zamek jest słaby i ustąpi pod łomem. Karta z dostępem ochrony otwiera ją bez włamania."
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/aquila_smuggler/PopulateContents()
	new /obj/item/aquila_smuggler_ledger(src)
	new /obj/item/stack/spacecash/c200(src)
	new /obj/item/stack/spacecash/c50(src)

/obj/item/storage/lockbox/aquila_smuggler/crowbar_act(mob/living/user, obj/item/tool)
	if(broken || !SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED))
		return FALSE
	to_chat(user, "<span class='notice'>Wsuwasz łom pod wieczko kasetki...</span>")
	if(tool.use_tool(src, user, 6 SECONDS, volume = 50))
		force_open(user)
	return TRUE

/// Zrywa zamek
/obj/item/storage/lockbox/aquila_smuggler/proc/force_open(mob/user)
	if(broken)
		return FALSE
	broken = TRUE
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, FALSE)
	icon_state = "[base_icon_state]+b"
	item_state = "[base_icon_state]+b"
	desc = "Pogięta stalowa kasetka z wyrwanym zamkiem."
	if(user)
		user.visible_message("<span class='notice'>[user] wyrywa zamek kasetki.</span>", "<span class='notice'>Zamek ustępuje ze zgrzytem.</span>")
	return TRUE

/// Notes przemytnika: dowód, który ochrona rejestruje na konsoli akt ochrony
/obj/item/aquila_smuggler_ledger
	name = "notes przemytnika"
	desc = "Zatłuszczony notes: daty, kwoty, ksywki i numery śluz. Dla sądu to dowód. Naczelnik więzienia albo szef ochrony może go zarejestrować, przykładając go do konsoli akt ochrony."
	icon = 'icons/obj/library.dmi'
	icon_state = "book-3"
	w_class = WEIGHT_CLASS_SMALL
	var/smuggler_name
	var/registered = FALSE

/obj/item/aquila_smuggler_ledger/examine(mob/user)
	. = ..()
	if(registered)
		. += "<span class='notice'>Na okładce widnieje pieczątka ochrony: notes zarejestrowano jako dowód.</span>"
	else if(smuggler_name)
		. += "<span class='notice'>Ostatni wpis: „[smuggler_name]: reszta w skrytce, nie oddał. Kontakt: G.”</span>"

/obj/item/aquila_smuggler_ledger/pre_attack(atom/A, mob/living/user, params)
	if(istype(A, /obj/machinery/computer/secure_data))
		register_evidence(A, user)
		return FALSE
	return ..()

/// Rejestruje notes jako dowód: raz, na działającej konsoli, kartą z dostępem do zbrojowni
/obj/item/aquila_smuggler_ledger/proc/register_evidence(obj/machinery/computer/console, mob/living/user)
	if(registered)
		to_chat(user, "<span class='notice'>Notes jest już zarejestrowany jako dowód.</span>")
		return FALSE
	if(console.machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='warning'>Konsola nie odpowiada.</span>")
		return FALSE
	var/obj/item/card/id/card = user.get_idcard(TRUE)
	if(!card || !(ACCESS_ARMORY in card.GetAccess()))
		playsound(console, 'sound/machines/terminal_prompt_deny.ogg', 30, FALSE)
		to_chat(user, "<span class='warning'>Dowód rejestruje naczelnik więzienia albo szef ochrony: potrzebna karta z dostępem do zbrojowni.</span>")
		return FALSE
	registered = TRUE
	var/datum/bank_account/budget = SSeconomy.get_dep_account(ACCOUNT_SEC)
	budget?.adjust_money(AQUILA_CONTRABAND_LEDGER_REWARD)
	playsound(console, 'sound/machines/terminal_success.ogg', 40, FALSE)
	console.say("Notes przemytnika zarejestrowany jako dowód. Budżet ochrony otrzymał [AQUILA_CONTRABAND_LEDGER_REWARD] kredytów.")
	var/obj/item/paper/receipt = new(console.drop_location())
	receipt.name = "protokół przyjęcia dowodu"
	receipt.add_raw_text("<center><b>OCHRONA OKRĘTU</b><br>Protokół przyjęcia dowodu</center><br>Notes przemytnika [smuggler_name || "bez nazwiska"] zarejestrowano jako dowód. Przyjął: [user.real_name].<br>Budżet ochrony otrzymał [AQUILA_CONTRABAND_LEDGER_REWARD] kredytów.")
	receipt.update_appearance()
	log_game("Intercepted Contraband: [key_name(user)] registered the ledger at [AREACOORD(console)].")
	return TRUE

#undef AQUILA_CONTRABAND_LEDGER_REWARD
#undef AQUILA_CONTRABAND_CIPHER_SHIFT
