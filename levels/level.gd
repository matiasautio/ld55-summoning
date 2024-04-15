extends Node2D

@onready var tier_1_creatures = [$timemachine]
@onready var tier_2_creatures = [$Taxi, $Hole, $Hole2]
@onready var tier_3_creatures = [$Fire, $Island]
@onready var tier_4_creatures = [$Island/Whale]

func _ready():
	Console.game_manager.level = self


func trigger_creatures(tier):
	if tier == 1:
		for creature in tier_1_creatures:
			creature.visible = true
	elif tier == 2:
		for creature in tier_2_creatures:
			creature.visible = true
	elif tier == 3:
		for creature in tier_3_creatures:
			creature.visible = true
