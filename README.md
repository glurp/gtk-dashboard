
Presentation
============

A Dashboard with on-line configuration :
* edit descriptor
* on save of it, dahboard reloads the configuration

Should work anywhere Ruby-Gtk work.

![demo](https://raw.githubusercontent.com/glurp/gtk-dashboard/master/demo.png)

Usage (linux/windows) :
------------------------

```
> gem install gtk3
> gem install Ruiby
> git clone https://github.com/glurp/gtk-dashboard.git
> cd gtk-dashboard
> cd lib
> ruby show.rb  descr.rb
```


Architecture
===========
```
       ----------      -------------------     --------
       |Producer|      | memory-database |     |widget|
       |        |      |     rtdb        |     |      |
       |        |      |                 |Read |------|
       |--------|Write |                 |====>| Plot |====> Main-Window
       |  MQTT  |=====>|                 |(sub)|------|
       |connect.| (pub)|                 |     |      |
       |--------|      |                 |     |      |
       |        |      |                 |     |      |
       |        |      |                 |     |      |
       ----------      -------------------     --------

```

RTDB use read/write and Publish/Subscribe pattern.

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
RTDB contain the list of variable in database. (Variables are String/Float/Int, no structurd data).

Produceur declare all connector.
They are 3 type/family of connector:
* ProdSystem : data came from  a system commande.
* ProdPipeNum: data are numerics values out of pipe ( exemple : vmtat 1)
* ProdRuby : A ruby  generate value for Rtdb. the Dashboard call this traitment periodcly (as ProSystem)



Windows entry specify the widgets.

* They are organise in row/column table : r1 { cel1 proc {} , cell1 proc {} ..} r2 { ... } r3 { ... }



All widget are specified by proc.
A helper is provided, 'e' context variable, which is the manager of all widgets (see E class in widgets/engine.rb)

Old fashion widgets
--------------------
On first version, widget get data, they were no memory-database, 
* e.nb  : execute a system command and count the line output, show "label : value"
* e.fsize: count the number of line of all files globed by parameter
* e.bd : show rtdb variable content in a label



New fashion Widgets
-------------------

In new version, database act as middleware

Widget which use rtdb are :

* Bd
* List
* Plot
* Gauge
* List
* Map

TODO
=====
[x] Map widget
[x] rtdb
[ ] subsciption on all widget using rtdb
[ ] multiple pad
[ ] test unit
[ ] bin tool for run from anywhere
[ ] gem ! (?)
