#!/usr/bin/env python3
from src.game.World import World
from src.BotExample import BotExample


class BotFramework:
    def __init__(self):
        self.agent = BotExample()
        self.world = World()

    def update(self, data):
        self.world.update(data["world"]["entities"])

    def generate_bot_commands(self):
        for hero in self.world.get_player_heroes():
            self.agent.actions(hero)

    def receive_bot_commands(self):
        commands = {}
        for hero in self.world.get_player_heroes():
            command = hero.get_command()
            if command:
                commands.update(command)
                hero.clear_and_archive_command()
        return commands
