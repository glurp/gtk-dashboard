
###########################################################################################
#     EPlot : scrolling curves : one or several masure (rtdb variable(s))
###########################################################################################
# 
class EPlot < W
    def initialize(app,period,text,config) 
        super(app,period,text)
        @config=config
    end
    def realize()
        @config[:presentation].each {|n,c| c[:data]= [[0,0]] if c.kind_of? Hash }
        @w=nil
        config=@config[:config]
        @app.cell_hspan(3,@app.box {
            @w=@app.plot(config[:size].first,config[:size].last-17,@config[:presentation],@config[:config]||{})
            @lab=@app.label(" ")
        })
    end
    def update()
        v=0
        gvalue=[]
        if @config[:generation] 
            @config[:generation].each {|(name,proc)|
                @w.scroll_data(name,v=proc.call())
                svalue=@config[:presentation][name][:format] % v
                gvalue << svalue
            }
            @lab.text = gvalue.join(" | ")
        else
            @config[:presentation].keys.each_with_index {|name,i|
                value=$rtdb.get_variable(name.to_sym).read_as_float
                @w.scroll_data(name,value)
                svalue=@config[:presentation][name][:format] % value
                gvalue << svalue
                #{@w.draw_text(0,5+i*10,svalue,1.5,@config[:presentation][name][:color])}
            }
            @lab.text = gvalue.join(" | ")
        end

    end
end

