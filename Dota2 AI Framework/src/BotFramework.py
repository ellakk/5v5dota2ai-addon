#!/usr/bin/env python3
from src.game.Hero import Hero
from src.BotExample import BotExample


class BotFramework:
    def __init__(self):
        self.agent = BotExample()
        self.heroes = []

    def Update(self, data):
        self.heroes.clear()
        print(data)
        for hero in data["heroes"]:
            self.heroes.append(Hero(hero['name'], hero, data['world']))

    def GenerateBotCommands(self):
        for hero in self.heroes:
            self.agent.actions(hero)

    def ReceiveBotCommands(self):
        commands = {}

        for hero in self.heroes:
            if hero.command:
                commands.update(hero.command)
        return commands
