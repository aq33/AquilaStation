// AQUILA - replica pod (klonowanie z krwi) przeniesiony na nową botanikę.
// U Bee w tym miejscu jest strąk diony z nimfą, której u nas nie ma. Krew wstrzyknięta do nasion trafia
// do cechy owocu, a gdy owoc dojrzeje i właściciel krwi jest martwy, z rośliny wychodzi człowiek-strąk.

/obj/item/plant_seeds/preset/diona_pod/on_reagent_change(changetype)
	. = ..()
	var/datum/plant_feature/fruit/cabbage/diona/pod = locate() in plant_features
	if(!pod)
		return
	var/datum/reagent/blood/blood = reagents.has_reagent(/datum/reagent/blood)
	if(!blood)
		pod.clone_data = null
		return
	if(changetype != ADD_REAGENT || pod.clone_data)
		return
	if(!blood.data["mind"] || !blood.data["cloneable"])
		visible_message("<span class='warning'>[src] odrzuca próbkę!</span>")
		return
	pod.clone_data = blood.data.Copy()
	visible_message("<span class='notice'>Do [src] wstrzyknięto świeżą próbkę krwi.</span>")
	log_cloning("[key_name(blood.data["mind"])]'s cloning record was added to [src] at [AREACOORD(src)].")

/obj/item/plant_seeds/preset/diona_pod/examine(mob/user)
	. = ..()
	var/datum/plant_feature/fruit/cabbage/diona/pod = locate() in plant_features
	if(pod?.clone_data)
		. += "<span class='notice'>Zawiera próbkę krwi z DNA ([pod.clone_data["blood_DNA"]]).</span>"

/datum/plant_feature/fruit/cabbage/diona/copy(datum/component/plant/_parent, datum/plant_feature/_feature)
	var/datum/plant_feature/fruit/cabbage/diona/new_pod = ..()
	new_pod.clone_data = clone_data?.Copy()
	return new_pod

/datum/plant_feature/fruit/cabbage/diona/build_fruit()
	var/mob/ghost = find_clone_player()
	if(!ghost)
		return ..()
	make_podman(ghost)
	clone_data = null

/// Szuka martwego gracza z próbki krwi, który może wrócić do ciała
/datum/plant_feature/fruit/cabbage/diona/proc/find_clone_player()
	if(!clone_data || !CONFIG_GET(flag/revival_pod_plants))
		return
	var/datum/mind/mind = clone_data["mind"]
	var/ckey = clone_data["ckey"]
	for(var/mob/M in GLOB.player_list)
		var/matches = ckey ? (M.ckey == ckey) : (mind && M.mind && ckey(M.mind.key) == ckey(mind.key) && M.client)
		if(!matches)
			continue
		if(isobserver(M))
			var/mob/dead/observer/O = M
			return O.can_reenter_corpse ? M : null
		if(M.stat != DEAD || M.suiciding)
			return
		if(isliving(M))
			var/mob/living/L = M
			if(L.ishellbound())
				return
		return M

/datum/plant_feature/fruit/cabbage/diona/proc/make_podman(mob/player)
	var/turf/T = get_turf(parent.plant_item)
	var/datum/mind/mind = clone_data["mind"]
	var/mob/living/carbon/human/podman = new /mob/living/carbon/human(T)
	podman.real_name = clone_data["real_name"] || "Człowiek-strąk ([rand(1,999)])"
	mind.transfer_to(podman)
	podman.ckey = player.ckey
	podman.gender = clone_data["gender"]
	podman.faction |= clone_data["factions"]
	var/list/features = clone_data["features"] || list()
	if(!features["mcolor"])
		features["mcolor"] = "#59CE00"
	for(var/quirk in clone_data["quirks"])
		new quirk(podman)
	podman.hardset_dna(null, null, podman.real_name, clone_data["blood_type"], new /datum/species/pod, features, null) // Klonowanie strąkiem jest niedokładne, zawsze wychodzi człowiek-strąk
	podman.set_cloned_appearance()
	to_chat(podman, "<span class='notice'><b>Następuje jasny błysk!</b><br><i>Czujesz się jak nowa istota.</i></span>")
	podman.flash_act()
	log_cloning("[key_name(mind)] cloned as a podman via [parent.plant_item] at [AREACOORD(T)].")
