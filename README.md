# Activitybot

[NO MO’ FOMO!](https://www.youtube.com/watch?v=2OFZj3HgzLw) Activitybot is an activity bot for Slack. When a channel it is listening on (and it has to be configured separately for each channel it listens to) gets “active,” it posts a message to a separate channel noting the activity. That way, a person can have notifications set on on the separate channel and find out that another channel is seeing real activity, and not just one person posting URLs.

## Requirements

You'll need a [Slack](https://slack.com) account, obviously, and a free [Heroku](https://www.heroku.com/) account to host the bot. You'll also need to be able to set up new integrations in Slack; if you're not able to do this, contact someone with admin access in your organization.

## Installation

1. Set up a Slack outgoing webhook at https://slack.com/services/new/outgoing-webhook. Keep the trigger word blank, as you want the bot to note all conversation. This step has to be repeated for each channel you want to track, but you can ignore the separate tokens. One is sufficient.

2. Set up a separate Slack *incoming* webhook at https://slack.com/services/new/incoming-webhook and pick the channel you want the Activitybot to use when posting updates. This should be a channel used for no other purpose, and it should be towards the end of the alphabet. Keep track of the webhook url Slack gives you, as that will be added to `ENV[WEBHOOK_URL]` in Heroku. Similarly, the channel you want to use will be saved as `ENV[CHANNEL]`, and the default is “zbullpen.”

3. Click this button to set up your Heroku app: [![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)   
If you'd rather do it manually, then just clone this repo, set up a Heroku app with Redis Cloud (the free level is more than enough for this), and deploy activitybot there. Make sure to set up the config variables in
[.env.example](https://github.com/muziejus/activitybot/blob/master/.env.example) in your Heroku app's settings screen.

4. Point the outgoing webhook to https://[YOUR-HEROKU-APP].herokuapp.com

5. Add funny icons (pictures of bullpen cars, whatever) to your bots.

## Usage

The bot listens on all channels and makes a redis entry every time someone
speaks. Two variables determine when the bot will announce that a channel is
alive, with `ENV[NUMBER_OF_CHATTERS]` team members speaking over the course of
`ENV[MINUTES]` minutes in the same channel. The default is set to three members
speaking in the same channel over the course of two minutes. This is obviously
designed for small teams that don't have a lot of chatter, but where FOMO is
high.

If both conditions are met, the bot announces in the channel configured in the
*incoming* webhook (also saved as `ENV[CHANNEL]`) that there is activity in a
    channel. The idea is that people who have FOMO have notifications set on on
    the announcement channel, so they are alerted. The default is “zbullpen,”
    but you can use something more clever if you like.

Similarly, the bot’s announcement is saved as `ENV[ACTIVITY_MESSAGE]`, and the
default is “There is some activity in #&lt;channel&gt;’s bullpen!”, where `<channel>`
is later replaced with the actual name of the channel.

Once the alert goes out, the bot waits `ENV[WAIT_TIME]` minutes before polling
it again, so it's not constantly announcing activity. The default is an hour.

The bot is very trustworthy. It doesn't check incoming tokens against tokens it has pre-configured. But the internet is a safe place!

## Credits & acknowledgements

This bot is based off of the clear implementation provided by Guilermo Esteves and the [Trebekbot](http://github.com/gesteves/trebekbot).

## Contributing

Feel free to open a new issue if you have questions, concerns, bugs, or feature requests. Just remember that I did this for fun, for free, in my free time, and I may not be able to help you, respond in a timely manner, or implement any feature requests.

Classic Val.

## License 

Copyright (c) 2015, Moacir P. de Sá Pereira, based on work

Copyright (c) 2014, Guillermo Esteves
All rights reserved.

BSD license

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
