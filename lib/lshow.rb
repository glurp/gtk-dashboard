# this configuration file should work on unix*/windows
$BG="#122"
{
    rtdb: {
        aa: {type: Float, value: 0}, 
        bb: {type: Float, value: 0},
        cc: {type: Float, value: 0},
        usr: {}, 
        idle: {},
        sys: {},
        aaa: {},
    },
    production: [
        {type: ProdSystem, period: 1, cmd: "ruby -e 'Time.now.sec.times { p 1 }'", to: :aa },
        {type: ProdPipeNum,  cmd: "ruby -e 'loop { a=Time.now.sec.to_s ; puts a+' '+a+' '+a+' '+a ; sleep(1)}'", index: [0,1,2,3], to: %i{usr sys idle aaa} },
        {type: ProdRuby,  period: 0.2, cmd: proc {(Time.now.to_f*100).to_i % 100 }, to: :bb },
    ],
    window: {
     page1: {
        1=> {
          1 =>  proc {|e| e.bd(1,"usr",:usr)  },
          2 =>  proc {|e| e.bd(1,"sys","sys")  },
          3 =>  proc {|e| e.bd(1,"idle",:idle)  },
        },
        2 =>  {
	        1 =>  proc {|e| e.plot(0.1,"curve",{
                    config: {bg: $BG, size: [200,70]},
                    presentation: {
                        "a" => { xminmax:[0,150], yminmax:[0,100], color: "#DDFF00" , maxlendata: 150, format: "Kg=%.0f"}
                    },
                    generation:  { "a" => proc {(Time.now.to_f*100).to_i % 100 } },
                  } ) },
            2  => proc {|e| e.list(1,"Title",{
                    aa: {text: "eeee", format: "%3d C°"},
                    bb: {text: ":bb", format: "%3d Km/h"},
                  })}
        },
        3 =>  {
	        1 =>  proc {|e| e.plot(0.1,"curve",{
                        config:  {bg: $BG, size: [200,160]},
                        presentation: {
                            "aa" => { xminmax:[0,150], yminmax:[0,60], color: "#44AA00" , maxlendata: 150, format: "v=%.0f"},
                            "bb" => { xminmax:[0,150], yminmax:[0,100], color: "#FF0000" , maxlendata: 150, format: "u=%.0f"},
                        }
                    }
                  )},
            2  => proc {|e| e.gauge(0.7,"mesure",{
                    size: [160,160],
                    type: :cadrant,
                    angle:50,
                    bg: $BG,
                    fg: "#FFF",
                    color: "#FF0",
                    varname: :bb,
                    format: "V: %2.0f Km/h",
                    minmax: [0,100],
                  })},
            3  => proc {|e| e.gauge(0.7,"mesure",{
                    size: [160,160],
                    type: :speed,
                    angle:50,
                    bg: $BG,
                    fg: "#FFF",
                    color: "#FF0",
                    varname: :bb,
                    format: "Speed: %2.0f Km/h",
                    minmax: [0,100],
                  })}
        },
        4 =>  {
            1  => proc {|e| e.gauge(0.7,"hbar",{
                    size: [200,160],
                    type: :hbar,
                    bg: $BG,
                    fg: "#FFA",
                    color: "#FF0",
                    varname: :bb,
                    format: "hbar: %2.0f",
                    minmax: [0,100],
                  })},
            2  => proc {|e| e.gauge(0.7,"vbar",{
                    size: [160,160],
                    type: :vbar,
                    angle:50,
                    bg: $BG,
                    fg: "#080",
                    color: "#FF0",
                    varname: :bb,
                    format: "Speed: %2.0f Km/h",
                    minmax: [0,100],
                  })}
        }
     }
    },
    css: <<EEND
* {background: #{$BG} ; color: #FFF} 
.button { 
  background: #{$BG} ;
  background-image: none;
  color: #CCC;
  padding: 3px 7px 2px 5px;
  border-width: 0px;
  -GtkButton-shadow-type:none;
}
GtkSeparator {  color: #FFC ; padding: 2px 0px 10px 0px;}
GtkLabel { color: #FF0 ;background: #000;  }
EEND
}

