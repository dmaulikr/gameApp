# Island Escape: Game Design Document
---
## Table of Contents
* [Game Design: Features and Elements] (#chapter-1)
* [Gameplay: Components] (#chapter-2)
* [Gameplay: Mechanics] (#chapter-3)
* [Technical] (#chapter-4)

<a id="chapter-1"></a> 
## Game Design: Features and Elements
### Key Features
* **Number of Levels:** 1 for this implementation
* **Level Time Constraint:** 20 Minutes
* **Number of Enemies:** 6 Distinct types of enemies
* **Number of Players:** 1-2 Players 
* **Time of Gameplay:** Infinite gameplay
* **Replayability:** Randomized location of resources, escape vehicle
* **Audio Specifications:** Sound effects only
* **Graphics Specifications:** 3D
* **Device Compatibility:** Game written for Mac OS X with iOS devices used as controllers (virtual joysticks/trackpads)
* **Modes:** Single and Multi-player
* **Multiplayer Mode:** Cooperative or Competitive

-
### Player Experience Goals

* **Race-to-the-End:** Player must escape from the given map in a set period of time (or before the other player if in multi-player mode and playing competitively) 
* **Advancement:** The more the player plays the game, the more "survival skills" the player can build
* **Exploration:** Player will need to explore the premises in order to escape the game
* **Conflict:** Combat with the NPCs or the other player if playing competitively in multiplayer mode
* **Collection:** Player must find (and/or collect) the necessary fixes for the helicopter before they can escape
* **Escape:** Player must ultimately escape from the given map 

-
### Definitions
#### Winning and Losing:
* **How to Win:** Successfully escape from the given level
* **How to Lose:** Fail to escape from the given level in the set amount of time or Die

#### Screens
##### OS X Game App
1. Title Screen
2. Mode Choice: Single-Player or Multi-Player
	* Single-Player
		* Pair Controller 
			* Choose Character
	* Multi-Player
		* Pair Controllers
			* Choose Characters  
			* Choose Mode: Coop vs Competitive
4. Game
	* Inventory
	* Menu	
5. End Credits	    

##### iOS Controller App
1. Title Screen
	* View Skills
	* OS X Pairing Screen
2. Controller

-
### Procedures
#### Starting: How the Game is put into play
* You find yourself waking up on the beach area of the island
* You find out that you need to find the helicopter to escape the island

#### Progression: Ongoing procedures running during gameplay
* You must avoid and/or defeat hostile NPCs while trying to find the helicopter
* After the helicopter is discovered, the player must find the repair materials necessary to fix it before it is usable

#### Special: Actions only available based on other elements
* Once the player has all of the necessary repair materials and they return to the helicopter, they are able to "repair" it

#### Resolving: These actions bring your game to an end
* Once the player (or players) repairs the helicopter, the game ends

-
### General Rules
* Players are only allowed to carry two weapons at a time: One equipped, one extra
* There must always be one NPC guarding the helicopter, and they are able to alert other NPCs 
* Helicopter must first be fixed
* Only 2 versions of every weapon available on the island, but other weapons can be looted from the grounders
* Once you lose life, you end up moving more slowly since you are injured
* Toolbox (necessary repair materials) must always be guarded by one Combat Android
* In multi-player mode, players first have to choose the mode: Coop vs Competitive
* Additional weapons add to the player's damage abilities (so if player starts with 5 damage and has a 20 damage weapon, their damage abilities = 25)

#### Bonus Challenges/Quests
* Stealth Victory
	* Pass the level completely undetected
	* No kills
	* Stealth kills only
* Combat Victory
	* Kill Bird
	* Kill Copperhead
	* Kill Dark Predator
	* Melee Weapons Only
* Save Ellie (Captured)  

-
### Point System
Maximum Possible Points: 100
#### Single-Player
**Positive Bonus** | Points	  |
:-----------------:|:----------:|
Successfull Mission|	+ 40     |
Player Uninjured	  |		+ 30	  |
**Negative Bonus** |  **-**	  |

####Multi-Player
##### Coop
**Positive Bonus** | Points	|
:------------------:|:--------:|
Successfull Mission|   + 40   |
One Uninjured		  |		+ 15   |
Both Uninjured	  |		+ 30   |
**Negative Bonus** |    **-** |
Partner Dead       |	- 50   |

##### Competitive
**Positive Bonus**  | Points	|
:------------------:|:--------:|
Successfull Mission |   + 40   |
Uninjured    		   |	+ 15   |
Second Player Alive	|	+ 10   |
**Negative Bonus** |    **-** |
Partner Dead       |	- 50   |

<a id="chapter-2"></a>
## Gameplay: Components 
### Inventory
#### Weapons
##### Melee
Weapon				| Type			 | Owner      | Quantity 
:---------------:|:-----------:|:----------:|:--------:
Knife				| Melee		 |	Island	    | 8        
Machete			| Melee		 | Island     | 5        
Hatchet			| Melee       | Island	    | 3        
Battle-axe		| Melee       | Predator   | Each     
Handgun        	| Short-range | Island     | 3 / 5    
Flamethrower     | Short-range | Island     | 1        
Dragunov	       | Long-range  | Island     | 1        
Rifle            | Long-range  | Android    | Each + 2 
Bomb             | Explosive   | Island     | 2        

#### Misc
Object				| Type			| Bonus/Use
:--------------:|:-----------:|:-----------:
Mushroom			| Health		| +10 Health
Toolbox			| Mission		| Fix Helicopter
Ammo				| Combat		| Reload
Rock				| Stealth		| Distract NPCs
 

-
### Player Elements
#### Character Options
##### Carter Bell
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/carter-bell.jpg" style="width: 300px"/>  
##### Gary Friedman
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/garry-friedman.jpg" style="width: 300px"/>
##### Jennifer
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/jennifer.jpg" style="width: 300px"/>
##### Sheva Alomar
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/sheva-alomar.jpg" style="width: 300px"/>

#### Player Properties
##### Dynamic
* Health
* Stamina
* Damage
* Inventory 
* Skills (?)
	* Combat
		* Hand-to-Hand
		* Melee
		* Short-range
		* Long-range
	* Stealth
	* Engineering
* Game Points

##### Static
* Speed
* Jump Height

#### Player Definitions
##### Actions
* Jog: Forward, Backward, Strafe Left, Strafe Right
* Run/Sprint: Forward, Backward, Strafe Left, Strafe Right
* Interact: Pick up items
* Jump
* Crouch (Stealth Mode)
* Combat
	* Attack
	* Defend ?

##### Information (Status)
###### Explicit:
* Own camera view
* Health
* Stamina (?)
* Damage Potential
* Enemy Health
* Time Left
* Currently Equipped Item
* Inventory 

###### Implicit:
* Second player's view if playing in multiplayer mode
* Set map information if played before

##### Heads up Display
* "Pick up object"
* "Detected" - Stealth Meter
* Introductory Tutorial
* Story Explanation (Captions on a black screen?..)

##### Default Properties
* **Health:** 100 points
* **Stamina:** 100 points
* **Base Damage:** 5 points
* **Inventory:** Empty
* **Game Points:** 0

#### Player Rewards
##### Objects that benefit player in a positive way

-
### Antagonistic Elements
#### Bird
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/bird.jpg" style="width: 300px"/>
##### Quantity: 1

##### Properties
* **Health:** 150
* **Damage:** 15
* **Weapon:**
* **Actions:**

##### AI Behavior
* **Normal State:** Roaming around (in set radius?)
* **Detection State:** Player has to be within visual range
* **Reaction State:** Hostile - Attacks player & calls for backup
* **End State:**

#### CopperHead
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/copperhead.jpg" style="width: 300px"/>
##### Quantity: 1

##### Properties
* **Health:** 130
* **Damage:** 12
* **Weapon:** 
* **Actions:**

##### AI Behavior
* **Normal State:**
* **Detection State:**
* **Reaction State:** Hostile - Attacks player & calls for backup
* **End State:**

#### Predator Dark
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/predator-dark.jpg" style="width: 300px"/>
##### Quantity: 1

##### Properties
* **Health:** 300 points
* **Damage:** 30 points
* **Weapon:** Battleaxe
* **Actions:**

##### AI Behavior
* **Normal State:** Following Bird
* **Detection State:** Player has to be within visual range
* **Reaction State:** Hostile - Attacks player & calls for backup
* **End State:**

#### Combat Android
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/combat-android.jpg" style="width: 300px"/>
##### Quantity: >= 10 

##### Properties
* **Health:** 100 points
* **Damage:** 20 points
* **Weapon:** Rifle
* **Actions:**

##### AI Behavior
* **Normal State:**
* **Detection State:**
* **Reaction State:** Hostile - Attacks player
* **End State:**

#### Lambent Female
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/lambent-female.jpg" style="width: 300px"/>
##### Quantity: >= 10 

##### Properties
* **Health:** 70 points
* **Damage:** 8 points
* **Weapon:** None (Hands)
* **Actions:**

##### AI Behavior
* **Normal State:** Roaming around
* **Detection State:**
* **Reaction State:** Hostile - Attacks player
* **End State:**

#### Lambent Male
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/lambent-male.jpg" style="width: 300px"/>
##### Quantity: >= 10 

##### Properties
* **Health:** 70 points
* **Damage:** 8 points
* **Weapon:** None (Hands)
* **Actions:**

##### AI Behavior
* **Normal State:** Roaming around
* **Detection State:**
* **Reaction State:** Hostile - Attacks player
* **End State:**

-
### Misc NPCs - Environment
#### Brown Bear
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/brown-bear.jpg" style="width: 300px"/>
##### Quantity: 1-3

##### Properties
* **Health:** 250 points
* **Damage:** 30 points

##### AI Behavior
* **Normal State:** Roaming around
* **Detection State:** Player has to be within visual range
* **Reaction State:** Hostile - Attacks player
* **End State:**
	* If player attacks back and kills it: Dead
	* If player attacks back and gets killed: Continue roaming around
	* If player starts running away: Chase after player
	* If player escapes from within visual range: Continue roaming around

#### Dog
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/dog.jpg" style="width: 300px"/>
##### Quantity: 5-10

##### Properties
* **Health:** 20 points
* **Damage:** 2 points

##### AI Behavior
* **Normal State:** Roaming around
* **Detection State:** Player has to be within visual range
* **Reaction State:** Non-Hostile - Just slowly approach player
* **End State:**
	* If player attacks it upon approaching: Attack back
	* If player attacks and starts running away: Chase after player 
	* If player does not attack: Go back to roaming around

#### Female Elk
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/elk-f.jpg" style="width: 300px"/>
##### Quantity: 1-5

##### Properties
* **Health:** 40 points
* **Damage:** 8 points

##### AI Behavior
* **Normal State:** Roaming around
* **Detection State:** Player has to be within visual range
* **Reaction State:** Non-Hostile - start running away if player gets too close
* **End State:** 
	* If player attacks it: Attack back
	* If player attacks and starts running away: Chase after player
	* If player does not attack: Continue roaming around 

#### Male Elk
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/elk-m.jpg" style="width: 300px"/>
##### Quantity 1-5

##### Properties
* **Health:** 50 points
* **Damage:** 10 points

##### AI Behavior
* **Normal State:** Roaming around
* **Detection State:** Player has to be within visual range
* **Reaction State:** Non-Hostile - start running away if player gets too close
* **End State:**
	* If player attacks it: Attack back
	* If player attacks and starts running away: Chase after player
	* If player does not attack: Continue roaming around

#### Giraffe
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/giraffe.jpg" style="width: 300px"/>
##### Quantity: 1-2

##### Properties
* **Health:** 270 points
* **Damage:** 15 points

##### AI Behavior
* **Normal State:** Roaming around
* **Detection State:** Player has to be within visual range
* **Reaction State:** Non-Hostile - start running away if player gets too close
* **End State:**
	* If player attacks it: Attack back
	* If player attacks and starts running away: Chase after player
	* If player does not attack: Continue roaming around 

#### Goat
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/white-goat.jpg" style="width: 300px"/>
##### Quantity: 5-10

##### Properties
* **Health:** 20
* **Damage:** 4

##### AI Behavior
* **Normal State:** Roaming around
* **Detection State:** Player has to be within visual range
* **Reaction State:** Non-Hostile - ignore player
* **End State:**
	* If player attacks it: Attack back
	* If player attacks and starts running away: Chase after player
	* If player does not attack: Continue roaming around 

#### Ostrich
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/ostrich.jpg" style="width: 300px"/>
##### Quantity: 3-7

##### Properties
* **Health:** 15
* **Damage:** 2

##### AI Behavior
* **Normal State:** Roaming around
* **Detection State:** Player has to be within visual range
* **Reaction State:** Non-Hostile - start running away if player gets too close
* **End State:**
	* If player attacks it: Attack back
	* If player attacks and starts running away: Continue roaming
	* If player does not attack: Continue roaming around

#### Swarm Infector
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/swarm-infector.jpg" style="width: 300px"/>
##### Quantity: 20-30

##### Properties
* **Health:** 10
* **Damage:** 2

##### AI Behavior
* **Normal State:** Roaming around
* **Detection State:** Player has to be within visual range
* **Reaction State:** Hostile - Attack player
* **End State:**
	* If player attacks back and kills it: Dead
	* If player attacks back and gets killed: Continue roaming around
	* If player starts running away: Chase after player
	* If player escapes from within visual range: Continue roaming around

#### Wolf
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/wolf.jpg" style="width: 300px"/>
##### Quantity: 3-5

##### Properties
* **Health:** 150
* **Damage:** 17

##### AI Behavior
* **Normal State:** Roaming around
* **Detection State:** Player has to be within visual range
* **Reaction State:** Hostile - Attack player
* **End State:**
	* If player attacks back and kills it: Dead
	* If player attacks back and gets killed: Continue roaming around
	* If player starts running away: Chase after player
	* If player escapes from within visual range: Continue roaming around

#### Zombie Dog I
<img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Model Images/zombie-dogA.jpg" style="width: 300px"/>
##### Quantity: 5-10

##### Properties
* **Health:** 50
* **Damage:** 12

##### AI Behavior
* **Normal State:** Roaming around
* **Detection State:** Player has to be within visual range
* **Reaction State:** Hostile - Attack player
* **End State:**
	* If player attacks back and kills it: Dead
	* If player attacks back and gets killed: Continue roaming around
	* If player starts running away: Chase after player
	* If player escapes from within visual range: Continue roaming around
  
<a id="chapter-3"></a> 
## Gameplay: Mechanics
### Player Controls
#### Directional Movement
Touch Vector	| Character Response		
:-----------:|:-----------------------------:|
⬆️				| Walk Forward				     |
⬇️				| Walk Backward (no turnaround) | 
⬅️				| Strafe Left					     |
➡️				| Strafe Right				     |
↖️				| Walk Diagonally Top-Left	     |
↗️				| Walk Diagonally Top-Right     |
↙️				| Walk Diagonally Bottom-Left   |
↘️				| Walk Diagonally Bottom-Right  |

#### Additional Movement
Action		| Interaction Type              | Character Response
:--------:|:-----------------------------:|:-----------------:|
Jump		| Double Tap in Camera Trackpad |Jump Straight Up  
Crouch		| Press Crouch Button           |Crouch (Stealth Mode)

#### Combat
* Attack
* Reload (Shaking gesture?)

#### Interaction
* Pick up objects

#### Inventory
* Equip Item
* Drop Item

#### Camera Movement
Touch Vector	| Character Response		
:-----------:|:-----------------------------:|
⬆️				| Look up 					     
⬇️				| Look Down					      
⬅️				| Rotate camera around player to the right to look left
➡️				| Rotate camera around player to the left to look right     
↖️				| Rotate camera to right and look up    
↗️				| Rotate camera to left and look up    
↙️				| Rotate camera to right and look down  
↘️				| Rotate camera to left and look down

#### Additional Control Definitions
* When camera is facing one way and player does the swipe up gesture to move forward

* The "shaking" gesture does something? Replenish stamina? Reload?

-
### iOS UI Components/Buttons
* Directional Movement Controls - *Virtual Joystick/Trackpad*
* Camera View - *Virtual Joystick/Trackpad*
* Jump - *Double Tap Gesture*
* Crouch - *Switch*
* Attack - *Button*
* Interact - *Button*
* Inventory - *Button*

-
### Combat Mechanics
#### Weapons - Generalized
##### Melee
Weapon				| Attack Interval | Damage: PB | 
:---------------:|:---------------:|:----------:|
Unarmed Combat   | 0.5 Seconds     | 10         
Knife				| 0.5 Seconds		  |	 30        
Machete			| 0.8 Seconds      | 40	
Hatchet			| 0.8 Seconds      | 40
Battle-axe       | 1.2 Seconds	  | 60	

##### Ranged
Weapon				| Loaded | Carried | Damage: PB     | Damage: MR       | Damage: LR 
:--------------:|:-------:|:-------:|:--------------:|:----------------:|:-----------:|
Handgun        	| 8      | 36		   | 20-22          | 10-15            | 8-9
Flamethrower     | 200	  | N/A      | 6.82 /particle | 4.09 / particle  | N/A
Dragunov	       | 25	  | N/A      | 50 - 150       |                  |                                   
Rifle            | 25	  | 75       | 8-12 / bullet  | 4-6              | 4-5

##### Explosive
Weapon				| Damage      | Duration    | Radius 
:---------------:|:-----------:|:----------:|:--------:|
Bomb             | 480         | 4 seconds  | 6 feet

-
#### Weapons - Details
##### Unarmed Combat
Weapon Details			|					|
:----------------------|:--------------:|
**Damage Type**			| Melee			|
**Base Damage** (100%)	| 10				|
**Special Action** (SA)	| Stealth choke  |
**SA Damage**				| 400%				|
**Attack Interval**		| 0.5 Seconds		|

##### Knife
Weapon Details			|				|
:----------------------|:-----------:|
**Damage Type**			| Melee		|
**Base Damage** (100%)	| 30			|
**Special Action** (SA)	| Backstab	|
**SA Damage**				| 300%			|
**Attack Interval**		| 0.5 Seconds	|
**Availability**			| Findable	|
**Total Quantity**		| 8				|

##### Machete
Weapon Details			|				|
:----------------------|:-----------:|
**Damage Type**			| Melee		|
**Base Damage** (100%)	| 40			|
**Special Action** (SA)	| N/A			|
**SA Damage**				| N/A			|
**Attack Interval**		| 0.8 Seconds	|
**Availability**			| Findable	|
**Total Quantity**		| 5				|

##### Hatchet
Weapon Details			|				|
:----------------------|:-----------:|
**Damage Type**			| Melee		|
**Base Damage** (100%)	| 40			|
**Special Action** (SA)	| N/A			|
**SA Damage**				| N/A			|
**Attack Interval**		| 0.8 Seconds	|
**Availability**			| Findable	|
**Total Quantity**		| 3				|

##### Battle-axe
Weapon Details			|				|
:----------------------|:-----------:|
**Damage Type**			| Melee		|
**Base Damage** (100%)	| 60			|
**Special Action** (SA)	| N/A			|
**SA Damage**				| N/A			|
**Attack Interval**		| 1.2 Seconds	|
**Availability**			| Retrievable	|
**Total Quantity**		| 1	(Predator)|

##### Handgun
Weapon Details			|					   |
:----------------------|:-----------------:|
**Damage Type**			| Ranged
**Shot Type**				| Bullet
**Base Damage** (100%)	| 15
**Max Damage**	(150%) | 22
**Min Damage**  (50%)	| 8
**Ammo Loaded**			| 8					   
**Ammo Carried**			| 36	
**Special Action** (SA)	| N/A
**SA Damage**				| N/A
**Attack Interval**		| 0.2 Seconds
**Reload Time**			| 1.36 Seconds
**Availability**			| Findable	   
**Total Quantity**		| 3(sing) 5(multi)

##### Flamethrower
Weapon Details			|					   |
:----------------------|:-----------------:|
**Damage Type**			| Fire (Ranged)
**Shot Type**				| Particle		   
**Base Damage** (100%)	| 6.82 / particle
**Min Damage**  (60%)	| 4.092 / particle   
**Ammo Loaded**			| 200				
**Ammo Carried**			| N/A   
**Special Action** (SA)	| Afterburn (10 Seconds)
**SA Damage**				| 3 / Second	
**Attack Interval**		| 0.044 Seconds	       
**Availability**			| Findable		   
**Total Quantity**		| 1 

##### Dragunov
Weapon Details			|					   |
:----------------------|:-----------------:|
**Damage Type**			| Ranged
**Shot Type**				| Bullet
**Base Damage** (100%)	| 50
**Max Damage**	(150%) | 75
**Min Damage**  (50%)	| 25
**Ammo Loaded**			| 25
**Ammo Carried**			| N/A	
**Special Action** (SA)	| Headshot
**SA Damage**				| Instant Death
**Attack Interval**		| 1.5 Seconds
**Availability**			| Findable	   
**Total Quantity**		| 1

##### Rifle
Weapon Details			|					   |
:----------------------|:-----------------:|
**Damage Type**			| Ranged
**Shot Type**				| Bullet
**Base Damage** (100%)	| 8
**Max Damage**	(150%) | 12
**Min Damage**  (50%)	| 4
**Ammo Loaded**			| 25
**Ammo Carried**			| 75	
**Special Action** (SA)	| N/A
**SA Damage**				| N/A
**Attack Interval**		| 0.1 Seconds
**Reload Time**			| 1.1 Seconds
**Availability**			| Findable & Retrievable (Android)   
**Total Quantity**		| Per Android + 2

##### Bomb
Weapon Details			|					   |
:----------------------|:-----------------:|
**Damage Type**			| Explosive
**Shot Type**				| Bullet
**Base Damage** (100%)	| 300
**Max Damage**	(150%) | 450
**Min Damage**  (50%)	| 150	
**Duration**				| 4 Seconds
**Radius**				| 6 Feet
**Availability**			| Findable   
**Total Quantity**		| 2

-
#### Damage Calculation System
* Add player default damage with the weapon they are using
* Assign each body part a certain percentage of the damage:
	* The amount of ultimate damage would be a combination of the player's damage ability and the body part that they hit
* Explosion damage can be based on the distance form the explosion (a certain percentage) of the explosive damage ability
* Example Calculation (Based on Team Fortress):  
`(Base Damage) x (Distance and Randomness Modifier) x (Resistance/Vulnerability Modifiers) x (Splash Modifiers)`  

**Base Damage:** This is the damage a specific projectile causes. Generally when talking DPS it would be this number multiplied by the rate of fire of the projectile  
**Distance + Randomness:** This is a multiplier used to reduce damage as the projectile collision occurs further away from the bullet's point of origin  
**Resistance/Vulnerability:** This is a multiplier that would be used to reduce/improve effectiveness of a weapon against specific characters  
**Splash Modifiers:** This is used for explosions (distance)

* Damage vs. Distance Calculation:
 <img src="/Users/Liza Girsova/Documents/_Work/_Lawrence University/Class Work/4_Senior/Independent Study/Design/Damage-Distance_calc.png" style="width: 400px"/>

-
### Generalized AI
#### Definitions
* **Visual Range:**
	* **Radius:**
	* **Direction:** 

<a id="chapter-4"></a> 
## Technical
### Minimum System Requirements
* **Game Operating System:** Mac OS X Yosemite 10.10
* **Controller Operating System:** iPhone 8.0 or higher

### General Implementation Details
* **Programming Language:** Swift 2
* **IDE:** Xcode 7.0
* **Additional Frameworks:** Apple SceneKit, iOS SDK
* **Data Storage:** CoreData 
* **Version Control:** Git
* **Graphics:** 3D using .dae scenes and models

### Required Assets
#### Visual
* Animation:
	* Jogging
	* Sprinting
	* Crouching
	* Jumping
	* Attacking
	
#### Audio
* Sound Effects:
	* Jogging
	* Jumping (landing)
	* Attacking

### Physics
* **Engine:** Usng the built-in Physics Delegate in SceneKit
* **Physics Model:** Based on a simplistic Newtonian model
	* Gravity
	* Collision 


### User Interface
#### Mac OS X Game App
##### Title View
* 3D Game Name

##### Device Pairing View
* Prompts the user to open the iOS app on their phones
* Asks user to "pair" the iOS device to the Mac OS X app by providing a code?

##### Mode Choice
* Prompts the user to choose either single-player or multi-player mode

##### Single Player Mode
* Appears upon choosing single-player mode
* Prompts user to choose character 
* "Start Game" button enabled once character is chosen

##### Multiplayer Mode
* Appears upon choosing multi-player mode
* Prompts user to pair the second iOS device with the Mac OS X app
* After both devices paired, prompts user to choose their respective characters
* Prompts user to choose between coop and competitive modes
* "Start Game" button enabled once characters and mode chosen

##### Game
* Single-player mode:
	* View fills up entire NSView/NSWindow 
	* 3rd-person camera view
	* Information available to player:
		* Character Health
		* Character Damage Abilities
		* Enemy Health Level
		* Time Left (Countdown) 
		* Currently Equipped Item

##### In-Game: Inventory
* Available items
* Currently equipped item 

##### In-Game: Menu
* "Pause" caption
* Exit to Main Menu

#### iOS Controller App
##### Title View
* 3D Game Name + "Controller"

##### View Skills
* View players registered on device and their skills 

##### OS X Pairing View
* Prompts user to connect to app by typing in the code provided in the OS X app into the controller
* Place to add code

##### Controller
* Virtual Joystick that has movement controls
* Option to look at "Skills"


### Use Cases
Use Case				           | Crit. | Risk | Priority |
:------------------------------|:-----:|:----:|:--------:
**User**					        |
Pairs iOS Controller with app  | 10 	   | 6    | 10
Selects Player Mode				 | 10	   | 1    | 10
Selects Character Avatar       | 5      | 4    | 5
Changes Multiplayer Split View | 1		| 4    | 1
**Main Player Character**     |
Movement: Jump                | 10      | 3    | 10
Movement: Walk/Run            | 10      | 2    | 10
Movement: Crouch					| 10      | 3    | 10
Combat: Attack                | 10      | 8    | 10
Look Around						| 10		| 4    | 10
Interact							| 10		| 4    | 10
Equip Object						| 10      | 8    | 10
View Inventory                | 10      | 9    | 10 
**NPC AI**						|
**Game World**                |
Randomize object appearance   | 10      | 9    | 8
**Bird**					       | 	
**Copperhead**			       |
**Predator Dark**		       |
**Combat Android**		       |
**Lambent Male**			       |
**Lambent Female**		  |
**Bear Brown**			  |
**Dog**					  |
**Female Elk**			  |
**Male Elk**				  |
**Giraffe**				  |
**Swarm Infector**		  |
**Wolf**					  |
**Ostrich**				  |
**Zombie Dog**			  |
**Goat**					  |	

### Program Structure: Classes
#### Mac OS X
##### Networking 
##### Game Window Controller
##### Player

#### iOS
##### Networking - ServiceBrowser.swift
* Properties
	* `serviceBrowser: MCNearbyServiceBrowser` 
	* `gameServiceType: String`
	* `peerId: MCPeerID`
	* `codeEnteredNotificationKey: String`
	* `updateConnectionNotificationKey: String`
	* `currentBrowser: MCNearbyServiceBrowser?`
	* `currentFoundPeerId: MCPeerID?`
	* `session: MCSession`
* Methods
	* `init()`
	* `deinit`
	* `sendInvite(notification: NSNotification)`
* Delegates

##### iOS Controller View Controller - ControlsViewController.swift
* Includes 2 main UIViews: movementTrackpadView and cameraTrackpadView
* Separate gesture recognizers will be used for each UIView (attached to each view), depending on the gesture that needs to be recognized
	* Will primarily be using the UILongPressGestureRecognizer for the trackpad and the UITapGestureRecognizer for the buttons in the UIViews

### Networking Details
* **Framework:** Apple's Multipeer Connectivity Framework
* **Connection Type:** Wifi & Bluetooth (determined by framework)
* **Server:** Mac OS X game application
* **Client:** iOS controller application
* **Game Service Type:** `elg-escape-game`
* **"Handshake v.1":** 
	1. Mac OS X game application displays a 4 digit code
	2. User types the 4 digit code into their iOS controller application
	3. If the code was types correctly, the Mac OS X game application accepts the invitation to connect and the connection is established
* **Handshake v.2:**
	1. Mac OS X application begins to advertise itself as a host and with the UI displaying "Waiting for players"
	2. iOS Controller application begins to browse for hosts with the UI display Waiting for hosts" or "Hosts" followed by a list of hosts
	3. Users of the iOS controllers click on the host they want to join, sending them an invitation
	4. Mac OS X application now lists a number of players that have sent an invite. Users of the Mac OS X application select the players and click "continue" to start the game

### Existing Bugs
* User Needs to be notified when connection to Mac OS X failed
	* Mac OS X needs to restart the connection immediately
	* When the host disappears from network, ios controller app needs to return to main screen view  

### Player Controls Implementation Details
#### Virtual Joystick
* Where user begins the pan gesture and `UIPanGestureRecognizerState.Began` is called, the method `translationInView(_View: NSView) -> CGPoint` returns the point where the player will be considered static
	* This point is usually `(0.0, 0.0)` and all of the translations are moved in terms of it 
	* The `CGPoint` is written in terms of the coordinate system: (x, y) where the coordinate system on the iOS starts in the upper left corner. This means that an upward movement decreases `y` while a downward movement increases `y`
* When the finger moves away from that point, the direction vector will be calculated
* Converting between 2D vector and 3D movement:
	* iOS `y` coordinate is the SceneKit `z` coordinate
	* iOS `x` coordinate is the SceneKit `x` coordinate
* The `x` and `y` values report the total translation over time

Generalized Translation Vectors | CGPoint    |
--------------------------------|------------|
Original (Starting Position)	  | (0.0, 0.0)
Upward Pan Gesture 				  | (0.0, -5.0)
Downward Pan Gesture			  | (0.0, 5.0)
Leftward Pan Gesture			  | (-5.0), 0.0)
Rightward Pan Gesture			  | (5.0, 0.0)

##### Movement Controls
##### Camera Controls
* Rotation of camera expressed as Euler Angles using Pitch, Yaw, and Roll
	* Pitch: the `x` component, is the rotation about the node's x axis
	* Yaw: the `y` component, is the rotation about the node's y axis
	* Roll: the `z` component, is the rotation about the node's z axis  
	* `sceneView.playing = true`
* The camera is essentially placed on an "imaginary sphere" whose center is the sprite position
* As the player swipes to the left to look left, the sphere rotates to the right to show the left side and so that the player is always in view. When the player swipes to the right to look right, the sphere rotates to the left to show the right side and so that the player is always in view

### Artificial Intelligence

-
#### Additional Things to Consider
* Player must be able to make meaningful and interesting choices
* Symmetry is the simplest way to balance a game
* There must be trade-offs involved, to make the choice-making more interesting
* Feedback: Tension between players can be increased with the aid of feedback
	* If one player is ahead in the game, the game could get more difficult for the player - *negative feedback*
	* If a player is behind in the game, challenges could get easier for that player - *positive feedback*

## Game Production Timeline
### Iteration 1
#### Week 1: Game & Level Design
* Concept
* Rules
* Mechanics
* Level Design

#### Week 2: Implementation of Game Base
* Networking between iOS device and OS X App
* Basic Movement Controls with Character Bot:
	* Directional Movement
	* Camera Movement 
* Antagonistic Elements
	* Bots for all antagonistic elements 
* Basic Physics: 
	* Gravity
	* Collision Detection 

#### Week 3: Implementation of 3D Models and Animation 
* Apply the models to the already-generated bots
* Add animation based on the movement: walk, jump, crouch, attack 

#### Week 4: Graphics Implementation of Level
* Create 3D Scene
* Add all models to the 3D scene
* Apply physics and collision detection to all objects in scene
	* Include attacking collision detection 

### Iteration 2
#### Week 5: Design & Implementation
* Re-evaluate all design choices made so far
* Begin implementation of AI
	* Normal Behavior of NPCs
	* Detection State 

#### Week 6: Implementation of AI
#### Week 7: Implementation of Multiplayer Features
* Split-screen camera views
* Physics collision detection

#### Week 8: Point-Based System
* Calculate the points of each player

#### Week 9: Testing & Tweaking
#### Week 10: Additional Features