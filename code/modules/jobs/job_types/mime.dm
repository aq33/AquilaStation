/datum/job/mime
	title = JOB_NAME_MIME
	flag = MIME
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = JOB_NAME_HEADOFPERSONNEL
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/mime

	access = list(ACCESS_THEATRE)
	minimal_access = list(ACCESS_THEATRE)
	paycheck = PAYCHECK_MINIMAL
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_MIME
	departments = DEPARTMENT_BITFLAG_SERVICE
	rpg_title = "Fool"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/mime
	)

/datum/job/mime/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	H.apply_pref_name("mime", M.client)

/datum/outfit/job/mime
	name = JOB_NAME_MIME
	jobtype = /datum/job/mime

	id = /obj/item/card/id/job/mime
	belt = /obj/item/modular_computer/tablet/pda/mime
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/mime
	mask = /obj/item/clothing/mask/gas/mime
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/frenchberet
	suit = /obj/item/clothing/suit/suspenders
	backpack_contents = list(/obj/item/book/mimery=1, /obj/item/reagent_containers/food/drinks/bottle/bottleofnothing=1)

	backpack = /obj/item/storage/backpack/mime
	satchel = /obj/item/storage/backpack/mime


/datum/outfit/job/mime/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak(null))
		H.mind.miming = 1

/obj/item/book/mimery
	name = "Guide to Dank Mimery"
	desc = "A primer on basic pantomime."
	icon_state ="bookmime"

// AQ EDIT - jak w tg: wybór układu z menu radialnego zamiast okna HTML
/obj/item/book/mimery/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!check_mimery_menu(H))
		return
	var/static/list/routines = list(
		"Niewidzialna ściana" = /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall,
		"Niewidzialne krzesło" = /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_chair,
		"Niewidzialne pudło" = /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_box,
	)
	var/list/choices = list()
	for(var/routine in routines)
		var/obj/effect/proc_holder/spell/spell_type = routines[routine]
		choices[routine] = image(icon = initial(spell_type.action_icon), icon_state = initial(spell_type.action_icon_state))
	to_chat(H, "<span class='notice'>Książka uczy jednego z trzech klasycznych układów pantomimy, pozwalając wprawnemu mimowi przywoływać niewidzialne przedmioty do cielesnego istnienia. Gdy opanujesz swój układ, nie będzie miała ci już nic do powiedzenia.</span>")
	var/choice = show_radial_menu(H, src, choices, custom_check = CALLBACK(src, .proc/check_mimery_menu, H), require_near = TRUE, tooltips = TRUE)
	if(!choice || !routines[choice] || !check_mimery_menu(H))
		return
	var/spell_type = routines[choice]
	H.mind.AddSpell(new spell_type(null))
	to_chat(H, "<span class='notice'>Książka znika w powietrzu.</span>")
	qdel(src)

/obj/item/book/mimery/proc/check_mimery_menu(mob/living/carbon/human/H)
	if(QDELETED(src) || QDELETED(H) || !H.mind)
		return FALSE
	if(H.stat || H.restrained())
		return FALSE
	return H.is_holding(src)
