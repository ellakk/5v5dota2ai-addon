#!/usr/bin/env python3

from src.game.Hero import Hero


class PlayerHero(Hero):
    def __init__(self, data):
        super().__init__(data)
        self.commands = [
            "ATTACK",
            "MOVE",
            "CAST",
            "BUY",
            "SELL",
            "USE_ITEM",
            "LEVELUP",
            "NOOP",
        ]
        self.command = None
        self.commands = []

    def get_command(self):
        return self.command

    def clear_and_archive_command(self):
        if self.command:
            self.commands.append(self.command)
            self.command = None

    def attack(self, target):
        self.command = {self.getName(): {"command": "ATTACK", "target": target}}

    def move(self, x, y, z):
        self.command = {self.getName(): {"command": "MOVE", "x": x, "y": y, "z": z}}

    def cast(self, ability):
        self.command = {self.getName(): {"command": "CAST", "ability": ability}}

    def buy(self, item):
        self.command = {self.getName(): {"command": "BUY", "item": item}}

    def sell(self, slot):
        self.command = {self.getName(): {"command": "SELL", "slot": slot}}

    def use_item(self, slot):
        self.command = {self.getName(): {"command": "USE_ITEM", "slot": slot}}

    def level_up(self, abilityIndex):
        self.command = {
            self.getName(): {"command": "LEVELUP", "abilityIndex": abilityIndex}
        }

    def noop(self):
        self.command = {self.getName(): {"command": "NOOP"}}