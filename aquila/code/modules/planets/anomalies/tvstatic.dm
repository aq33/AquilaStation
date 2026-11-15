// AQUILA - anomalia szumu i kwantowa czarna skrzynka: port z Shiptesta (code/game/objects/effects/anomalies/
// anomalies_static.dm, rdzeń z code/modules/assembly/anomalies.dm, licencja AGPLv3; sprite z Shiptesta, CC BY-SA 3.0;
// dźwięki radiohiss, stall, walkietalkie i static z Shiptesta, CC BY-SA 3.0).
// Szum oślepia zakłóceniami i uszkadza mózg ludzi w pobliżu (bez implantu lojalności, głuchych i tych ze skanerem
// badawczym). Kto ma mózg zniszczony w 3/4, może zostać wchłonięty: ginie, a w jego miejscu powstaje nowy szum.
// W środku bywa ciało (25%), które szum wypluwa po neutralizacji.
// Różnice względem Shiptesta:
// - zakłócenia przez nakładkę „flash/static” bez flash_act (nasz flash_act u ludzi nie przyjmuje typu nakładki);
// - ciało w środku to zwłoki zarażone legionem, tworzone przez spawner na polu anomalii i wciągane do środka (nasze
//   mob_spawn nie zwraca stworzonego moba);
// - bez własnego spawnera ciała (stored_mob_spawner) używanego tylko w mapach Shiptesta;
// - czarna skrzynka ma nasz sprite czarnej kostki (icons/obj/stationobjs.dmi „blackcube”, jak w Shiptest).

GLOBAL_LIST_INIT(tvstatic_sayings, list(
	"...pomóż mi...",
	"...muszę się stąd wydostać...",
	"...nie ma nadziei...",
	"...wypuść mnie...",
	"...zostań ze mną...",
	"...nie tak...",
	"...proszę, nie odchodź...",
	"...nie zapomnij o mnie...",
	"...jesteś tam...?",
	"...boli...",
	"...te oczy...",
	"...trzeba uciekać...",
	"...jest tu ktoś...",
))

/obj/effect/anomaly/tvstatic
	name = "anomalia szumu"
	desc = "Dziura w świecie, z której bez końca dobiega brzęczenie. Skrywa coś cennego."
	icon = 'aquila/icons/planets/anomalies.dmi'
	icon_state = "static"
	density = TRUE
	aSignal = /obj/item/assembly/signaler/anomaly/tvstatic
	verb_say = "błaga"
	verb_ask = "błaga"
	verb_exclaim = "krzyczy"
	verb_whisper = "kwili"
	verb_yell = "krzyczy"
	speech_span = SPAN_ITALICS
	var/effectrange = 4
	var/pulse_delay = 4 SECONDS
	COOLDOWN_DECLARE(pulse_cooldown)
	/// Ciało uwięzione w szumie
	var/mob/living/carbon/stored_mob

/obj/effect/anomaly/tvstatic/Initialize(mapload, new_lifespan)
	. = ..()
	pulse_delay = rand(pulse_delay * 0.5, pulse_delay * 1.5)

/obj/effect/anomaly/tvstatic/Destroy()
	release_stored_mob()
	return ..()

/obj/effect/anomaly/tvstatic/examine(mob/user)
	. = ..()
	if(!iscarbon(user) || user.research_scanner)
		return
	var/mob/living/carbon/victim = user
	to_chat(victim, "<span class='userdanger'>Głowa ci pęka, gdy wpatrujesz się w [src]!</span>")
	static_flash(victim)
	SEND_SOUND(victim, 'aquila/sound/effects/anomaly/static.ogg')
	victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 100)

/// Zakłócenia na ekranie (jak błysk)
/obj/effect/anomaly/tvstatic/proc/static_flash(mob/living/carbon/victim)
	victim.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/static)
	addtimer(CALLBACK(victim, TYPE_PROC_REF(/mob, clear_fullscreen), "flash", 25), 25)

/obj/effect/anomaly/tvstatic/anomalyEffect(delta_time)
	..()
	var/turf/spot = locate(rand(x - effectrange, x + effectrange), rand(y - effectrange, y + effectrange), z)
	if(spot)
		new /obj/effect/particle_effect/staticball(spot)
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	for(var/mob/living/carbon/human/looking in range(effectrange, src))
		playsound(src, 'aquila/sound/effects/anomaly/walkietalkie.ogg', 75)
		if(stored_mob && looking.stat != DEAD && prob(25))
			say(pick(GLOB.tvstatic_sayings))
		if(HAS_TRAIT(looking, TRAIT_MINDSHIELD) || looking.stat == DEAD || looking.research_scanner || HAS_TRAIT(looking, TRAIT_DEAF))
			continue
		looking.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 200)
		static_flash(looking)
		playsound(src, 'aquila/sound/effects/anomaly/radiohiss.ogg', 50)
		if(looking.getOrganLoss(ORGAN_SLOT_BRAIN) >= 150 && looking.stat != DEAD && prob(20))
			consume(looking)

