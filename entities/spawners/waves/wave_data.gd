class_name WaveData
extends Resource

# modifies an entity spawner

## Blue entities
@export_group("Blue Entity")
@export var blue_scenes: Array[PackedScene]

## Red entities
@export_group("Red Entity")
@export var red_scenes: Array[PackedScene]

## Green entities
@export_group("Green Entity")
@export var green_scenes: Array[PackedScene]

@export_group("Spawn Count")
@export var total_to_kill:  int   = 10   ## kill count needed to end the wave
@export var spawn_count_min: int  = 1
@export var spawn_count_max: int  = 1
@export var burst_spread:   float = 0.0

@export_group("Timing")
@export var respawn_delay_min: float = 0.8
@export var respawn_delay_max: float = 1.2

@export_group("Entity Weights")
@export var blue_weight:    float = 1.0
@export var blue_max_alive: int   = 0
@export var red_weight:     float = 1.0
@export var red_max_alive:  int   = 0
@export var green_weight:   float = 0.0
@export var green_max_alive: int  = 0

@export_group("Throw Settings")
@export var throw_force_min: float = 700.0
@export var throw_force_max: float = 1100.0
@export var spread_min:      float = -0.3
@export var spread_max:      float =  0.3
@export var gravity_min:     float =  0.7
@export var gravity_max:     float =  1.0
@export var spin_min:        float = -5.0
@export var spin_max:        float =  5.0
