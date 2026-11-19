// AQUILA - marki protez (robolimbs z Baystation12/Polarisa/Paradise: code/modules/organs/robolimbs.dm) i protezy
// z realistyczną skórą (Polaris lifelike, Bay Vey-Med skintone). Marka to sam wygląd: sprite (style z maszyny do dopasowania
// augmentacji, ikony NSV13 i tg) i opis przy oględzinach, bez cech (obrażeń, EMP, bólu, samonaprawy).
// Vey-Med wygląda jak ciało w kolorze skóry właściciela i zdradza się dopiero z bliska albo po uszkodzeniu.
// Kończyny IPC rysuje podwozie gatunku, więc marka ich nie zmienia.

/datum/aq_robolimb_brand
	/// Klucz w GLOB.aq_robolimb_brands i w preferencjach
	var/id
	/// Nazwa producenta
	var/name = "Bez marki"
	/// Opis przy oględzinach
	var/desc = "Zwykła proteza bez znaku producenta."
	/// Sprite kończyny (stany robotic_<strefa>)
	var/limb_icon = 'icons/mob/augmentation/augments.dmi'
	/// Wersja męska sprite'u, jeśli marka ma osobną
	var/limb_icon_male
	/// Wygląda jak ciało w kolorze skóry właściciela
	var/lifelike = FALSE

/datum/aq_robolimb_brand/proc/get_icon(gender)
	if(limb_icon_male && gender == MALE)
		return limb_icon_male
	return limb_icon

/datum/aq_robolimb_brand/nanotrasen
	id = "nanotrasen"
	name = "Nanotrasen"
	desc = "Prosta i wydajna proteza z fabryk Nanotrasen."
	limb_icon = 'icons/mob/augmentation/augments.dmi'

/datum/aq_robolimb_brand/nanotrasen_engineering
	id = "nanotrasen_engineering"
	name = "Nanotrasen (inżynieria)"
	desc = "Proteza Nanotrasen w żółtej, izolowanej obudowie dla inżynierów."
	limb_icon = 'icons/mob/augmentation/augments_engineer.dmi'

/datum/aq_robolimb_brand/nanotrasen_security
	id = "nanotrasen_security"
	name = "Nanotrasen (ochrona)"
	desc = "Proteza Nanotrasen w czerwonej, wzmocnionej obudowie dla ochrony."
	limb_icon = 'icons/mob/augmentation/augments_security.dmi'

/datum/aq_robolimb_brand/nanotrasen_mining
	id = "nanotrasen_mining"
	name = "Nanotrasen (górnictwo)"
	desc = "Toporna proteza Nanotrasen w brązowej obudowie dla górników."
	limb_icon = 'icons/mob/augmentation/augments_mining.dmi'

/datum/aq_robolimb_brand/bishop
	id = "bishop"
	name = "Bishop Cybernetics"
	desc = "Biała obudowa z polimeru z niebieskimi holowyświetlaczami."
	limb_icon = 'nsv13/icons/mob/augmentation/bishop.dmi'

/datum/aq_robolimb_brand/shellguard
	id = "shellguard"
	name = "Shellguard Munitions"
	desc = "Ciężka, wojskowa proteza w pancernej obudowie."
	limb_icon = 'nsv13/icons/mob/augmentation/shellguard.dmi'

/datum/aq_robolimb_brand/xion
	id = "xion"
	name = "Xion Manufacturing Group"
	desc = "Minimalistyczna, przemysłowa obudowa w czerni i czerwieni."
	limb_icon = 'nsv13/icons/mob/augmentation/xion.dmi'

/datum/aq_robolimb_brand/zenghu
	id = "zenghu"
	name = "Zeng-Hu Pharmaceuticals"
	desc = "Gumowe pokrycie w kolorze ciała z widocznymi szwami."
	limb_icon = 'nsv13/icons/mob/augmentation/zenghu.dmi'

/datum/aq_robolimb_brand/wardtakahashi
	id = "wardtakahashi"
	name = "Ward-Takahashi"
	desc = "Smukła obudowa z czarnych i białych polimerów."
	limb_icon = 'nsv13/icons/mob/augmentation/wardtakahashi.dmi'

/datum/aq_robolimb_brand/veymed
	id = "veymed"
	name = "Vey-Med"
	desc = "Proteza najwyższej jakości, prawie nie do odróżnienia od ciała."
	limb_icon = 'nsv13/icons/mob/augmentation/veymed.dmi'
	limb_icon_male = 'nsv13/icons/mob/augmentation/veymedm.dmi'
	lifelike = TRUE

/// id -> marka
GLOBAL_LIST_INIT(aq_robolimb_brands, aq_init_robolimb_brands())

/proc/aq_init_robolimb_brands()
	. = list()
	for(var/datum/aq_robolimb_brand/brand_type as anything in subtypesof(/datum/aq_robolimb_brand))
		var/datum/aq_robolimb_brand/brand = new brand_type
		.[brand.id] = brand

/// Marka po pliku ikony (maszyna do dopasowania augmentacji zmienia sam sprite)
/proc/aq_robolimb_brand_by_icon(icon_file)
	for(var/id in GLOB.aq_robolimb_brands)
		var/datum/aq_robolimb_brand/brand = GLOB.aq_robolimb_brands[id]
		if("[brand.limb_icon]" == "[icon_file]" || (brand.limb_icon_male && "[brand.limb_icon_male]" == "[icon_file]"))
			return brand

