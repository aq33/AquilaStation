 //Suits for the pink and grey skeletons! //EVA version no longer used in favor of the Jumpsuit version


/obj/item/clothing/suit/space/eva/plasmaman
	name = "plazmowy kombinezon środowiskowy EVA"
	desc = "Specjalny kombinezon izolujący plazmę, który nadaje się do kosmosu i można go nosić na innym ubraniu. Tak jak mniejszy odpowiednik, w razie kryzysu automatycznie gasi noszącego, ale mieści dwa razy więcej ładunków."
	allowed = list(/obj/item/gun, /obj/item/ammo_casing, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/transforming/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75, "stamina" = 0, "bleed" = 10)
	resistance_flags = FIRE_PROOF
	icon_state = "plasmaman_suit"
	item_state = "plasmaman_suit"
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 10


/obj/item/clothing/suit/space/eva/plasmaman/examine(mob/user)
	. = ..()
	. += "<span class='notice'>W tym kombinezonie pozostało ładunków gaśnicy: [extinguishes_left].</span>"


/obj/item/clothing/suit/space/eva/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.fire_stacks)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message("<span class='warning'>Kombinezon [H] automatycznie go gasi!</span>","<span class='warning'>Twój kombinezon automatycznie cię gasi.</span>")
			H.ExtinguishMob()
			new /obj/effect/particle_effect/water(get_turf(H))


//I just want the light feature of the hardsuit helmet
/obj/item/clothing/head/helmet/space/plasmaman
	name = "plazmowy hełm środowiskowy"
	desc = "Specjalny hełm izolujący, dzięki któremu plazmowe formy życia mogą bezpiecznie przebywać w środowisku z tlenem. Nadaje się do kosmosu i można go nosić razem z innym sprzętem EVA."
	icon_state = "helmet"
	item_state = "helmet"
	greyscale_colors = "#DF5900#A349A4#DF5900"
	greyscale_config = /datum/greyscale_config/plasmaman_helmet_default
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_helmet_default_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_helmet_default_inhand_right
	greyscale_config_worn = /datum/greyscale_config/plasmaman_helmet_default_worn
	strip_delay = 80
	flash_protect = 2
	tint = 2
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75, "stamina" = 0, "bleed" = 10)
	resistance_flags = FIRE_PROOF
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 4
	light_on = FALSE
	var/helmet_on = FALSE
	var/smile = FALSE
	var/smile_color = "#FF0000"
	var/smile_state = "envirohelm_smile"
	var/visor_state = "enviro_visor"
	var/lamp_functional = TRUE
	var/obj/item/clothing/head/attached_hat
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_welding_screen/plasmaman)
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES
	visor_flags_inv = HIDEEYES|HIDEFACE|HIDEFACIALHAIR

/obj/item/clothing/head/helmet/space/plasmaman/Initialize(mapload)
	. = ..()
	visor_toggling()
	remove_verb(/obj/item/clothing/head/helmet/space/plasmaman/verb/unattach_hat)

/obj/item/clothing/head/helmet/space/plasmaman/Destroy()
	if (attached_hat)
		if (attached_hat.resistance_flags & INDESTRUCTIBLE)
			attached_hat.forceMove(get_turf(src))
		else
			QDEL_NULL(attached_hat)
	..()

/obj/item/clothing/head/helmet/space/plasmaman/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE))
		toggle_welding_screen(user)

/obj/item/clothing/head/helmet/space/plasmaman/examine(mob/user)
	. = ..()
	if(attached_hat)
		. += "<span class='notice'>Na hełmie jest [attached_hat.name], który można zdjąć z menu kontekstowego.</span>"
	else
		. += "<span class='notice'>Na hełmie można umieścić kapelusz.</span>"

/obj/item/clothing/head/helmet/space/plasmaman/proc/toggle_welding_screen(mob/living/user)
	if(!weldingvisortoggle(user))
		return
	if(helmet_on)
		to_chat(user, "<span class='notice'>Latarka twojego hełmu nie przebije się przez przyłbicę spawalniczą!</span>")
		helmet_on = FALSE
	playsound(src, 'sound/mecha/mechmove03.ogg', 50, 1) //Visors don't just come from nothing
	update_icon()
	update_button_icons(user)

/obj/item/clothing/head/helmet/space/plasmaman/update_icon()
	update_overlays()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_head()

/obj/item/clothing/head/helmet/space/plasmaman/attackby(obj/item/item, mob/living/user)
	. = ..()
	if(istype(item, /obj/item/light/bulb) && !lamp_functional)
		lamp_functional = TRUE
		qdel(item)
		to_chat(user, "<span class='notice'>Naprawiasz zepsutą latarkę czołową!</span>")
	if(istype(item, /obj/item/toy/crayon))
		if(smile)
			to_chat(user, "<span class='notice'>Wygląda na to, że ktoś już coś narysował na przyłbicy hełmu.</span>")
		else
			var/obj/item/toy/crayon/CR = item
			to_chat(user, "<span class='notice'>Zaczynasz rysować uśmiechniętą buźkę na przyłbicy hełmu..</span>")
			if(do_after(user, 25, target = src))
				smile = TRUE
				smile_color = CR.paint_color
				to_chat(user, "Rysujesz uśmiech na przyłbicy hełmu.")
				update_icon()
				update_button_icons(user)
		return
	if(istype(item, /obj/item/clothing/head) \
		// i know someone is gonna do it after i thought about it
		&& !istype(item, /obj/item/clothing/head/helmet/space/plasmaman) \
		// messy and icon can't be seen before putting on
		&& !istype(item, /obj/item/clothing/head/foilhat))
		var/obj/item/clothing/head/hat = item
		if(attached_hat)
			to_chat(user, "<span class='notice'>Na hełmie jest już kapelusz!</span>")
			return
		attached_hat = hat
		hat.forceMove(src)
		if (user.get_item_by_slot(ITEM_SLOT_HEAD) == src)
			hat.equipped(user, ITEM_SLOT_HEAD)
		update_icon()
		update_button_icons(user)
		add_verb(/obj/item/clothing/head/helmet/space/plasmaman/verb/unattach_hat)

