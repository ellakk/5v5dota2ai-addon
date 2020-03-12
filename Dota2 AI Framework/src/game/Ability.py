#!/usr/bin/env python3

from src.game.BaseEntity import BaseEntity


class Ability(BaseEntity):
    def __init__(self, data):
        super().__init__(data)

    def getAbilityDamage(self):
        return self.data["abilityDamage"]

    def getAbilityDamageType(self):
        return self.data["abilityDamageType"]

    def getAbilityIndex(self):
        return self.data["abilityIndex"]

    def getAbilityType(self):
        return self.data["abilityType"]

    def getBehavior(self):
        return self.data["behavior"]

    def getCooldownTime(self):
        return self.data["cooldownTime"]

    def getCooldownTimeRemaining(self):
        return self.data["cooldownTimeRemaining"]

    def getLevel(self):
        return self.data["level"]

    def getMaxLevel(self):
        return self.data["maxLevel"]

    def getTargetFlags(self):
        return self.data["targetFlags"]

    def getTargetTeam(self):
        return self.data["targetTeam"]

    def getTargetType(self):
        return self.data["targetType"]
