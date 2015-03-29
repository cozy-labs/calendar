# [Cozy](http://cozy.io) Calendar

Cozy Calendar makes your event management easy. This a standalone version that
don't require the whole Cozy platform. Main features are: 

* Simple UI
* Event tagging
<<<<<<< HEAD
* Event sharing (via email) (fix on the way)
* ICal import (fix on the way) 
=======
* Event sharing (via email)
* ICal import
* CalDAV sync (require [Cozy Sync](https://github.com/mycozycloud/cozy-sync))
>>>>>>> 95d0785fad0c21a4f96bf50b6af6e224172f5c42

## Install

    npm install cozy-calendar -g

## Run

Run it from anywhere, data will be stored in the `~/.cozy-calendar`folder:

    cozy-calendar


## Contribution

You can contribute to the Cozy Calendar in many ways:

* Translate it in [a new language](https://github.com/mycozycloud/cozy-calendar/tree/master/client/app/locales).
* Allow to share calendars via ICal feeds.
* Allow to subscribe to a CalDAV Calendar.

## Hack

Get sources:

    git clone https://github.com/mycozycloud/cozy-calendar.git

Run it with:

    npm start

Each modification of the server requires a new build, here is how to run a
build:

    cake build

Each modification of the client requires a specific build too.

    cd client
    brunch build

## Tests

To run tests type the following command into the Cozy Calendar folder:

    cake tests

In order to run the tests, you must only have the Data System started.

## Icons

by [iconmonstr](http://iconmonstr.com/)

Main icon by [Elegant Themes](http://www.elegantthemes.com/blog/freebie-of-the-week/beautiful-flat-icons-for-free).

## License

Cozy Calendar is developed by Cozy Cloud and distributed under the AGPL v3 license.

## What is Cozy?

![Cozy Logo](https://raw.github.com/mycozycloud/cozy-setup/gh-pages/assets/images/happycloud.png)

[Cozy](http://cozy.io) is a platform that brings all your web services in the
same private space.  With it, your web apps and your devices can share data
easily, providing you with a new experience. You can install Cozy on your own
hardware where no one profiles you.

## Community

You can reach the Cozy Community by:

* Chatting with us on IRC #cozycloud on irc.freenode.net
* Posting on our [Forum](https://forum.cozy.io/)
* Posting issues on the [Github repos](https://github.com/cozy/)
* Mentioning us on [Twitter](http://twitter.com/mycozycloud)