/obj/item/bodypart
	/// AQUILA - marka protezy (limb_brands.dm), null dla ciała i dla kończyn bez marki
	var/datum/aq_robolimb_brand/aq_brand
	/// AQUILA - wygląd ciała, które udaje proteza z realistyczną skórą
	var/aq_lifelike_icon
	var/aq_lifelike_limb_id

/// Czy marka może być na tej kończynie: zwykłe protezy, bez IPC (podwozie), kołków i protez kinetycznych
/obj/item/bodypart/proc/aq_can_have_brand()
	return !IS_ORGANIC_LIMB(src) && (bodytype & BODYTYPE_ROBOTIC) && limb_id != "synth" && !animal_origin && !is_pseudopart && !aq_is_advanced()

/// Nadaje kończynie markę: sprite, nazwę i cechy
/obj/item/bodypart/proc/aq_set_brand(datum/aq_robolimb_brand/brand, gender)
	if(istext(brand))
		brand = GLOB.aq_robolimb_brands[brand]
	if(!brand || !aq_can_have_brand())
		return FALSE
	aq_brand = brand
	if(!(bodytype & BODYTYPE_DIGITIGRADE))
		static_icon = brand.get_icon(gender || owner?.gender)
		limb_id = "robotic"
	should_draw_greyscale = FALSE
	update_icon_dropped()
	if(owner)
		owner.update_body()
	return TRUE

/// Maszyna do dopasowania augmentacji zmienia tylko sprite, marka idzie za nim
/obj/item/bodypart/proc/aq_sync_brand_from_icon()
	if(!aq_can_have_brand())
		return
	var/datum/aq_robolimb_brand/brand = aq_robolimb_brand_by_icon(static_icon)
	if(brand)
		aq_brand = brand

/obj/machinery/aug_manipulator/eject_part(mob/living/user)
	storedpart?.aq_sync_brand_from_icon()
	return ..()

/// Proteza z realistyczną skórą pokazuje swój prawdziwy wygląd po uszkodzeniu
/obj/item/bodypart/proc/aq_lifelike_disguised()
	return aq_brand?.lifelike && get_damage() < max_damage * 0.3

/obj/item/bodypart/get_limb_icon(dropped)
	if(!aq_lifelike_disguised() || dropped)
		return ..()
	var/old_icon = icon
	var/old_limb_id = limb_id
	var/old_greyscale = should_draw_greyscale
	icon = aq_lifelike_icon || 'icons/mob/human_parts_greyscale.dmi'
	limb_id = aq_lifelike_limb_id || SPECIES_HUMAN
	should_draw_greyscale = TRUE
	. = ..()
	icon = old_icon
	limb_id = old_limb_id
	should_draw_greyscale = old_greyscale

/// Pamięć ikon kończyn liczy klucz z limb_id, więc różne marki z limb_id "robotic" by się myliły
/mob/living/carbon/generate_icon_key(obj/item/bodypart/BP)
	. = ..()
	if(IS_ORGANIC_LIMB(BP) || BP.should_draw_greyscale)
		return
	. += "-[BP.static_icon]"
	if(BP.aq_lifelike_disguised())
		. += "-lifelike-[BP.aq_lifelike_limb_id]-[BP.species_color || BP.skin_tone]"

/// Zapamiętuje wygląd zastępowanej kończyny, żeby proteza z realistyczną skórą mogła go udawać
/obj/item/bodypart/proc/aq_copy_lifelike_look(obj/item/bodypart/old_limb)
	if(!old_limb || !IS_ORGANIC_LIMB(old_limb))
		return
	aq_lifelike_icon = old_limb.icon
	aq_lifelike_limb_id = old_limb.limb_id
	skin_tone = old_limb.skin_tone
	species_color = old_limb.species_color

/obj/item/bodypart/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, required_status = null)
	var/was_disguised = aq_lifelike_disguised()
	. = ..()
	if(was_disguised && !aq_lifelike_disguised() && owner)
		owner.visible_message("<span class='warning'>Spod rozerwanej skóry [owner] ([strefa_pl(body_zone)]) wyziera metal!</span>")
		owner.update_body()

/obj/item/bodypart/examine(mob/user)
	. = ..()
	if(aq_brand)
		. += "<span class='notice'>Proteza marki [aq_brand.name]: [aq_brand.desc]</span>"

/// Linijki przy oględzinach człowieka: widać protezy, a te z realistyczną skórą tylko z bliska albo po uszkodzeniu
/mob/living/carbon/human/proc/aq_prosthetic_examine_lines(mob/user)
	. = list()
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(!limb.aq_brand)
			continue
		if(limb.aq_lifelike_disguised() && get_dist(user, src) > 1)
			continue
		var/zone = strefa_pl(limb.body_zone)
		if(limb.aq_lifelike_disguised())
			. += "<span class='notice'>Z bliska widać, że [zone] to proteza [limb.aq_brand.name] ukryta pod sztuczną skórą.</span>"
		else
			. += "<span class='notice'>Ma protezę [limb.aq_brand.name] ([zone]).</span>"

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(user != src)
		. += aq_prosthetic_examine_lines(user)
