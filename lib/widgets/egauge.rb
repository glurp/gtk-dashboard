###########################################################################################
#     EGauge : Schow a numerique value (a rtdb variable) in a instrument
#      @config[:type] give a type of widget : cadrant, speed, hbar, vbar
###########################################################################################
# 

class EGauge < W
    def initialize(app,period,text,config) 
        super(app,period,text)
        @config=config
        @width,@height=@config[:size]
        @x0=@width/2
        @y0=@height/2
        if @config[:type].to_s !~  /bar|progress/
            @config[:angle] ||= 0
            @y0=@height/2*(1+ 1-Math.sin(d2r(@config[:angle])))
            @r=[@x0,@y0].min-4
        end
        @angle=0
    end
    def realize()
        @w=nil
        @app.cell_hspan(3,@app.box {
            @w=@app.canvas(@width,@height) {
              @app.on_canvas_draw { |w,ctx| redraw(w,ctx) }
            }
        })
    end
    def redraw(w,ctx) 
        w.draw_rectangle(0,0,@width, @height,0, @config[:fg],@config[:bg], 2) 
        a=@config[:angle]
        case @config[:type]
        when :cadrant
            w.draw_arc(@x0,@y0,@r,1/4.0+a/360.0,1/4.0-a/360.0, 3, "#0F0","#888")
            x1=@x0+(@r-4)*Math.cos(@angle)
            y1=@y0+(@r-4)*Math.sin(@angle)
            w.draw_line([@x0,@y0,x1,y1],@config[:color],3)
            w.draw_text_center(@r,@height-10,@svalue,1,@config[:color])
        when :speed
            w.draw_arc(@x0,@y0,@r,1/4.0+a/360.0,1/4.0-a/360.0, 3, "#0F0","#888")
            w.draw_arc(@x0,@y0,@r,1/4.0+a/360.0,1/4.0-@angle/2*Math::PI,0,"#F00","#F00")
            w.draw_circle(@x0,@y0,@r*7/10, @config[:bg],@config[:bg],0)
            w.draw_text_center(@r,@y0,@svalue,1.5,@config[:color])
        when :hbar
            marge=10
            largeur=@height/5
            ep=1
            w.draw_rectangle(marge,@height-marge-largeur,@width-2*marge,largeur, 3, "#F00","#999",ep)
            w.draw_rectangle(marge+ep,@height-marge-largeur+ep,(@width-2*(marge+ep))*@angle,largeur-2*ep, 3, @config[:fg],@config[:fg],0)
            w.draw_text_center(@x0,@y0,@svalue,2,@config[:color])
        when :vbar
            marge=10
            ep=3
            largeur=@width/5
            h=(@height-2*(marge+ep))*@angle
            w.draw_rectangle(marge,marge,largeur,@height-2*marge, 3, "#F00","#999",ep)
            w.draw_rectangle(marge+ep,@height-marge-ep-h,largeur-2*ep,h, 3, @config[:fg],@config[:fg],ep)
            w.draw_text(marge+largeur,@y0,@svalue,1.8,@config[:color])
        end
    end
    def update()
        v=$rtdb.read(@config[:varname]).to_f
        @svalue=(@config[:format] % [v])
        if @config[:type].to_s =~  /bar|progress/
            min,max=0.0,1.0
        else
            min,max=(270-@config[:angle]),(270+@config[:angle])
        end
        vmin,vmax=@config[:minmax]
        y=(v-vmin)*(max-min)/(vmax-vmin)+min
        @angle = (@config[:type].to_s =~  /bar|progress/) ? y : d2r(y)
        @w.redraw
    end
    def d2r(a) Math::PI*(a/180.0) end
end

