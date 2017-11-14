
Presentation
============

A Dashboard with on-line configuration :
* edit descriptor
* on save of it, dahboard reloads the configuration

Should work anywhere Ruby-Gtk work.
Demo use Unix commande (grep/wc -l...)

Usage (linux) :
---------------

```
> gem install gtk3 Ruiby
> gem install gtk3
> cd ..../gtk-dashboard
> cd lib
> ruby show.rb  # use lshow.rb configuration file by default
```


Architecture
===========
```
       ----------      -------------------     --------
       |Producer|      | memory-database |     |widget|
       |        |      |                 |     |      |
       |        |      |                 |Read |------|
       |--------|Write |                 |====>| Plot |====> Main-Window
       |  MQTT  |=====>|                 |(sub)|------|
       |connect.|Data  |                 |     |      |
       |--------|      |                 |     |      |
       |        |      |                 |     |      |
       |        |      |                 |     |      |
       ----------      -------------------     --------

```

All these elements are in one, simple process, which manage  Gtk main window.

Producer, database, widgets are descibe with a  ruby file descriptor.
Descriptor contain also the CSS of the application.


Desciptor
==========

Structure
--------
```ruby
{
    bddtr: {
        <varname> : {....}, 
        bb: {type: Float, value: 0},
    },
    production: [
        {type: ProdSystem,... },
        {type: ProdPipeNum, ... },
        {type: ProdRuby, ... },
    ],
    window: {
     page1: {
        1 => {
          1 =>  proc {|e| e.nb(10,"nb Frame","pgrep -laf appli_sim") },
          2 =>  proc {|e| e.fsize(10,"size-logs","../logs/log*.txt")  },
        }
     }
   }
   css; <<EEND
* { ... }
EEND
}
```
Bddtr containthe list of variable in database. (Variables are String/Float/Int, no structurd data).

Produceur declare all connector.
They are 3 type/familly of connector:
* ProdSystem : data came from  a systm commande.
* ProdPipeNum: data are numerique value out of pipe ( exemple : vmtat 1)
* ProdRuby : A ruby cade generate value for Bddtr. the Dashboard call this traitment periodcly (as ProSystem)

Windows entry specify the widgets.
They are organise in row/column table :
r1 { cel1 proc {} , cell1 proc {} ..} r2 { ... } r3 { ... }

All widget are epecified by proc.
A helper is provided, 'e' context variable, which is the manager of all widgets (see E class in widgts.rb)

Old fashion widgets
--------------------
On first version, widget get data, they were no memory-database, 
* e.nb  : execute a system commande and count the line output, show "label : cvalue"
* e.fsize: count the nomber of line of all files 
* e.bd

New fashion Widgets
-------------------
In new version, database act as midleware
* Plot
* Gauge
* List