/obj/item/clothing/head/helmet/space/plasmaman/equipped(mob/user, slot)
	. = ..()
	attached_hat?.equipped(user, slot)

/obj/item/clothing/head/helmet/space/plasmaman/dropped(mob/user)
	. = ..()
	attached_hat?.dropped(user)

/obj/item/clothing/head/helmet/space/plasmaman/proc/update_button_icons(mob/user)
	if(!user)
		return

	//The icon's may look differently due to overlays being applied asynchronously
	for(var/X in actions)
		var/datum/action/A=X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/plasmaman/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	if(!isinhands)
		if(smile)
			var/mutable_appearance/M = mutable_appearance('icons/mob/clothing/head.dmi', smile_state)
			M.color = smile_color
			. += M
		if(helmet_on)
			. += mutable_appearance('icons/mob/clothing/head.dmi', visor_state + "_light")
		if(!up)
			. += mutable_appearance('icons/mob/clothing/head.dmi', visor_state + "_weld")
		if(attached_hat)
			. += attached_hat.build_worn_icon(attached_hat.icon_state, default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head.dmi')

/obj/item/clothing/head/helmet/space/plasmaman/verb/unattach_hat()
	set name = "Remove Hat"
	set category = "Object"
	set src in usr

	usr.put_in_hands(attached_hat)
	if (usr.get_item_by_slot(ITEM_SLOT_HEAD) == src)
		attached_hat.dropped(usr)
	attached_hat = null
	update_icon()
	remove_verb(/obj/item/clothing/head/helmet/space/plasmaman/verb/unattach_hat)

/obj/item/clothing/head/helmet/space/plasmaman/ComponentInitialize()
	. = ..()
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(wipe_that_smile_off_your_face))

///gets called when receiving the CLEAN_ACT signal from something, i.e soap or a shower. exists to remove any smiley faces drawn on the helmet.
/obj/item/clothing/head/helmet/space/plasmaman/proc/wipe_that_smile_off_your_face()
	SIGNAL_HANDLER

	if(smile)
		smile = FALSE
		cut_overlays()
		update_icon()

/obj/item/clothing/head/helmet/space/plasmaman/attack_self(mob/user)
	helmet_on = !helmet_on
	if(!lamp_functional)
		to_chat(user, "<span class='notice'>Latarka twojego hełmu jest zepsuta! Musisz ją naprawić żarówką!</span>")
		set_light_on(FALSE)
		helmet_on = FALSE
		return
	if(helmet_on)
		if(!up)
			to_chat(user, "<span class='notice'>Latarka twojego hełmu nie przebije się przez przyłbicę spawalniczą!</span>")
			helmet_on = FALSE
			return
		else
			set_light_on(TRUE)
	else
		set_light_on(FALSE)

	update_icon()
	user.update_inv_head() //So the mob overlay updates
	update_button_icons(user)

/obj/item/clothing/head/helmet/space/plasmaman/proc/smash_headlamp()
	if(!lamp_functional)
		return
	if(!helmet_on)
		return
	set_light_on(FALSE)
	helmet_on = FALSE
	playsound(src, 'sound/effects/glass_step.ogg', 100)
	to_chat(usr, "<span class='danger'>Latarka czołowa [src] jest roztrzaskana na kawałki!</span>")
	lamp_functional = FALSE
	update_icon()
	usr.update_inv_head() //So the mob overlay updates
	update_button_icons(usr)

/obj/item/clothing/head/helmet/space/plasmaman/update_overlays()
	cut_overlays()

	if(!up)
		add_overlay(mutable_appearance('icons/obj/clothing/hats.dmi', visor_state + "_weld"))
	else if(helmet_on)
		add_overlay(mutable_appearance('icons/obj/clothing/hats.dmi', visor_state + "_light"))

	return ..()

/obj/item/clothing/head/helmet/space/plasmaman/security
	name = "policyjny hełm środowiskowy"
	desc = "Hełm izolujący plazmamana zaprojektowany dla policjantów. Chroni ich przed spłonięciem żywcem i innymi nieprzyjemnościami."
	greyscale_colors = "#9F2A2E#2D2D2D#7D282D"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75, "stamina" = 10, "bleed" = 10)

/obj/item/clothing/head/helmet/space/plasmaman/security/warden
	name = "hełm środowiskowy Naczelnika"
	desc = "Hełm izolujący plazmamana zaprojektowany dla Naczelnika. Para białych pasków odróżnia go od reszty ochrony."
	greyscale_colors = "#9F2A2E#C0C0C0#7D282D"

/obj/item/clothing/head/helmet/space/plasmaman/medical
	name = "medyczny hełm środowiskowy"
	desc = "Hełm środowiskowy zaprojektowany dla plazmamanów lekarzy. Na znak tego ma przez całą długość dwa paski"
	greyscale_colors = "#D2D2D2#498CB4#2D2D2D"

