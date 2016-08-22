## Use or remove

* Use EMOTE_QUESTION, EMOTE_HAPPY, EMOTE_SAD, and EMOTE_SLEEP somewhere
* Use or remove SPRITE_OLD_LINK_RECEPTIONIST
* Phase out SPRITE_MONSTER, SPRITE_FAIRY, SPRITE_BIRD, and SPRITE_DRAGON

## Bugs

* Move Reminder doesn't list all possible moves
* Thief permanently steals held items
* TMs refresh PP
* Lance uses X Spcl. Atk (a more general AI bug?)
* Thick Club + Swords Dance Marowak Attack overflow (only in link battles?)
* Fix delay before last text box when Wonder Trading (is this still there?)
* Headbutt animation looks weird (wrong tile ID?)
* Protect prints (sometimes?) "X is protecting itself! Y's attack missed!"
* Dig sometimes prints that both Pokémon dug a hole
* Per-turn status animations might not always work
* Sleep lasts [2–4 turns](https://github.com/roukaour/pokecrystal/commit/252817539482c1fc3fe8dd24c484a74234a0b89a#commitcomment-18349313)?


## Battle mechanics

* http://smogon.site/forums/threads/gsc-mechanics.3542417/
* Gen III critical hit mechanics (ignore -Atk and +Def stat changes, don't ignore burn)
* Defrosted Pokémon can attack on that turn (like waking up)
* Substitute does not block sound-based moves
* Substitute prevents building Rage
* Drain Kiss drains 75% HP
* Avalanche doubles damage if user is hit first
* Hurricane cannot miss in rain
* Low Kick's power is based on weight
* Thunder ignores accuracy and evasion in rain
* Rock-type Pokémon get Sp.Def boosted by 50% in a sandstorm
* Grass-type Pokémon are immune to PoisonPowder, Stun Spore, Sleep Powder, and Spore
* Ghost-type Pokémon are immune to the trapping effects of Mean Look, Clamp, Fire Spin, Whirlpool, and Wrap
* Rock Smash breaks screens instead of lowering Defense (like Brick Break) (non-faithful)


## Other mechanics

* Catch rate formula from Gen III
* Show stat changes and then absolute values on level up
* Brief beeping with low HP
* Healing items activate at 1/3 HP, not 1/2 (edit HandleHPHealingItem)
* Gold Berry heals 25% HP even in battle (edit ConsumeHeldItem)
* Select reorders Pokémon in party menu
* Send gift Pokémon to the PC if the party is full
* More frequently successful Headbutting (edit Script_respawn_one_offs)
* More likely to find roaming Pokémon when on the correct route
* Give female trainers better DVs, and use the new unique DVs feature to make certain Pokémon female


## Aesthetic updates

* Animate new Pokémon sprites
* Design custom animations for new moves
* Show Pokémon portraits when using field moves
* Better Substitute sprites
* Color party/day-care sprites by species
* Special sprites for Pikachu that know Surf or Fly
* Yellow Pikachu Surfing music
* Big roofs like Pewter Museum on Silph Co. and Pokémon Tower
* Goldenrod Dept.Store and Celadon Mansion roofs should have dark sky at night
* Add umbrellas to Olivine City benches
* Merge gray and roof colors on Faraway Island to make room for another green


## New content

* Use Mmmmmm's B/W Route 12 music for a new location
* Extend Lugia's chamber with flute music
* Use some of Soloo93's HG/SS Gym Leader [sprite devamps](https://hax.iimarck.us/post/36679/#p36679)?
* Use Mateo's X/Y Hex Maniac sprite devamp (or make an X/Y one)?
* Add wild Pokémon to Navel Rock?
* Battle with Tower Tycoon Palmer as the last battle of every 5th and 10th 7-battle set in the Battle Tower
* Battle with Giovanni either in Radio Tower or with Celebi time traveling
* Battle with Cynthia in the Sinjoh Ruins after catching all 26 Unown (reward: Expert Belt)
* Battle with Steven in the Embedded Tower (reward: Muscle Band)
* Battle Caitlin and Darach somewhere, possibly around the Battle Tower (reward: ?)
* Battle with [Shigeki Morimoto](http://bulbapedia.bulbagarden.net/wiki/Shigeki_Morimoto) (game designer and programmer), [Kōji Nishino](http://bulbapedia.bulbagarden.net/wiki/K%C5%8Dji_Nishino) (planner), [Tsunekazu Ishihara](https://tcrf.net/Pok%C3%A9mon_Red_and_Blue#Deleted_Maps) (president and CEO), and/or Satoshi Tajiri (creator) in Celadon Mansion once a day
* Battle [En and Madoka](http://bulbapedia.bulbagarden.net/wiki/The_Legendary_Rotation_Battle!) somewhere (Mt. Quena, after completing the Pokédex?)


## New features

* Add an event based on the Spell of the Unown movie after you catch all 26
* Fourth stat screen showing Poké Seer's data
* Restore [unused memory game](http://iimarck.us/i/memory/)
* Add [Sweet Honey trees](http://iimarck.us/i/sweet-honey/) for Munchlax (replace Sweet Scent)
* Pickup ability for Meowth, Teddiursa, and/or Phanpy
* Use the News Machine for something (Mystery Gift?)
* Optional Locke mode where fainted Pokémon cannot be revived (Max/Revive, Revival Herb, and Sacred Ash still fix HP and status so they aren't useless)
* Restore the Safari Game (some functionality, like HandleSafariAngerEatingStatus, already exists)
* Add a store to buy room decorations that Mom doesn't (the Goldenrod Dept. Store rooftop bargain sale and the harbor are good)
* Sometimes wild Pokémon know an egg move
* Longer player and rival names
* More Bag pockets (split Items into Items, Medicine, and Berries)
* Press Start to auto-sort items
* Add a third Trainer Card page for Kanto badges
* Adjust Kanto trainers' levels closer to Gym Leaders
