###########################################################################################
#     EMap : Schow a 2 numeriques value as x/yposition in raster  image
###########################################################################################
# 

class EMap < W
    def initialize(app,period,text,config) 
        super(app,period,text)
        @config=config
        @width,@height=@config[:size]
        @r=[10,@width/100].max
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
        w.draw_image(0,0,@config[:image]) 
        w.draw_circle(@x,@y,@r, @config[:fg],@config[:bg],2)
        if @config[:format]
          w.draw_text_center(@width/2,10,@config[:format] % [@vx,@vy],1,@config[:fg],@config[:bg])
        end
    end
    def update()
        @vx=$rtdb.read(@config[:varnames].first).to_f
        @vy=$rtdb.read(@config[:varnames].last).to_f
        if @config[:minmax]
          @x=linear(@vx,@config[:minmax].first, [0,@width])
          @y=linear(@vy,@config[:minmax].last, [0,@height])
        else
          @x=@vx
          @y=@vy
        end
        @w.redraw
    end
end