/obj/item/clothing/head/helmet/space/plasmaman/genetics
	name = "hełm środowiskowy genetyka"
	desc = "Hełm środowiskowy plazmamana zaprojektowany dla genetyków."
	greyscale_colors = "#D2D2D2#0093C4#2D2D2D"

/obj/item/clothing/head/helmet/space/plasmaman/viro
	name = "hełm środowiskowy wirologii"
	desc = "Hełm najbezpieczniejszych ludzi na statku – tych, którzy są całkowicie odporni na potworności, które sami tworzą."
	greyscale_colors = "#D2D2D2#2D8800#2D2D2D"

/obj/item/clothing/head/helmet/space/plasmaman/chemist
	name = "hełm środowiskowy chemii"
	desc = "Hełm środowiskowy plazmamana zaprojektowany dla chemików, z dwoma pomarańczowymi paskami biegnącymi przez przód."
	greyscale_colors = "#D2D2D2#D26F00#2D2D2D"

/obj/item/clothing/head/helmet/space/plasmaman/paramedic
	name = "hełm środowiskowy ratownika medycznego"
	desc = "Hełm środowiskowy tylko dla najodważniejszego plazmamana z medycyny."
	greyscale_colors = "#2C3A4E#D9D9D9#2C3A4E"

/obj/item/clothing/head/helmet/space/plasmaman/security/secmed
	name = "hełm środowiskowy Lekarza Więziennego"
	desc = "Hełm środowiskowy zrobiony dla lekarzy więziennych."
	greyscale_colors = "#A5A9B6#B72B2F#A5A9B6"

/obj/item/clothing/head/helmet/space/plasmaman/science
	name = "hełm środowiskowy nauki"
	desc = "Hełm środowiskowy plazmamana zaprojektowany dla naukowców."
	greyscale_colors = "#E6E6E6#9E00EA#E6E6E6"

/obj/item/clothing/head/helmet/space/plasmaman/robotics
	name = "hełm środowiskowy robotyki"
	desc = "Hełm środowiskowy plazmamana zaprojektowany dla robotyków."
	greyscale_colors = "#313131#722BA4#313131"

/obj/item/clothing/head/helmet/space/plasmaman/engineering
	name = "inżynieryjny hełm środowiskowy"
	desc = "Nadający się do kosmosu hełm zaprojektowany specjalnie dla plazmamanów inżynierów. Zwykłe fioletowe paski zastąpiono inżynieryjnym pomarańczem."
	greyscale_colors = "#F0DE00#D75600#F0DE00"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 10, "fire" = 100, "acid" = 75, "stamina" = 0, "bleed" = 10)

/obj/item/clothing/head/helmet/space/plasmaman/engineering/atmospherics
	name = "hełm środowiskowy atmosferyki"
	desc = "Nadający się do kosmosu hełm zaprojektowany specjalnie dla plazmamanów techników atmosferyki. Zwykłe fioletowe paski zastąpiono inżynieryjnym błękitem."
	greyscale_colors = "#F0DE00#0098CA#F0DE00"

/obj/item/clothing/head/helmet/space/plasmaman/mailman
	name = "hełm środowiskowy listonosza"
	desc = "Nakrycie głowy plazmamanów z poczty <i>„Zawsze na czas”</i>."
	greyscale_colors = "#091544#e6c447#091544"

/obj/item/clothing/head/helmet/space/plasmaman/cargo
	name = "hełm środowiskowy zaopatrzenia"
	desc = "Hełm środowiskowy plazmamana zaprojektowany dla magazynierów i kwatermistrzów."
	greyscale_colors = "#ADADAD#BB9042#ADADAD"

/obj/item/clothing/head/helmet/space/plasmaman/mining
	name = "górniczy hełm środowiskowy"
	desc = "Hełm w kolorze khaki wydawany plazmamanom górnikom pracującym na Lavalandzie."
	greyscale_colors = "#55524A#8A5AE1#55524A"

/obj/item/clothing/head/helmet/space/plasmaman/chaplain
	name = "hełm środowiskowy kapłana"
	desc = "Hełm środowiskowy zaprojektowany specjalnie dla najpobożniejszych plazmamanów."
	greyscale_colors = "#313131#743474#313131"

/obj/item/clothing/head/helmet/space/plasmaman/white
	name = "biały hełm środowiskowy"
	desc = "Zwykły biały hełm środowiskowy."
	greyscale_colors = "#D2D2D2#743474#D2D2D2"

/obj/item/clothing/head/helmet/space/plasmaman/bartender
	name = "biały hełm środowiskowy z cylindrem"
	desc = "Zwykły biały hełm środowiskowy z cylindrem przymocowanym na czubku"
	greyscale_colors = "#E6E6E6#A349A4#E6E6E6"

/obj/item/clothing/head/helmet/space/plasmaman/bartender/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/head/hat = new /obj/item/clothing/head/that
	attached_hat = hat
	hat.forceMove(src)
	update_icon()
	add_verb(/obj/item/clothing/head/helmet/space/plasmaman/verb/unattach_hat)

/obj/item/clothing/head/helmet/space/plasmaman/gold
	name = "designerski hełm środowiskowy"
	desc = "Hełm środowiskowy Plasmi-Deluxe z wplecionym w tkaninę złotem. Taki designerski model jest pewnie wart sporo kasy."
	greyscale_colors = "#C47D0C#C47D0C#C47D0C"

