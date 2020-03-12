#!/usr/bin/env python3
from src.game.BaseEntity import BaseEntity


class BaseNPC(BaseEntity):
    def __init__(self, data):
        super(data)

    def getAbilities(self):
        return self.data["abilities"]

    def getAttackRange(self):
        return self.data["attackRange"]

    def getAttackTarget(self):
        return self.data["attackTarget"]

    def getLevel(self):
        return self.data["level"]

    def getMana(self):
        return self.data["mana"]

    def getMaxMana(self):
        return self.data["maxMana"]

    def getTeam(self):
        return self.data["team"]

    def isAlive(self):
        return self.data["alive"]

    def isBlind(self):
        return self.data["blind"]

    def isDeniable(self):
        return self.data["deniable"]

    def isDisarmed(self):
        return self.data["disarmed"]

    def isDominated(self):
        return self.data["dominated"]

    def isRooted(self):
        return self.data["rooted"]
