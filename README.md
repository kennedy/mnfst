Mnfst
========

Concept: never create an account, instead sign text with a PGP key.

_Create a new status_. This takes JSON where the content is a piece of
text that is signed using a PGP key.

    POST /statuses
    Content-Type: application/json

    { status: { signed_body: PGP-signed-ASCII } }

    =>

    201

_Create a new status, detached_. This takes JSON where the content is a piece
of text plus the PGP signature.

    POST /statuses
    Content-Type: application/json

    { status: { body: ASCII, signature: PGP-signed-ASCII } }

    =>

    201

_View a status_. Takes a status ID. This is mostly here just for sharing
URLs with others.

    GET /statuses/:id
    Content-Type: application/json
    Accept: application/json

or:

    GET /statuses/:id
    Content-Type: text/html

Examples
--------

This repo comes with a file `data` that has an example POST data. Use it
as a template.

The `signed_body` was generated from an input file named `tweet` using:

    gpg -a --output tweet.asc --sign tweet

These commands can be used to interact with the system:

    curl -i -d@data localhost:7000/statuses -H "Content-Type: application/json"
    curl -i localhost:7000/statuses/17 -H "Content-Type: application/json" -H "Accept: application/json"

Getting Started
---------------

This repository comes equipped with a self-setup script.

    % ./bin/setup

After setting up, you can run the application using [foreman]:

    % foreman start

[foreman]: http://ddollar.github.io/foreman/

Guidelines
----------

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)