/obj/item/clothing/head/helmet/space/plasmaman/curator
	name = "hełm środowiskowy bibliotekarza"
	desc = "Lekko zmodyfikowany tradycyjny hełm próżniowy. To pierwsze rozwiązanie Nano-Trasen *problemów logistycznych* związanych z zatrudnianiem plazmamanów. Mimo ograniczeń wciąż noszą je historycy i plazmamani starej daty."
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	icon_state = "prototype_envirohelm"
	item_state = "prototype_envirohelm"
	smile_state = "prototype_smile"

/obj/item/clothing/head/helmet/space/plasmaman/botany
	name = "hełm środowiskowy botaniki"
	desc = "Zielono-niebieski hełm środowiskowy, który oznacza noszącego jako botanika. Choć nie zaprojektowano go do tego specjalnie, chroni przed drobnymi obrażeniami od roślin."
	greyscale_colors = "#5FA31E#0D49FF#5FA31E"

/obj/item/clothing/head/helmet/space/plasmaman/janitor
	name = "hełm środowiskowy woźnego"
	desc = "Szary hełm z parą fioletowych pasków, które oznaczają noszącego jako woźnego."
	greyscale_colors = "#ADADAD#7E3391#FCFF00"

/obj/item/clothing/head/helmet/space/plasmaman/exploration
	name = "hełm środowiskowy odkrywcy"
	desc = "Hełm środowiskowy plazmamana zaprojektowany dla odkrywców, w ich charakterystycznym jaskrawym turkusie."
	greyscale_colors = "#CFC7B8#50BA5C#CFC7B8"

//mime and clown
/obj/item/clothing/head/helmet/space/plasmaman/mime
	name = "hełm środowiskowy mima"
	desc = "Czarno-biały hełm środowiskowy zrobiony specjalnie dla mima. Grzechoczące kości nie przeszkodzą w twoich cichych wybrykach!"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	icon_state = "mime_envirohelm"
	item_state = "mime_envirohelm"
	visor_state = "mime_visor"

/obj/item/clothing/head/helmet/space/plasmaman/honk
	name = "hełm środowiskowy klauna"
	desc = "Wielobarwny hełm, który pachnie bananium i łzami ochrony."
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	icon_state = "honk_envirohelm"
	item_state = "honk_envirohelm"
	smile_state = "clown_smile"
	visor_state = "clown_visor"

//command helms
/obj/item/clothing/head/helmet/space/plasmaman/command
	name = "hełm środowiskowy kapitana"
	desc = "Hełm wydawany szefowi dowództwa. Elegancki i stylowy, jak każdy kapitan powinien być."
	greyscale_colors = "#005478#D7C73F#005478"

/obj/item/clothing/head/helmet/space/plasmaman/engineering/ce
	name = "hełm środowiskowy Głównego Inżyniera"
	desc = "Hełm środowiskowy zaprojektowany dla Głównego Inżyniera. Cuchnie Poly i plazmą."
	greyscale_colors = "#D7D7C4#D75600#D7D7C4"

/obj/item/clothing/head/helmet/space/plasmaman/cmo
	name = "hełm środowiskowy Ordynatora"
	desc = "Hełm wydawany szefowi personelu medycznego."
	greyscale_colors = "#6FABCE#E6E6E6#6FABCE"

/obj/item/clothing/head/helmet/space/plasmaman/security/hos
	name = "hełm środowiskowy Komendanta"
	desc = "Wzmocniony hełm środowiskowy wydawany szefowi ochrony. Przyda ci się."
	greyscale_colors = "#2F2E31#C7B83C#2F2E31"

/obj/item/clothing/head/helmet/space/plasmaman/rd
	name = "hełm środowiskowy Dyrektora Naukowego"
	desc = "Hełm środowiskowy wykonany na zamówienie z zaawansowanych nanowłókien. Modny i wygodny."
	greyscale_colors = "#6F5828#A349A4#6F5828"

/obj/item/clothing/head/helmet/space/plasmaman/hop
	name = "hełm środowiskowy Starszego Oficera"
	desc = "Hełm środowiskowy zrobiony dla Starszego Oficera. Przykleiło się do niego trochę sierści corgiego."
	greyscale_colors = "#005478#AA1916#005478"

//centcom envirohelms
/obj/item/clothing/head/helmet/space/plasmaman/commander
	name = "hełm środowiskowy Komandora Centrali"
	desc = "Specjalny hełm izolujący zaprojektowany dla wyższych rangą członków Centrali. Niewiele ich istnieje, bo Centrala z powodu komplikacji zwykle nie obsadza plazmamanami wyższych stanowisk."
	greyscale_colors = "#007F00#E1C709#007F00"

/obj/item/clothing/head/helmet/space/plasmaman/official
	name = "hełm środowiskowy przedstawiciela Centrali"
	desc = "Specjalny hełm izolujący zaprojektowany dla personelu Centrali. Oni naprawdę kochają ten swój zielony."
	greyscale_colors = "#099756#C0C0C0#099756"

/obj/item/clothing/head/helmet/space/plasmaman/intern
	name = "hełm środowiskowy stażysty Centrali"
	desc = "Specjalny hełm izolujący zaprojektowany dla personelu Centrali. No wiesz, żeby rozlana kawa nie zabiła biedaka."
	greyscale_colors = "#088756#313131#088756"

