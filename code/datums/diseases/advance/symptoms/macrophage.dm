/datum/symptom/macrophage
	name = "Makrofag"
	desc = "Wirus rośnie w nosicielu, przestając być mikroskopijny i wyrządzając poważne szkody w ciele. Te fagi szukają, atakują i zarażają kolejnych odpowiednich nosicieli"
	stealth = -4
	resistance = 1
	stage_speed = -2
	transmission = 2
	level = 9
	severity = 2
	symptom_delay_min = 30
	symptom_delay_max = 60
	prefixes = list("Ambulant ", "Macro")
	bodies = list("Phage")
	var/gigagerms = FALSE
	var/netspeed = 0
	var/phagecounter = 10
	threshold_desc = "<b>Szybkość stadiów:</b> im wyższa szybkość stadiów, tym częściej fagi wyrywają się z nosiciela.<br>\
                      <b>Odporność:</b> im wyższa odporność, tym więcej zdrowia mają fagi i tym większe zadają obrażenia.<br>\
					  <b>Transmisja 10:</b> fagi mogą być większe, bardziej agresywne i z pewnym wysiłkiem przebijać grube ubrania.<br>\
                      <b>Transmisja 12:</b> fagi przenoszą wszystkie choroby nosiciela, a nie tylko te z ich własnym symptomem"



/datum/symptom/macrophage/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 10)
		severity += 2

/datum/symptom/macrophage/Start(datum/disease/advance/A)
	if(!..())
		return
	netspeed = max(1, A.stage_rate)
	if(A.transmission >= 10)
		gigagerms = TRUE

/datum/symptom/macrophage/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1-3)
			to_chat(M, "<span class='notice'>Ciarki przechodzą ci po skórze.</span>")
		if(4)
			M.visible_message("<span class='danger'>Na skórze [M] pojawiają się guzy!</span>", \
								  "<span class='userdanger'>Krzywisz się z bólu, gdy na twojej skórze pojawiają się i przesuwają guzy!</span>")
		if(5)
			phagecounter -= max(2, A.stage_rate)
			if(gigagerms && phagecounter <= 0) //only ever spawn one big germ
				Burst(A, M, TRUE)
				phagecounter += 10
			while(phagecounter <= 0)
				phagecounter += 5
				Burst(A, M)

/datum/symptom/macrophage/proc/Burst(datum/disease/advance/A, var/mob/living/M, var/gigagerms = FALSE)
	var/mob/living/simple_animal/hostile/macrophage/phage
	if(gigagerms)
		phage = new /mob/living/simple_animal/hostile/macrophage/aggro(M.loc)
		phage.melee_damage = max(5, A.resistance)
		M.apply_damage(rand(10, 20))
		playsound(M, 'sound/effects/splat.ogg', 50, 1)
		M.emote("scream")
	else
		phage = new(M.loc)
		M.apply_damage(rand(1, 7))
	phage.health += A.resistance
	phage.maxHealth += A.resistance
	phage.infections += A
	phage.basedisease = A
	if(A.transmission >= 12)
		for(var/datum/disease/D in M.diseases)
			if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS) || (D.spread_flags & DISEASE_SPREAD_FALTERED))
				continue
			if(D == A)
				continue
			phage.infections += D
	phage.InitializeSkin()//AQ EDIT
	M.visible_message("<span class='danger'>Z [M] wyrywa się dziwne stworzenie!</span>", \
	  "<span class='userdanger'>Z twojego ciała wyrywa się oślizgłe stworzenie!</span>")
	addtimer(CALLBACK(phage, TYPE_PROC_REF(/mob/living/simple_animal/hostile/macrophage, shrivel)), 3000)
