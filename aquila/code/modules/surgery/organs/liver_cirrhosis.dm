// Marskość wątroby: mocny alkohol albo duża ilość alkoholu uszkadzają wątrobę mimo limitu upicia,
// a długie picie zostawia trwałe zwłóknienie, którego nie da się wyleczyć inaczej niż przeszczepem wątroby.

/// Alcohol tolerance of a normal organic liver, used to scale damage for cybernetic livers
#define CIRRHOSIS_BASE_TOLERANCE 0.002
/// Mnożnik dodatkowych obrażeń od mocnego i dużej ilości alkoholu
#define CIRRHOSIS_ABUSE_MULTIPLIER 0.15
/// Drinks at least this strong count as hard liquor
#define CIRRHOSIS_STRONG_BOOZEPWR 65
/// Units of alcohol in the body above which drinking counts as heavy
#define CIRRHOSIS_HEAVY_VOLUME 30
/// Cirrhosis level at which the liver is scarred enough to stop healing fully
#define CIRRHOSIS_COMPENSATED 30
/// Cirrhosis level with symptoms and faster damage from alcohol
#define CIRRHOSIS_DECOMPENSATED 60
#define CIRRHOSIS_MAX 100

/obj/item/organ/liver
	// Wątroba obrywa od alkoholu 2,5 raza wolniej niż u Bee (ALCOHOL_RATE): butelka wódki uszkadza ją lekko,
	// dwie mocno, a niewydolność przychodzi dopiero po trzeciej
	alcohol_tolerance = CIRRHOSIS_BASE_TOLERANCE
	/// Permanent scarring from alcohol, 0 to CIRRHOSIS_MAX. Only a new liver gets rid of it.
	var/cirrhosis = 0

/obj/item/organ/liver/on_life()
	. = ..()
	var/mob/living/carbon/drinker = owner
	if(!istype(drinker) || HAS_TRAIT(drinker, TRAIT_NOMETABOLISM))
		return
	handle_cirrhosis(drinker)
	// A failing liver doesn't process alcohol, so it takes no new alcohol damage
	if((organ_flags & ORGAN_FAILING) || alcohol_tolerance <= 0)
		return
	handle_alcohol_abuse(drinker)

/// Extra liver damage from hard liquor and from drinking a lot at once
/obj/item/organ/liver/proc/handle_alcohol_abuse(mob/living/carbon/drinker)
	var/total_alcohol = 0
	var/abuse_damage = 0
	// Napój najpierw czeka w żołądku (stomach_contents.dm), więc alkohol liczymy w krwi i w żołądku razem:
	// progi działają tak, jak gdy całość od razu szła do krwi
	var/obj/item/organ/stomach/belly = drinker.getorganslot(ORGAN_SLOT_STOMACH)
	var/list/booze_volumes = list()
	var/list/booze_powers = list()
	for(var/datum/reagent/consumable/ethanol/booze in drinker.reagents.reagent_list)
		booze_volumes[booze.type] += booze.volume
		booze_powers[booze.type] = booze.boozepwr
	if(belly?.reagents)
		for(var/datum/reagent/consumable/ethanol/booze in belly.reagents.reagent_list)
			booze_volumes[booze.type] += booze.volume
			booze_powers[booze.type] = booze.boozepwr
	for(var/booze_type in booze_volumes)
		var/volume = booze_volumes[booze_type]
		var/boozepwr = booze_powers[booze_type]
		total_alcohol += volume
		if(boozepwr >= CIRRHOSIS_STRONG_BOOZEPWR)
			abuse_damage += 0.05 * ((boozepwr - 55) / 10) * sqrt(volume)
	if(total_alcohol > CIRRHOSIS_HEAVY_VOLUME)
		abuse_damage += 0.01 * (total_alcohol - CIRRHOSIS_HEAVY_VOLUME)
	if(abuse_damage <= 0)
		return
	// Zaprawiony pijak: wątroba przyzwyczajona do alkoholu obrywa słabiej i wolniej się bliznowacieje
	var/tolerant = HAS_TRAIT(drinker, TRAIT_ALCOHOL_TOLERANCE)
	if(tolerant)
		abuse_damage *= 0.5
	if(HAS_TRAIT(drinker, TRAIT_LIGHT_DRINKER))
		abuse_damage *= 1.5
	abuse_damage *= CIRRHOSIS_ABUSE_MULTIPLIER * alcohol_tolerance / CIRRHOSIS_BASE_TOLERANCE
	if(cirrhosis >= CIRRHOSIS_DECOMPENSATED)
		abuse_damage *= 1.5
	applyOrganDamage(abuse_damage)
	// Scarring builds up faster in a liver that is already damaged
	var/old_cirrhosis = cirrhosis
	var/scarring = abuse_damage * (0.2 + 0.8 * damage / maxHealth)
	if(tolerant)
		scarring *= 0.5
	cirrhosis = min(cirrhosis + scarring, CIRRHOSIS_MAX)
	if(old_cirrhosis < CIRRHOSIS_COMPENSATED && cirrhosis >= CIRRHOSIS_COMPENSATED)
		to_chat(drinker, "<span class='warning'>Czujesz ciężar i ucisk pod prawymi żebrami.</span>")
	else if(old_cirrhosis < CIRRHOSIS_DECOMPENSATED && cirrhosis >= CIRRHOSIS_DECOMPENSATED)
		to_chat(drinker, "<span class='danger'>Brzuch ci puchnie, a skóra swędzi nie do wytrzymania. Coś jest bardzo nie tak z twoją wątrobą.</span>")