// The Mark 2 variants of the standard envirohelms.
/obj/item/clothing/head/helmet/space/plasmaman/mark2
	name = "hełm środowiskowy Mk.II"
	desc = "Elegancki nowy hełm izolujący plazmamana w klasycznym kolorze „ostrzegawczy pomarańcz”."
	greyscale_colors = "#DF5900#A349A4"
	greyscale_config = /datum/greyscale_config/plasmaman_helmet_mark2
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_helmet_mark2_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_helmet_mark2_inhand_right
	greyscale_config_worn = /datum/greyscale_config/plasmaman_helmet_mark2_worn
	visor_state = "mark2_visor"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/security
	name = "policyjny hełm środowiskowy Mk.II"
	desc = "Stylowa nowa wersja oryginalnego hełmu izolującego plazmamana dla policjantów. Zachowuje całą dawną ochronę na nową erę kruchych stróżów prawa."
	greyscale_colors = "#9F2A2E#2D2D2D"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75, "stamina" = 10, "bleed" = 10)

/obj/item/clothing/head/helmet/space/plasmaman/mark2/security/warden
	name = "hełm środowiskowy Naczelnika Mk.II"
	desc = "Stylowa nowa wersja oryginalnego hełmu izolującego plazmamana dla Naczelnika. Cały szyk standardowego wyglądu plus charakterystyczny odblaskowy biały pasek Naczelnika."
	greyscale_colors = "#9F2A2E#C0C0C0"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/medical
	name = "medyczny hełm środowiskowy Mk.II"
	desc = "Stylowa nowa wersja oryginalnego hełmu izolującego plazmamana dla lekarzy. Sklejaj kolegów z załogi i przy okazji pokaż, że masz styl."
	greyscale_colors = "#E6E6E6#5A96BB"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/genetics
	name = "hełm środowiskowy genetyka Mk.II"
	desc = "Stylowa nowa wersja oryginalnego hełmu izolującego plazmamana dla genetyków. Przesuwanie granic życia organicznego jeszcze nigdy nie wyglądało tak dobrze!"
	greyscale_colors = "#E6E6E6#0097CA"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/viro
	name = "hełm środowiskowy wirologii Mk.II"
	desc = "Hełm najbezpieczniejszych ludzi na statku – tych, którzy są całkowicie odporni na potworności, które sami tworzą, w tym na potworności przestarzałej mody"
	greyscale_colors = "#E6E6E6#339900"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/chemist
	name = "hełm środowiskowy chemii Mk.II"
	desc = "Wzmocniony hełm izolujący plazmamana zaprojektowany dla chemików."
	greyscale_colors = "#E6E6E6#FF8800"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/paramedic
	name = "hełm środowiskowy ratownika medycznego Mk.II"
	desc = "Nowy, ulepszony hełm środowiskowy tylko dla najodważniejszego plazmamana z medycyny."
	greyscale_colors = "#2C3A4E#D9D9D9"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/security/secmed
	name = "hełm środowiskowy Lekarza Więziennego Mk.II"
	desc = "Wzmocniony hełm izolujący plazmamana zaprojektowany dla lekarzy więziennych."
	greyscale_colors = "#A5A9B6#B72B2F"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/science
	name = "hełm środowiskowy nauki Mk.II"
	desc = "Stylowa nowa wersja oryginalnego hełmu izolującego plazmamana dla naukowców."
	greyscale_colors = "#E6E6E6#9E00EA"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/robotics
	name = "hełm środowiskowy robotyki Mk.II"
	desc = "Stylowa nowa wersja oryginalnego hełmu izolującego plazmamana dla robotyków."
	greyscale_colors = "#2F2E31#932500"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/engineering
	name = "inżynieryjny hełm środowiskowy Mk.II"
	desc = "Nowa wersja klasycznego hełmu nadającego się do kosmosu, pomalowana w klasyczne barwy inżynierii."
	greyscale_colors = "#E8D700#D75600"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 10, "fire" = 100, "acid" = 75, "stamina" = 0, "bleed" = 10)

/obj/item/clothing/head/helmet/space/plasmaman/mark2/engineering/atmospherics
	name = "hełm środowiskowy atmosferyki Mk.II"
	desc = "Nowa wersja klasycznego hełmu nadającego się do kosmosu, pomalowana w klasyczne barwy atmosferyki."
	greyscale_colors = "#E8D700#0098CA"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/cargo
	name = "hełm środowiskowy zaopatrzenia Mk.II"
	desc = "Stylowa nowa wersja oryginalnego hełmu izolującego plazmamana dla magazynierów i kwatermistrzów. Neoliberalne naciąganie jeszcze nigdy nie było tak odlotowe"
	greyscale_colors = "#ADADAD#BB9042"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/mailman
	name = "hełm środowiskowy listonosza Mk.II"
	desc = "Unowocześnione nakrycie głowy plazmamanów z poczty <i>„Zawsze na czas”</i>."
	greyscale_colors = "#091544#e6c447"


