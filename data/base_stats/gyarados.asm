	db GYARADOS ; 130

	db  95, 125,  79,  81,  60, 100
	;   hp  atk  def  spd  sat  sdf

	db WATER, FLYING
	db 45 ; catch rate
	db 214 ; base exp
	db NO_ITEM ; item 1
	db NO_ITEM ; item 2
	db 127 ; gender
	db 100 ; unknown
	db 5 ; step cycles to hatch
	db 5 ; unknown
	dn 7, 7 ; frontpic dimensions
	db 0, 0, 0, 0 ; padding
	db SLOW ; growth rate
	dn FISH, REPTILE ; egg groups

	; tmhm
	tmhm CURSE, ROAR, TOXIC, HIDDEN_POWER, ICY_WIND, ICE_BEAM, BLIZZARD, HYPER_BEAM, PROTECT, RAIN_DANCE, DRAGONBREATH, IRON_TAIL, THUNDERBOLT, THUNDER, EARTHQUAKE, RETURN, DOUBLE_TEAM, SWAGGER, FLAMETHROWER, SANDSTORM, FIRE_BLAST, STONE_EDGE, AVALANCHE, REST, ATTRACT, BODY_SLAM, SUBSTITUTE, SCALD, DARK_PULSE, ENDURE, DRAGON_PULSE, THUNDER_WAVE, FLY, SURF, STRENGTH, WHIRLPOOL, WATERFALL, ROCK_SMASH, AQUA_TAIL, DOUBLE_EDGE, HEADBUTT, IRON_HEAD, SLEEP_TALK, ZAP_CANNON
	; end
