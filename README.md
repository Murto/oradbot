# oradbot

oradbot (OpenRA Discord Bot) is a bot created to provide matchmaking, real time server monitoring and moderation utilities to the unofficial OpenRA discord server.

To use oradbot you will require [Luvit](https://luvit.io).


#### Setup

To set up oradbot, simply clone this repository (or download & unpack a zip file) then enter the *src* folder. If you have installed luvit correctly then you should have the lit toolkit. If so, then run the following command:

~~~
lit install
~~~

This will install all required dependencies and complete bot set up.


#### Usage

To use the bot you will require a bot token. You can get a bot token by [setting up a new Discord application](https://discordapp.com/developers/applications/me). If you have your bot token in the $DISCORD_BOT environment variable then enter the root directory and use the following command:

~~~
sh run.sh
~~~

Otherwise, if you wish to enter your bot token manually, enter the *src* directory and use the following command:

~~~
luvit main.lua [token]
~~~

The bot should appear in the discord servers you have added it to shortly after.


#### License

oradbot is licensed under the GNU General Public License v3.0

See [LICENSE](https://github.com/Murto/oradbot/blob/master/LICENSE) or [this](https://opensource.org/licenses/GPL-3.0) for more information.