/obj/item/clothing/head/helmet/space/plasmaman/mark2/mining
	name = "górniczy hełm środowiskowy Mk.II"
	desc = "Nowa stylizacja klasycznego hełmu w kolorze khaki wydawanego plazmamanom górnikom."
	greyscale_colors = "#E1D9CA#2BFF92"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/chaplain
	name = "hełm środowiskowy kapłana Mk.II"
	desc = "Stylowa nowa wersja oryginalnego hełmu izolującego dla najpobożniejszych plazmamanów. Dawne tradycje w nowoczesnej skorupie."
	greyscale_colors = "#313131#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/white
	name = "biały hełm środowiskowy Mk.II"
	desc = "Zwykły biały hełm środowiskowy przeniesiony w nową erę mody."
	greyscale_colors = "#E6E6E6#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/botany
	name = "hełm środowiskowy botaniki Mk.II"
	desc = "Stylowa nowa wersja oryginalnego hełmu izolującego plazmamana dla botaników. Teraz zaprojektowana specjalnie z myślą o drobnych obrażeniach od roślin."
	greyscale_colors = "#54911A#0650D7"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/janitor
	name = "hełm środowiskowy woźnego Mk.II"
	desc = "Nowy wygląd efektownego hełmu środowiskowego woźnego. Zdobądź uznanie, na jakie zasługujesz, dzięki temu krzykowi mody."
	greyscale_colors = "#ADADAD#FCFF00"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/exploration
	name = "górniczy hełm środowiskowy"
	desc = "Nowy hełm środowiskowy plazmamana zaprojektowany dla odkrywców, w ich charakterystycznym jaskrawym turkusie."
	greyscale_colors = "#E1D9CA#2BFF92"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/command
	name = "hełm środowiskowy kapitana Mk.II"
	desc = "Nowoczesny hełm wydawany szefowi dowództwa. Jeszcze elegantszy i stylowszy, jak każdy kapitan powinien być."
	greyscale_colors = "#005478#D7C73F"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/engineering/ce
	name = "hełm środowiskowy Głównego Inżyniera Mk.II"
	desc = "Stylowa nowa wersja oryginalnego hełmu izolującego plazmamana dla Głównego Inżyniera. Ten nie śmierdzi aż tak ptasią kupą."
	greyscale_colors = "#D7D7C4#D75600"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/cmo
	name = "hełm środowiskowy Ordynatora Mk.II"
	desc = "Elegancki nowy hełm wydawany szefowi personelu medycznego. Pochwal się swoim wielkim czołem przed wszystkimi sztywniakami z nauki."
	greyscale_colors = "#6FABCE#E6E6E6"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/security/hos
	name = "hełm środowiskowy Komendanta Mk.II"
	desc = "Nowy wariant klasycznego wzmocnionego hełmu środowiskowego Komendanta. Wciąż ci się przyda."
	greyscale_colors = "#232A35#8A0400"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/rd
	name = "hełm środowiskowy Dyrektora Naukowego Mk.II"
	desc = "Stylowy nowy hełm wydawany szefowi personelu naukowego. Pochwal się swoim wielkim czołem przed wszystkimi mięczakami z medycyny."
	greyscale_colors = "#6F5828#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/hop
	name = "hełm środowiskowy Starszego Oficera Mk.II"
	desc = "Nowy hełm środowiskowy zrobiony dla Starszego Oficera, spryskany feromonami corgi."
	greyscale_colors = "#005478#AA1916"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/gold
	name = "designerski hełm środowiskowy Mk.II"
	desc = "Hełm środowiskowy Plasmi-Deluxe z wplecionym w tkaninę złotem. To najnowsza wersja."
	greyscale_colors = "#C47D0C#C47D0C"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/commander
	name = "hełm środowiskowy Komandora Centrali Mk.II"
	desc = "Specjalny hełm izolujący zaprojektowany dla wyższych rangą członków Centrali. Niewiele ich istnieje, bo Centrala z powodu komplikacji zwykle nie obsadza plazmamanami wyższych stanowisk."
	greyscale_colors = "#007F00#E1C709"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/official
	name = "hełm środowiskowy przedstawiciela Centrali Mk.II"
	desc = "Specjalny hełm izolujący zaprojektowany dla personelu Centrali. Oni naprawdę kochają ten swój zielony."
	greyscale_colors = "#099756#C0C0C0"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/intern
	name = "hełm środowiskowy stażysty Centrali"
	desc = "Specjalny hełm izolujący zaprojektowany dla personelu Centrali. No wiesz, żeby rozlana kawa nie zabiła biedaka."
	greyscale_colors = "#088756#313131"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/bartender
	name = "biały hełm środowiskowy z cylindrem"
	desc = "Nowy hełm środowiskowy plazmamana zaprojektowany dla barmanów, z cylindrem przymocowanym na czubku."
	greyscale_colors = "#E6E6E6#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/mime
	name = "hełm środowiskowy mima"
	desc = "Nowy hełm środowiskowy plazmamana zaprojektowany dla mimów."
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	icon_state = "mime_mark2"
	item_state = "mime_mark2"
	visor_state = "mime_visor_mk2"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/clown
	name = "hełm środowiskowy klauna"
	desc = "Nowy hełm środowiskowy plazmamana zaprojektowany dla klaunów."
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	icon_state = "clown_mark2"
	item_state = "clown_mark2"
	visor_state = "clown_visor_mk2"

/obj/item/clothing/head/helmet/space/plasmaman/mark2/bartender/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/head/hat = new /obj/item/clothing/head/that
	attached_hat = hat
	hat.forceMove(src)
	update_icon()
	add_verb(/obj/item/clothing/head/helmet/space/plasmaman/verb/unattach_hat)

