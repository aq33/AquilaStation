// AQUILA - gotowanie krok po kroku. Silnik na wzór ParaCooking With Jane z Paradise (ParadiseSS13/Paradise,
// code/modules/cooking; to z kolei przeróbka Cooking with Jane z Sojourna i CEV-Eris), napisany pod nasze
// maszyny: kuchenkę z zupami tg, piekarnik, grill i frytkownicę. Różnice względem Paradise: czas gotowania liczony
// w process() (z mocą maszyny), bez stopera; przypalanie liczone od chwili, gdy na ogniu nic się nie gotuje;
// jakość dania z kroków zamiast liczby porcji; krok narzędzia (nóż, wałek) z Cooking with Jane.

/// Używany przedmiot nie pasuje do żadnego kroku
#define COOK_NO_STEPS 1
/// Krok wykonany
#define COOK_SUCCESS 3
/// Przedmiot użyty, ale krok jeszcze niespełniony (np. za mało odczynnika)
#define COOK_PARTIAL_SUCCESS 4
/// Danie gotowe
#define COOK_COMPLETE 5
/// Naczynie zajęte czymś, co nie należy do przepisu
#define COOK_CONTAINER_FULL 9

#define COOK_CHECK_INVALID 0
#define COOK_CHECK_VALID 1
#define COOK_CHECK_FULL 2
/// Pasuje, ale bez komunikatu (krok maszyny)
#define COOK_CHECK_SILENT 3

#define COOK_TEMP_LOW "low"
#define COOK_TEMP_MED "medium"
#define COOK_TEMP_HIGH "high"

/// Mnożnik szybkości zwykłego pieczenia i grzania zup przy danym ogniu
#define COOK_TEMP_SPEED(temp) ((temp) == COOK_TEMP_LOW ? 0.5 : ((temp) == COOK_TEMP_HIGH ? 1.5 : 1))

#define COOKER_STOVE "stove"
#define COOKER_OVEN "oven"
#define COOKER_GRILL "grill"
#define COOKER_FRYER "fryer"
#define COOKER_ICE_CREAM "ice_cream"

/// Po tylu sekundach na ogniu bez postępu danie się przypala
#define COOK_BURN_TIME_LOW (60 SECONDS)
#define COOK_BURN_TIME_MED (45 SECONDS)
#define COOK_BURN_TIME_HIGH (30 SECONDS)

/// Czas rozgrzania sprzętu kuchennego przy laserze 1. poziomu (przy 4. poziomie: 1/4 tego)
#define KITCHEN_WARMUP_TIME (20 SECONDS)
/// Najmniejsza szybkość gotowania na zimnej maszynie (gotowanie rusza od razu, tylko wolniej)
#define KITCHEN_COLD_SPEED 0.25

/// Wysyłane na naczynie, gdy maszyna skończyła krok przepisu
#define COMSIG_COOK_MACHINE_STEP_COMPLETE "cook_machine_step_complete"

#define COOK_ADD_ITEM(item_type, options...) new /datum/cooking/recipe_step/add_item(item_type, list(##options))
#define COOK_ADD_PRODUCE(produce_type, options...) new /datum/cooking/recipe_step/add_produce(produce_type, list(##options))
#define COOK_ADD_REAGENT(reagent_type, amount, options...) new /datum/cooking/recipe_step/add_reagent(reagent_type, amount, list(##options))
#define COOK_USE_TOOL(tool, options...) new /datum/cooking/recipe_step/use_tool(tool, list(##options))
#define COOK_USE_STOVE(temperature, time, options...) new /datum/cooking/recipe_step/use_machine/stove(temperature, time, list(##options))
#define COOK_USE_OVEN(temperature, time, options...) new /datum/cooking/recipe_step/use_machine/oven(temperature, time, list(##options))
#define COOK_USE_GRILL(time, options...) new /datum/cooking/recipe_step/use_machine/grill(COOK_TEMP_MED, time, list(##options))
#define COOK_USE_FRYER(time, options...) new /datum/cooking/recipe_step/use_machine/fryer(COOK_TEMP_MED, time, list(##options))
#define COOK_USE_ICE_CREAM(time, options...) new /datum/cooking/recipe_step/use_machine/ice_cream(COOK_TEMP_MED, time, list(##options))
#define COOK_ADD_LIMB(limb_ids, options...) new /datum/cooking/recipe_step/add_item/limb(limb_ids, list(##options))
#define COOK_ADD_ROBOTIC_LIMB(options...) new /datum/cooking/recipe_step/add_item/limb/robotic(null, list(##options))

/// Kategorie przepisów krokowych w Książce kucharskiej
#define COOK_CATEGORY_MISC "Różne"
#define COOK_CATEGORY_MEAT "Mięsa"
#define COOK_CATEGORY_DESSERTS "Desery"
#define COOK_CATEGORY_BREAD "Pieczywo"
#define COOK_CATEGORY_BREAKFAST "Śniadania"
#define COOK_CATEGORY_SEAFOOD "Ryby i owoce morza"
#define COOK_CATEGORY_PASTA "Makarony i kluski"
#define COOK_CATEGORY_SIDES "Dodatki"
#define COOK_CATEGORY_VEGE "Dania wegetariańskie"
#define COOK_CATEGORY_POLISH "Kuchnia polska"
#define COOK_CATEGORY_BURGERS "Burgery"
#define COOK_CATEGORY_CANDY "Słodycze"
#define COOK_CATEGORY_DONUTS "Pączki"
#define COOK_CATEGORY_PIZZA "Pizze"
#define COOK_CATEGORY_SALADS "Sałatki"
#define COOK_CATEGORY_SUSHI "Sushi"

/// Nazwa ognia w zdaniu „na X ogniu”
/proc/cook_temp_adjective(temp)
	switch(temp)
		if(COOK_TEMP_LOW)
			return "niskim"
		if(COOK_TEMP_HIGH)
			return "wysokim"
	return "średnim"

/// Nazwa ognia do menu
/proc/cook_temp_name(temp)
	switch(temp)
		if(COOK_TEMP_LOW)
			return "niski"
		if(COOK_TEMP_HIGH)
			return "wysoki"
	return "średni"

/proc/cook_burn_time(temp)
	switch(temp)
		if(COOK_TEMP_LOW)
			return COOK_BURN_TIME_LOW
		if(COOK_TEMP_HIGH)
			return COOK_BURN_TIME_HIGH
	return COOK_BURN_TIME_MED
