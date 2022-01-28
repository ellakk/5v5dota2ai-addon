# The DotA 2 AI 5v5 Framework project
**General disclaimer: this project is not affiliated with Valve. It's an academic research project.** 
## About
A 5v5 framework developed by Kalle Lindqvist and Dennis Nilsson, an extension of a previous 1v1 framework developed by Tobias Mahlmann.

## Goals of this project
To provide a framework able to to run 5v5 matches with bots in DotA 2. One team controlled by usermade bots competing against the in-game DotA 2 bots.

Submit the framework to competitions held by organizations such as the conference on games (COG) and foundations of digital games conference (FDG).

## Using the framework
* Download DotA 2
* Download workshop tools for DotA2 (DLC)
* Download the [5v5 framework](https://github.com/ellakk/5v5dota2ai-framework)
* Copy the framework files located in the Dota2 AI Addon folder and put them in SteamLibrary/steamapps/common/dota 2 beta
* Run DotA 2 workshop tools, click play and select workshop tools
* Load the dota2ai project in the workshop tools
* Run the Python client, start it by running framework.py in the Dota2 AI Framework folder - src folder - (python framework.py in a command prompt/terminal)
* Open vConsole in the workshop tool
* Run the following command in vConsole to launch the mod: dota_launch_custom_game dota2ai dota

By performing these steps the framework will launch a game filled with bots. Both teams are controlled by custom bots, which you can change by editing the settings.json file in the [framework](https://github.com/ellakk/5v5dota2ai-framework)  You can find examples for controlling the bots in the Dota 2 AI framework/src folder. The example script currently shows a minimal bot implementation

### Generating Documentation

The project uses [pdoc](https://github.com/mitmproxy/pdoc) to generate the API documentation found in the Documentation/api directory.

## Future work
Implement functionality that supports 5v5 matches where all bots are controlled by user developed scripts.
