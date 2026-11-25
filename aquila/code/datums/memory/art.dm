/**
 * Element oceny dzieła sztuki z tg (code/datums/elements/art.dm), potrzebny rycinom i tatuażom.
 * Kto obejrzy dzieło, przez 2 sekundy mu się przygląda i dostaje nastrój zależny od jego klasy.
 * Nastroje artgreat / artgood / artok / artbad już mamy (generic_*_events.dm).
 */
/datum/element/art
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2
	var/impressiveness = 0
	/// AQUILA: zamiast DOING_INTERACTION_WITH_TARGET z tg (u nas brak), żeby jedno oglądanie nie odpalało kilku ocen
	var/list/appraising = list()

/datum/element/art/Attach(datum/target, impress)
	. = ..()
	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE
	impressiveness = impress
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/element/art/Detach(datum/target)
	UnregisterSignal(target, COMSIG_PARENT_EXAMINE)
	return ..()

/datum/element/art/proc/apply_moodlet(atom/source, mob/living/user, impress)
	var/msg
	switch(impress)
		if(GREAT_ART to INFINITY)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "artgreat", /datum/mood_event/artgreat)
			msg = "Co za [pick("arcydzieło", "majstersztyk")]. [pick("Wzniosłe", "Porywające", "Urzekające", "Nieskazitelne")]!"
		if(GOOD_ART to GREAT_ART)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "artgood", /datum/mood_event/artgood)
			msg = "To [pick("solidne", "godne uznania", "chwalebne")] dzieło, miłe dla wprawnego oka."
		if(BAD_ART to GOOD_ART)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "artok", /datum/mood_event/artok)
			msg = "Przeciętne, ale da się to nazwać „dziełem sztuki”."
		if(-INFINITY to BAD_ART)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "artbad", /datum/mood_event/artbad)
			msg = "Ojej, to jest okropne."

	user.visible_message("<span class='notice'>[user] przystaje i uważnie przygląda się: [source].</span>", \
		"<span class='notice'>Oceniasz dzieło ([source])... [msg]</span>")

/datum/element/art/proc/on_examine(atom/source, mob/user, list/examine_texts)
	SIGNAL_HANDLER
	if(!isliving(user) || (REF(user) in appraising))
		return
	INVOKE_ASYNC(src, PROC_REF(appraise), source, user) //Do not sleep the proc.

/datum/element/art/proc/appraise(atom/source, mob/user)
	var/user_ref = REF(user)
	appraising += user_ref
	to_chat(user, "<span class='notice'>Zaczynasz oceniać dzieło ([source])...</span>")
	var/success = do_after(user, 2 SECONDS, target = source)
	appraising -= user_ref
	if(!success)
		return
	var/mult = 1
	if(isobj(source))
		var/obj/art_object = source
		if(art_object.max_integrity)
			mult = art_object.obj_integrity / art_object.max_integrity
	apply_moodlet(source, user, impressiveness * mult)

/// Sztuka ludu (tatuaże): zachwyca wszystkich poza dowództwem, ochroną i kwatermistrzem
/datum/element/art/commoner

/datum/element/art/commoner/apply_moodlet(atom/source, mob/living/user, impress)
	var/msg
	var/list/haters = GLOB.command_positions + GLOB.security_positions + JOB_NAME_QUARTERMASTER

	if(!(user.mind?.assigned_role in haters))
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "artgreat", /datum/mood_event/artgreat)
		msg = "Co za [pick("arcydzieło", "majstersztyk")]. Takie [pick("bliskie sercu", "przyziemne", "prawdziwe", "szczere")]!"
	else
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "artbad", /datum/mood_event/artbad)
		msg = "Ojej, to jest okropne."

	user.visible_message("<span class='notice'>[user] przystaje i przygląda się: [source].</span>", \
		"<span class='notice'>Oceniasz dzieło ([source]), podziwiając kunszt proletariatu... [msg]</span>")