// The Protective helmet variants
/obj/item/clothing/head/helmet/space/plasmaman/protective
	name = "wzmocniony hełm środowiskowy"
	desc = "Ten hełm pierwotnie zaprojektowano dla ekip inżynieryjnych w bardziej rozklekotanych koloniach wydobywających plazmę. Teraz, po kilku poprawkach konstrukcji i pozwach zbiorowych, znów trafił do plazmaludzi z NT jako zabawny dodatek kosmetyczny."
	greyscale_colors = "#DF5900#A349A4"
	greyscale_config = /datum/greyscale_config/plasmaman_helmet_protective
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_helmet_protective_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_helmet_protective_inhand_right
	greyscale_config_worn = /datum/greyscale_config/plasmaman_helmet_protective_worn
	visor_state = "protective_visor"

/obj/item/clothing/head/helmet/space/plasmaman/protective/security
	name = "wzmocniony policyjny hełm środowiskowy"
	desc = "Wzmocniony hełm izolujący plazmamana zaprojektowany dla policjantów."
	greyscale_colors = "#9F2A2E#2D2D2D"

/obj/item/clothing/head/helmet/space/plasmaman/protective/security/warden
	name = "wzmocniony hełm środowiskowy Naczelnika"
	desc = "Wzmocniony hełm izolujący plazmamana zaprojektowany dla Naczelnika."
	greyscale_colors = "#9F2A2E#C0C0C0"

/obj/item/clothing/head/helmet/space/plasmaman/protective/medical
	name = "wzmocniony medyczny hełm środowiskowy"
	desc = "Wzmocniony hełm izolujący plazmamana zaprojektowany dla lekarzy."
	greyscale_colors = "#E6E6E6#5A96BB"

/obj/item/clothing/head/helmet/space/plasmaman/protective/genetics
	name = "wzmocniony hełm środowiskowy genetyka"
	desc = "Wzmocniony hełm izolujący plazmamana zaprojektowany dla genetyków."
	greyscale_colors = "#E6E6E6#0097CA"

/obj/item/clothing/head/helmet/space/plasmaman/protective/viro
	name = "wzmocniony hełm środowiskowy wirologii"
	desc = "Hełm najbezpieczniejszych ludzi na statku – tych, którzy są całkowicie odporni na potworności, które sami tworzą."
	greyscale_colors = "#E6E6E6#339900"

/obj/item/clothing/head/helmet/space/plasmaman/protective/chemist
	name = "wzmocniony hełm środowiskowy chemii"
	desc = "Wzmocniony hełm izolujący plazmamana zaprojektowany dla chemików."
	greyscale_colors = "#E6E6E6#FF8800"

/obj/item/clothing/head/helmet/space/plasmaman/protective/paramedic
	name = "wzmocniony hełm środowiskowy ratownika medycznego"
	desc = "Nowy, ulepszony hełm środowiskowy tylko dla najodważniejszego plazmamana z medycyny."
	greyscale_colors = "#2C3A4E#EBEBEB"

/obj/item/clothing/head/helmet/space/plasmaman/protective/security/secmed
	name = "wzmocniony hełm środowiskowy Lekarza Więziennego"
	desc = "Wzmocniony hełm izolujący plazmamana zaprojektowany dla lekarzy więziennych."
	greyscale_colors = "#A5A9B6#C4373C"

/obj/item/clothing/head/helmet/space/plasmaman/protective/science
	name = "wzmocniony hełm środowiskowy nauki"
	desc = "Wzmocniony hełm izolujący plazmamana zaprojektowany dla naukowców."
	greyscale_colors = "#E6E6E6#9E00EA"

/obj/item/clothing/head/helmet/space/plasmaman/protective/robotics
	name = "wzmocniony hełm środowiskowy robotyki"
	desc = "Wzmocniony hełm izolujący plazmamana zaprojektowany dla robotyków."
	greyscale_colors = "#3F3B4C#722BA4"

/obj/item/clothing/head/helmet/space/plasmaman/protective/engineering
	name = "wzmocniony inżynieryjny hełm środowiskowy"
	desc = "Bezpieczniej wyglądająca nowa interpretacja klasycznego hełmu nadającego się do kosmosu, pomalowana w klasyczne barwy inżynierii."
	greyscale_colors = "#E8D700#D75600"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 10, "fire" = 100, "acid" = 75, "stamina" = 0, "bleed" = 10)

/obj/item/clothing/head/helmet/space/plasmaman/protective/engineering/atmospherics
	name = "wzmocniony hełm środowiskowy atmosferyki"
	desc = "Bezpieczniej wyglądająca nowa interpretacja klasycznego hełmu nadającego się do kosmosu, pomalowana w klasyczne barwy atmosferyki."
	greyscale_colors = "#E8D700#0098CA"

/obj/item/clothing/head/helmet/space/plasmaman/protective/cargo
	name = "wzmocniony hełm środowiskowy zaopatrzenia"
	desc = "Wzmocniony hełm izolujący plazmamana zaprojektowany dla magazynierów i kwatermistrzów."
	greyscale_colors = "#ADADAD#BB9042"

/obj/item/clothing/head/helmet/space/plasmaman/protective/mailman
	name = "hełm środowiskowy listonosza Mk.II"
	desc = "Wzmocnione nakrycie głowy plazmamanów z poczty <i>„Zawsze na czas”</i>."
	greyscale_colors = "#091544#e6c447"

