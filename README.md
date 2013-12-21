PinewoodDerby
=============

A race manager and status board application for Cub Scout Pack 420's [pinewood derby](http://en.wikipedia.org/wiki/Pinewood_derby)

![screenshot](http://cl.ly/image/1L3b3g0o0R0F/Screen%20shot%202013-02-03%20at%209.18.25%20PM.png)

Features
--------

* Show a status board (TV/projector) with the standings, most recent heat times, and upcoming heats, all updated in real-time
* Register contestants, even after the derby has begun
* Activate the start switch for each race with a button in the app
* Swap out contestants in upcoming heats when someone is MIA or not ready to race
* Redo the most recent heat when something goes wrong
* Manage the derby, show the display board, and run the sensor on different devices if desired
* Retire contestants that drop out of the derby
* The welcome screen displays the URL at which other devices can access the application
* Warnings are displayed when the USB device is unplugged or the sensor daemon is not running
* Lineup order is automatically generated (using the rules below)
* Race using a configurable number of lanes

Limitations
-----------

This PinewoodDerby app was written in a short period of time for our Pack's needs.
Some features were left out due to time constraints.
There are with several important assumptions that are currently built into this application, including:

### Sensor and track

* A [NewBold DT8000](http://www.pinewood-derby-timer.com/DT8000.html) track sensor
* A USB-serial adapter that creates a character device on /dev/ttyUSB\* or /dev/tty.usbserial\* such as the [IOGEAR GUC232A](http://www.iogear.com/product/GUC232A/) on Linux
* A Linux or OSX operating system running the sensor application

### Derby lineup rules

* Each contestant will run exactly once in each lane
* The winner is the contestant with the lowest cumulative/average time (no brackets/playoffs)
* In the first round, contestants race in the order they were registered
* Contestants will race against others they have not yet raced against when possible
* Keeping the above constraints, racers with slower averages will race before those with faster averages
* When swapping out or adding contestants, the upcoming 3 heats are not recalculated unless there are empty lanes

### Missing features

* Authentication - anyone who visits the app URL can start races, modify contestants, clear all data, etc.
* Customization - support for other devices and variations on the lineup rules
* Deltas - indicate when a contestant moves up or down in rank with a green or red highlight
* Canceling a heat - once you start a heat, you cannot cancel it and must trigger the sensor
* Non-finishers - handle people whose cars don't make it to the sensor in under 10 seconds; currently they don't get a time for that heat
* Windows support, and configurable support for device paths other than /dev/ttyUSB\* or /dev/tty.usbserial\*
* Mobile layout - the responsive mobile layout sometimes isn't very pretty

Feel free to inquire (via issues) regarding how you can modify this app for your setup. I am happy to assist.

Despite this being a last-minute attempt with no automated tests, it ran our 2013 derby perfectly with zero problems.

Setup
-----

1. [Install drivers for the USB serial connector](https://github.com/nilbus/pinewood-derby/wiki/USB-serial-driver-installation)
1. Install [Ruby &gt;= 1.9.2](https://www.ruby-lang.org/en/downloads), [bundler](http://bundler.io), and [PostgreSQL](http://www.postgresql.org/)
1. Install the required ruby dependencies

        bundle install

1. After starting the PostgreSQL server, initialize the database

        rake db:setup RAILS_ENV=development
        rake db:setup RAILS_ENV=production

1. Ensure the `config/derby_config.yaml` file is configured correctly for your setup
1. Run the application and sensor daemon as root (for access to port 80) and wait a few seconds

        rvmsudo foreman start   # or just plain sudo

1. Visit http://localhost/ - You should see the welcome screen, and it should report that the sensor is not plugged in
1. Connect the sensor via USB, and turn it on. Hit the reset button, and it should display "3 lanes". Press reset until the sensor display goes blank.
1. Verify that the "not plugged in" warning has gone away
1. Connect with other devices to the URL on the welcome page (status board and/or other device to manage the derby)
1. Visit the contestants page to register contestants
1. Visit the Dashboard page to manage the races

Running a heat
--------------

1. Have the contestants for the upcoming heat place their cars on the track. If a contestant is missing, click their name to swap in another contestant and try the missing person later.
2. On the Dashboard page, click the "Start the race" button. The next race is highlighted in green.
3. Simultaneously release the cars and release the sensor's start switch to start the timer. The race times will appear on the Dashboard after they pass the finish line.
4. If needed, click the "redo" button to re-run the same heat.

Developing
==========

This project uses Rails 4.

Instead of using foreman, start the app server and daemon separately:

    rails server

    rake daemon:sensor_watch

Testing
-------

To simulate a sensor device, you can create a fifo at /dev2/ttyUSB0:

    sudo mkdir /dev2
    sudo mkfifo /dev2/ttyUSB0
    sudo chown $USER /dev2/ttyUSB0

Because a fifo differs from a real character device, every time the daemon restarts, the daemon will block until you feed it some input:

    echo hello > /dev2/ttyUSB0

To simulate random race times after starting a heat:

    ruby -e 'print ": "; 3.times {|i| print "#{i+1} #{(rand*10).round(3)} " }; puts' | tee /dev2/ttyUSB0

When using the Rails console, start EventMachine or Faye will throw `RuntimeError: eventmachine not initialized: evma_connect_to_server` when events are triggered.

    Faye.ensure_reactor_running!

Architecture
------------

### Sensor driver

`TrackSensor` communicates with the sensor device via the device file in /dev. It tells the device to start a race and reads the race times. When the device is unplugged, it throws an error when attempting to read race times.

This component could be separated into its own gem, but I'm including it in this project for now.

### SensorWatch daemon

`SensorWatch` runs as a daemon to keep the persistent instance of TrackSensor necessary to keep the device open. The application communicates with the daemon via POSIX signals (SIGUSR1) to start a race. The daemon communicates with the app via Faye and database updates.

### Rails web server

The user interface is provided via the web.

### Faye websocket pub/sub

The faye-rails `AnnounceController` in the `SensorWatch` daemon uses ActiveRecord observers to detect changes the daemon makes to the models - updating heat status, run times, etc. These changes trigger Faye to publish a message.

The faye-redis engine communicates these update messages to the Faye publisher running in the app server.
This publisher sends the `Dashboard` json updates to its javascript clients connected via websockets.

Contributing
------------

This pinewood-derby application is Copyright 2013 Edward Anderson,
and is distributed under the GNU Affero General Public License (see LICENSE).

Please let me know (via [issues](https://github.com/nilbus/pinewood-derby/issues)) if you're interested in using this PinewoodDerby software or need help with it.
