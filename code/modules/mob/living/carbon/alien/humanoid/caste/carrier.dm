/mob/living/carbon/alien/humanoid/carrier
	name = "alien carrier"
	caste = "Drone"
	maxHealth = 200
	health = 200
	storedPlasma = 50
	max_plasma = 50
	icon_state = "Drone Walking"
	plasma_rate = 5
	heal_rate = 2
	var/facehuggers = 0
	var/usedthrow = 0
	color = "#967d00"
	damagemin = 20
	damagemax = 30
	tacklemin = 2
	tacklemax = 4
	tackle_chance = 60 //Should not be above 100%
	var/THROWSPEED = 2
	psychiccost = 32

/mob/living/carbon/alien/humanoid/carrier/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien carrier")
		name = text("alien carrier ([rand(1, 1000)])")
	real_name = name
	var/matrix/M = matrix()
	M.Scale(1.1,1.15)
	src.transform = M
	pixel_y = 3
	verbs -= /mob/living/carbon/alien/verb/ventcrawl
	verbs -= /atom/movable/verb/pull
	..()

/mob/living/carbon/alien/humanoid/carrier/Stat()

	..()

	if (client.statpanel == "Status")
		stat(null, "Facehuggers Stored: [facehuggers]/6")

/mob/living/carbon/alien/humanoid/carrier/Life()
	..()

	if(usedthrow < 0)
		usedthrow = 0
	else if(usedthrow > 0)
		usedthrow--

/mob/living/carbon/alien/humanoid/carrier/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] || modifiers["shift"])
		if(facehuggers > 0)
			throw_hugger(A)
		else
			..()
		return
	..()

/mob/living/carbon/alien/humanoid/carrier/verb/throw_hugger(var/mob/living/carbon/human/T)
	set name = "Throw Facehugger"
	set desc = "Throw one of your facehuggers"
	set category = "Alien"
	if(health < 0)
		src << "\red You can't throw huggers when unconcious."
		return
	if (stat == 2)
		src << "\red You can't throw huggers when dead."
		return
	if(facehuggers <= 0)
		src << "\red You don't have any facehuggers to throw!"
		return
	if(usedthrow <= 0)
		if(!T)
			var/list/victims = list()
			for(var/mob/living/carbon/human/C in oview(7))
				victims += C
			T = input(src, "Who should you throw at?") as null|anything in victims

		if(T)
			var/obj/item/clothing/mask/facehugger/throw = new()
			facehuggers -= 1
			usedthrow = 1
			throw.loc = src.loc
			throw.throw_at(T, 5, THROWSPEED)
			src << "We throw a facehugger at [throw]"
			visible_message("\red <B>[src] throws something towards [T]!</B>")

		else
			src << "\blue You cannot throw at nothing!"
	else
		src << "\red You need to wait before throwing again!"


/mob/living/carbon/alien/humanoid/carrier/handle_regular_hud_updates()

	..() //-Yvarov

	var/HP = (health/maxHealth)*100

	if (healths)
		if (stat != 2)
			switch(HP)
				if(80 to INFINITY)
					healths.icon_state = "health0"
				if(60 to 80)
					healths.icon_state = "health1"
				if(40 to 60)
					healths.icon_state = "health2"
				if(20 to 40)
					healths.icon_state = "health3"
				if(0 to 20)
					healths.icon_state = "health4"
				else
					healths.icon_state = "health5"
		else
			healths.icon_state = "health6"


/mob/living/carbon/alien/humanoid/carrier/handle_environment()
	if(m_intent == "run" || resting)
		..()
	else
		adjustToxLoss(-heal_rate)