/obj/item/clothing/head/helmet/space/plasmaman/protective/mining
	name = "górniczy hełm środowiskowy Mk.II"
	desc = "Nowa stylizacja klasycznego hełmu w kolorze khaki wydawanego plazmamanom górnikom."
	greyscale_colors = "#55524A#8A5AE1"

/obj/item/clothing/head/helmet/space/plasmaman/protective/chaplain
	name = "wzmocniony hełm środowiskowy kapłana"
	desc = "Wzmocniony hełm izolujący zaprojektowany dla najpobożniejszych plazmamanów."
	greyscale_colors = "#313131#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/protective/white
	name = "wzmocniony biały hełm środowiskowy"
	desc = "Zwykły biały hełm środowiskowy w masywnej, być może lepiej chroniącej skorupie."
	greyscale_colors = "#E6E6E6#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/protective/botany
	name = "wzmocniony hełm środowiskowy botaniki"
	desc = "Wzmocniony hełm izolujący plazmamana zaprojektowany dla botaników."
	greyscale_colors = "#54911A#0650D7"

/obj/item/clothing/head/helmet/space/plasmaman/protective/janitor
	name = "wzmocniony hełm środowiskowy woźnego"
	desc = "Masywniejsza wersja hełmu środowiskowego woźnego."
	greyscale_colors = "#ADADAD#FCFF00"

/obj/item/clothing/head/helmet/space/plasmaman/protective/exploration
	name = "wzmocniony górniczy hełm środowiskowy"
	desc = "Nowy hełm środowiskowy plazmamana zaprojektowany dla odkrywców, w ich charakterystycznym jaskrawym turkusie."
	greyscale_colors = "#CFC7B8#0CD46C"

/obj/item/clothing/head/helmet/space/plasmaman/protective/command
	name = "wzmocniony hełm środowiskowy kapitana"
	desc = "Lepiej chroniący hełm wydawany szefowi dowództwa. Może pomoże. Może."
	greyscale_colors = "#005478#D7C73F"

/obj/item/clothing/head/helmet/space/plasmaman/protective/engineering/ce
	name = "wzmocniony hełm środowiskowy Głównego Inżyniera"
	desc = "Wzmocniony hełm izolujący plazmamana zaprojektowany dla Głównego Inżyniera."
	greyscale_colors = "#D7D7C3#D75600"

/obj/item/clothing/head/helmet/space/plasmaman/protective/cmo
	name = "wzmocniony hełm środowiskowy Ordynatora"
	desc = "Masywny nowy hełm wydawany szefowi personelu medycznego."
	greyscale_colors = "#6FABCE#E6E6E6"

/obj/item/clothing/head/helmet/space/plasmaman/protective/security/hos
	name = "wzmocniony hełm środowiskowy Komendanta"
	desc = "Lepiej opancerzony wariant klasycznego wzmocnionego hełmu środowiskowego Komendanta."
	greyscale_colors = "#232A35#8A0400"

/obj/item/clothing/head/helmet/space/plasmaman/protective/rd
	name = "wzmocniony hełm środowiskowy Dyrektora Naukowego"
	desc = "Nieporęczny nowy hełm wydawany szefowi personelu naukowego."
	greyscale_colors = "#6F5828#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/protective/hop
	name = "wzmocniony hełm środowiskowy Starszego Oficera"
	desc = "Nowy, rzekomo bezpieczniejszy hełm środowiskowy zrobiony dla Starszego Oficera."
	greyscale_colors = "#005478#AA1916"

/obj/item/clothing/head/helmet/space/plasmaman/protective/gold
	name = "wzmocniony designerski hełm środowiskowy"
	desc = "Hełm środowiskowy Plasmi-Deluxe z wplecionym w tkaninę złotem. To najnowsza wersja."
	greyscale_colors = "#C47D0C#C47D0C"

/obj/item/clothing/head/helmet/space/plasmaman/protective/commander
	name = "wzmocniony hełm środowiskowy Komandora Centrali"
	desc = "Specjalny hełm izolujący zaprojektowany dla wyższych rangą członków Centrali. Niewiele ich istnieje, bo Centrala z powodu komplikacji zwykle nie obsadza plazmamanami wyższych stanowisk."
	greyscale_colors = "#007F00#E1C709"

/obj/item/clothing/head/helmet/space/plasmaman/protective/official
	name = "wzmocniony hełm środowiskowy przedstawiciela Centrali"
	desc = "Specjalny hełm izolujący zaprojektowany dla personelu Centrali. Oni naprawdę kochają ten swój zielony."
	greyscale_colors = "#099756#C0C0C0"

/obj/item/clothing/head/helmet/space/plasmaman/protective/intern
	name = "wzmocniony hełm środowiskowy stażysty Centrali"
	desc = "Specjalny hełm izolujący zaprojektowany dla personelu Centrali. No wiesz, żeby rozlana kawa nie zabiła biedaka."
	greyscale_colors = "#088756#313131"

/obj/item/clothing/head/helmet/space/plasmaman/protective/bartender
	name = "biały hełm środowiskowy z cylindrem"
	desc = "Specjalny hełm izolujący zaprojektowany dla barmanów, z cylindrem przymocowanym na czubku."
	greyscale_colors = "#E6E6E6#A349A4"

/obj/item/clothing/head/helmet/space/plasmaman/protective/bartender/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/head/hat = new /obj/item/clothing/head/that
	attached_hat = hat
	hat.forceMove(src)
	update_icon()
	add_verb(/obj/item/clothing/head/helmet/space/plasmaman/verb/unattach_hat)
