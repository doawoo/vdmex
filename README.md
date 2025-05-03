# Vdmex

This is a collection of Elixir and VDMX Control Surface JSON templates that allow me to "script" VDMX using GenServers.

The general workflow goes like this:

1. Create a "Control Surface" in VDMX by importing the JSON layout of the module you want to use from the `/modules` directory.
2. Tweak the mins and maxes and other options the template provies, and hook up and `CLOCK` inputs (however you want).
3. Start up this Elixir application on the same machine as the VDMX instance, the app will seek out all matching control surfaces and start automating them!

Currently I haven't written support for dynamically added control surfaces so you'll need to restart the Elixir app when you add a new one.
I plan to fix that soon...