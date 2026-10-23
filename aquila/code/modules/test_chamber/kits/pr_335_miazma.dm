// aq33/AquilaStation#335 - przywrócenie miazmy: gnijące zwłoki i gibsy, oddychanie miazmą, sterylizacja

/datum/test_chamber_kit/pr_335
	name = "PR 335: miazma - gnijące zwłoki"
	pr = "aq33/AquilaStation#335"
	description = "Zrzuca trzy trupy z cofniętym czasem zgonu (gniją od razu, bez czekania 2 min): jeden leży luzem, jeden w worku na zwłoki, jeden z 20u formaldehydu. \
	SSmiasma odpala co 10 s - po kilkunastu sekundach analizator gazu przy luźnym trupie ma pokazać miazmę, przy dwóch pozostałych nie. Gibsy też gniją. \
	Zdejmij maskę i pooddychaj: zapach, moodlet, potem wymioty. Puść bąka (*fart) - dochodzi odrobina miazmy. Kanister miazmy do szybkiego testu oddychania, scrubber ją wyłapuje. \
	Gnicie można jeszcze przyspieszyć, ustawiając VV trupa timeofdeath na mniejsze, albo wait SSmiasma (Debug -> Debug Controller) na mniejsze."
	items = list(
		/obj/item/analyzer = 1,
		/obj/item/clothing/mask/gas = 1,
		/obj/item/tank/internals/oxygen = 1,
		/obj/effect/decal/cleanable/blood/gibs = 2,
		/obj/machinery/portable_atmospherics/canister/miasma = 1,
		/obj/machinery/portable_atmospherics/scrubber = 1,
		/obj/item/reagent_containers/glass/bottle/formaldehyde = 1,
		/obj/item/reagent_containers/syringe = 1,
	)

/datum/test_chamber_kit/pr_335/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/index = length(items)
	// Loose corpse, rotting right away
	var/mob/living/carbon/human/loose = new(turfs[min(++index, length(turfs))])
	loose.real_name = "Gnijący trup"
	loose.name = loose.real_name
	loose.death()
	loose.timeofdeath = world.time - MIASMA_CORPSE_GRACE_PERIOD

	// Corpse in a body bag - must not rot
	var/obj/structure/closet/body_bag/bag = new(turfs[min(++index, length(turfs))])
	var/mob/living/carbon/human/bagged = new(bag.loc)
	bagged.real_name = "Trup w worku"
	bagged.name = bagged.real_name
	bagged.death()
	bagged.timeofdeath = world.time - MIASMA_CORPSE_GRACE_PERIOD
	bagged.forceMove(bag)

	// Embalmed corpse - must not rot
	var/mob/living/carbon/human/embalmed = new(turfs[min(++index, length(turfs))])
	embalmed.real_name = "Zabalsamowany trup"
	embalmed.name = embalmed.real_name
	embalmed.reagents.add_reagent(/datum/reagent/toxin/formaldehyde, 20)
	embalmed.death()
	embalmed.timeofdeath = world.time - MIASMA_CORPSE_GRACE_PERIOD