/// Scarred tissue doesn't heal back and a badly scarred liver makes its owner sick
/obj/item/organ/liver/proc/handle_cirrhosis(mob/living/carbon/drinker)
	if(cirrhosis < CIRRHOSIS_COMPENSATED)
		return
	var/scar_floor = min(cirrhosis * 0.5, maxHealth - 1)
	if(damage < scar_floor)
		damage = scar_floor
	if(cirrhosis < CIRRHOSIS_DECOMPENSATED)
		return
	if(prob(2))
		to_chat(drinker, "<span class='warning'>[pick("Mdli cię.", "Swędzi cię całe ciało.", "Czujesz tępy ból pod prawymi żebrami.", "Brzuch masz napięty i obolały.")]</span>")
	if(prob(1))
		drinker.vomit(10)

/obj/item/organ/liver/examine(mob/user)
	. = ..()
	if(cirrhosis >= CIRRHOSIS_DECOMPENSATED)
		. += "<span class='warning'>Jest twarda, pomarszczona i pokryta guzkami - zaawansowana marskość.</span>"
	else if(cirrhosis >= CIRRHOSIS_COMPENSATED)
		. += "<span class='notice'>Jest bledsza niż powinna i wyczuwalnie zwłókniała.</span>"

/// Health analyzer line about cirrhosis, or null
/mob/living/carbon/proc/cirrhosis_scan_text()
	var/obj/item/organ/liver/liver = getorganslot(ORGAN_SLOT_LIVER)
	if(!istype(liver) || liver.cirrhosis < CIRRHOSIS_COMPENSATED)
		return
	var/stage = liver.cirrhosis >= CIRRHOSIS_DECOMPENSATED ? "niewyrównana" : "wyrównana"
	return "\t<span class='alert'>Wykryto marskość wątroby ([stage], [round(liver.cirrhosis)]% zwłóknienia). Zalecane postępowanie: <b>abstynencja i przeszczep wątroby</b>.</span>"

#undef CIRRHOSIS_BASE_TOLERANCE
#undef CIRRHOSIS_ABUSE_MULTIPLIER
#undef CIRRHOSIS_STRONG_BOOZEPWR
#undef CIRRHOSIS_HEAVY_VOLUME
#undef CIRRHOSIS_COMPENSATED
#undef CIRRHOSIS_DECOMPENSATED
#undef CIRRHOSIS_MAX
