# DASH-IF DASH Live Source Simulator

This software is intended as a reference that can be customized to provide a reference
for several use cases for live DASH distribution.

It uses VoD content in live profile as a start, and modifies the MPD and the media
segments to provide a live source. All modifications are made on the fly, which allows
for many different options as well as accurate timing testing.

The tool is written in Python and runs as an Apache mod_python plugin or using mod_wsgi.

The Dockerfile can be used to build a docker container that has Apache with the mod_python
plugin.

    docker build -t dash-live .
    
It exposes the Apache server on port 80 of the container. You need to map this to a port
on the host running the container. For example to use host port 8123:

    docker run -p 8123:80 -t dash-live