/// Wchłania człowieka: ginie, a na jego miejscu powstaje nowy szum z jego ciałem w środku
/obj/effect/anomaly/tvstatic/proc/consume(mob/living/carbon/human/victim)
	var/obj/effect/anomaly/tvstatic/planetary/expansion = new(get_turf(victim))
	visible_message("<span class='warning'>[src] pochłania [victim], a na jego miejscu pojawia się [expansion]!</span>")
	victim.death()
	expansion.store_mob(victim)

/obj/effect/anomaly/tvstatic/proc/store_mob(mob/living/carbon/victim)
	stored_mob = victim
	victim.forceMove(src)

/// Wypluwa ciało na pole anomalii
/obj/effect/anomaly/tvstatic/proc/release_stored_mob()
	if(!stored_mob)
		return
	var/turf/T = get_turf(src)
	if(T && stored_mob.loc == src)
		stored_mob.forceMove(T)
	stored_mob = null

/obj/effect/anomaly/tvstatic/Bumped(atom/movable/AM)
	anomalyEffect()

/obj/effect/anomaly/tvstatic/detonate()
	for(var/mob/living/carbon/human/looking in range(effectrange, src))
		visible_message("<span class='boldwarning'>[src] smaga mackami, a ból wypełnia umysły wszystkich dookoła!</span>")
		if(!HAS_TRAIT(looking, TRAIT_MINDSHIELD) && looking.stat != DEAD)
			looking.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100, 200)
			playsound(src, 'aquila/sound/effects/anomaly/stall.ogg', 100)
	if(stored_mob)
		stored_mob.adjustBruteLoss(400)
		visible_message("<span class='warning'>[src] wypluwa [stored_mob] w fontannie krwi i wnętrzności!</span>")
		new /obj/effect/gibspawner/human(loc)
		release_stored_mob()

/obj/effect/anomaly/tvstatic/anomalyNeutralize()
	if(stored_mob)
		visible_message("<span class='warning'>[src] wypluwa [stored_mob]!</span>")
		release_stored_mob()
	return ..()

/obj/effect/anomaly/tvstatic/planetary
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/tvstatic

/// Szum na planecie: w co czwartym jest ciało, zwłoki zarażone legionem
/obj/effect/anomaly/tvstatic/planetary/Initialize(mapload, new_lifespan)
	. = ..()
	if(stored_mob || !prob(25))
		return
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/list/before = list()
	for(var/mob/living/carbon/human/existing in T)
		before += existing
	new /obj/effect/mob_spawn/human/corpse/damaged/legioninfested(T)
	for(var/mob/living/carbon/human/victim in T)
		if(!(victim in before))
			store_mob(victim)
			break

/// Kwantowa czarna skrzynka: nieruchomy, wieczny szum w kształcie czarnej kostki (ruiny)
/obj/effect/anomaly/tvstatic/blackbox
	name = "kwantowa czarna skrzynka"
	desc = "Czasem coś trafia w niewłaściwe miejsce: odpad z miejsca, które tak naprawdę nie istnieje. To jedna z takich rzeczy."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackcube"
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/tvstatic

/obj/item/assembly/signaler/anomaly/tvstatic
	name = "\improper rdzeń anomalii szumu"
	desc = "Zneutralizowany rdzeń anomalii szumu. Od samego patrzenia boli głowa. Pewnie przydałby się do badań."
	color = "#c8c8c8"

/// Kłębek szumu: mignięcie z trzaskiem radia
/obj/effect/particle_effect/staticball
	name = "kłębek szumu"
	desc = "Niepokojąca masa unoszącego się w powietrzu szumu."
	icon = 'aquila/icons/planets/anomalies.dmi'
	icon_state = "static"

/obj/effect/particle_effect/staticball/Initialize(mapload)
	. = ..()
	flick(icon_state, src)
	playsound(src, 'aquila/sound/effects/anomaly/walkietalkie.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	QDEL_IN(src, 2 SECONDS)
