## Authoritative game state — CLAUDE.md §2, §8.
##
## CORE ISOLATION RULE (CLAUDE.md, §8 "Key rule"):
##   This file — and everything under /core — MUST NOT depend on /views,
##   /input, or /net. No rendering, no input polling, no networking.
##   Game rules take inputs and produce state; views render state; the
##   network moves state. Keep this deterministic and unit-testable.
##
## This is a minimal Phase-1 placeholder so the split exists from day one.
## Real combat resolution lands in the single-player core loop (build step 1).

class_name GameState
extends RefCounted

const STARTING_HP := 30

var players_hp: Array[int] = [STARTING_HP, STARTING_HP]
var boss_hp: int = 100
var turn: int = 1

## Pure, deterministic: apply damage to the boss and return remaining HP.
func damage_boss(amount: int) -> int:
	boss_hp = max(boss_hp - amount, 0)
	return boss_hp

## True when the shared board is in a terminal state.
func is_boss_defeated() -> bool:
	return boss_hp <= 0

## A tiny self-check the runnable scene calls to prove /core works headless
## with zero rendering/input/net dependencies. Returns true on success.
static func self_check() -> bool:
	var gs := GameState.new()
	assert(gs.boss_hp == 100)
	gs.damage_boss(40)
	assert(gs.boss_hp == 60)
	gs.damage_boss(1000)
	assert(gs.boss_hp == 0)
	assert(gs.is_boss_defeated())
	return true
