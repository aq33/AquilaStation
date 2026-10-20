#define REVELATION_MIN_COOLDOWN	20 SECONDS
#define REVELATION_MAX_COOLDOWN	1 MINUTES

/datum/vampire_clan/malkavian
	name = CLAN_MALKAVIAN
	description = "Malkavianie to potomstwo Malkava i jeden z wielkich wampirzych klanów. To obłąkane wampiry, dotknięte szaleństwem swego przedpotopowego protoplasty.<br><br>\
		Członkowie klanu przyjęli role wieszczów i wyroczni wśród Spokrewnionych i śmiertelników - niesamowite postacie spętane dziwnymi przymusami i zdolnością dostrzegania tego, czego inni nie widzą.<br><br>\
		Słyną też jako notoryczni dowcipnisie, których 'żarty' bywają od głupich po sadystyczne. Wbrew wszelkim przeciwnościom dzieci Malkava należą jednak do najstarszych zachowanych wampirzych linii."
	join_icon_state = "malkavian"
	joinable_clan = TRUE
	default_humanity = 8
	princely_score_bonus = 6

	COOLDOWN_DECLARE(revelation_cooldown)

/datum/vampire_clan/malkavian/New(datum/antagonist/vampire/owner_datum)
	. = ..()

	vampiredatum.owned_disciplines += new /datum/discipline/auspex/malkavian(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/obfuscate(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/dominate(vampiredatum)


	var/mob/living/carbon/carbon_owner = vampiredatum.owner.current
	if(istype(carbon_owner))
		carbon_owner.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbon_owner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)

	ADD_TRAIT(vampiredatum.owner.current, TRAIT_XRAY_VISION, TRAIT_VAMPIRE)
	vampiredatum.owner.current.update_sight()

	vampiredatum.owner.current.playsound_local(get_turf(vampiredatum.owner.current), 'sound/ambience/antag/creepalert.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(vampiredatum.owner.current, span_hypnophrase("Witaj, dziecię Malkava..."))

/datum/vampire_clan/malkavian/Destroy(force)
	REMOVE_TRAIT(vampiredatum.owner.current, TRAIT_XRAY_VISION, TRAIT_VAMPIRE)
	vampiredatum.owner.current.update_sight()

	var/mob/living/carbon/carbon_owner = vampiredatum.owner.current
	if(istype(carbon_owner))
		carbon_owner.cure_trauma_type(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbon_owner.cure_trauma_type(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)
	return ..()

/datum/vampire_clan/malkavian/handle_clan_life()
	. = ..()
	var/mob/living/living_vampire = vampiredatum.owner.current
	if(!COOLDOWN_FINISHED(src, revelation_cooldown) || HAS_TRAIT(living_vampire, TRAIT_MASQUERADE) || living_vampire.stat != CONSCIOUS)
		return

	if(prob(15))
		var/message = pick(strings("malkavian_revelations.json", "revelations", "strings"))
		INVOKE_ASYNC(living_vampire, TYPE_PROC_REF(/mob/living, whisper), message)
		COOLDOWN_START(src, revelation_cooldown, rand(REVELATION_MIN_COOLDOWN, REVELATION_MAX_COOLDOWN))

/datum/vampire_clan/malkavian/on_exit_torpor()
	var/mob/living/carbon/carbon_vampire = vampiredatum.owner.current
	if(istype(carbon_vampire))
		carbon_vampire.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbon_vampire.gain_trauma(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)

#undef REVELATION_MAX_COOLDOWN
#undef REVELATION_MIN_COOLDOWN
