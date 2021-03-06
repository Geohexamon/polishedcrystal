	db MAROWAK ; 105

if DEF(FAITHFUL)
	db  60,  80, 110,  45,  50,  80
	;   hp  atk  def  spd  sat  sdf
else
	db  60,  80, 110,  70,  50,  80
	;   hp  atk  def  spd  sat  sdf
endc

	db GROUND, GROUND
	db 75 ; catch rate
if DEF(FAITHFUL)
	db 124 ; base exp
else
	db 140 ; base exp
endc
	db NO_ITEM ; item 1
	db THICK_CLUB ; item 2
	db 127 ; gender
	db 100 ; unknown
	db 20 ; step cycles to hatch
	db 5 ; unknown
	dn 6, 6 ; frontpic dimensions
	db 0, 0, 0, 0 ; padding
	db MEDIUM_FAST ; growth rate
	dn MONSTER, MONSTER ; egg groups

	; tmhm
	tmhm DYNAMICPUNCH, CURSE, TOXIC, SWORDS_DANCE, HIDDEN_POWER, SUNNY_DAY, ICY_WIND, ICE_BEAM, BLIZZARD, HYPER_BEAM, PROTECT, IRON_TAIL, EARTHQUAKE, RETURN, DIG, MUD_SLAP, DOUBLE_TEAM, SWAGGER, FLAMETHROWER, SANDSTORM, FIRE_BLAST, STONE_EDGE, REST, ATTRACT, THIEF, BODY_SLAM, ROCK_SLIDE, FURY_CUTTER, SUBSTITUTE, FOCUS_BLAST, FALSE_SWIPE, ENDURE, SHADOW_CLAW, STRENGTH, ROCK_SMASH, COUNTER, DOUBLE_EDGE, EARTH_POWER, FIRE_PUNCH, HEADBUTT, ICE_PUNCH, IRON_HEAD, SEISMIC_TOSS, SLEEP_TALK, THUNDERPUNCH
	; end
