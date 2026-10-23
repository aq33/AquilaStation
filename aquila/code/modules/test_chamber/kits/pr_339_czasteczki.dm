// aq33/AquilaStation#339 - efekty cząsteczek: dym i iskry z flary, ogniska i przegrzanego IPC

/datum/test_chamber_kit/pr_339
	name = "PR 339: cząsteczki - flara, ognisko, przegrzany IPC"
	pr = "aq33/AquilaStation#339"
	description = "Zapal flarę (użyj w ręce) - ma sypać iskrami i dymić, po zgaszeniu efekt łagodnie zanika. Pochodnia zostaje bez efektu. \
	Podpal ognisko zapalniczką - płomienie, iskry i dym; zgaś gaśnicą, efekt ma zniknąć. \
	IPC jest przegrzany (temperatura ciała powyżej progu obrażeń) - ma dymić, a gdy ostygnie, dym ma zniknąć. Zwykły człowiek obok nie dymi."
	items = list(
		/obj/item/flashlight/flare = 2,
		/obj/item/flashlight/flare/torch = 1,
		/obj/structure/bonfire = 1,
		/obj/item/lighter = 1,
		/obj/item/extinguisher = 1,
		/mob/living/carbon/human = 2,
	)

/datum/test_chamber_kit/pr_339/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Drugi człowiek z listy zostaje przegrzanym IPC
	var/mob/living/carbon/human/ipc = locate(/mob/living/carbon/human) in (spawned - (locate(/mob/living/carbon/human) in spawned))
	if(!ipc)
		return
	ipc.forceMove(turfs[min(length(items) + 1, length(turfs))])
	ipc.set_species(/datum/species/ipc)
	ipc.real_name = "Przegrzany IPC"
	ipc.name = ipc.real_name
	ipc.bodytemperature = BODYTEMP_HEAT_DAMAGE_LIMIT + 100
