import json
from library.bottle.bottle import run, post, get, request
from src.BotFramework import BotFramework

framework = BotFramework()


@get("/api/party")
def party():
    return json.dumps(framework.get_party())


@post("/api/chat")
def chat():
    postdata = request.body.read()

    print(postdata)
    return json.dumps("ok")


@post("/api/update")
def update():
    post_data = request.body.read()
    world = json.loads(post_data)

    framework.update(world)
    framework.generate_bot_commands()
    commands = framework.receive_bot_commands()

    return json.dumps(commands)


run(host="localhost", port=8080, debug=True, reloader=True)
