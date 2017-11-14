
###########################################################################################
#     Class E : moteur de widgets
###########################################################################################
class E
  def initialize(app)
      @app=app
      @ltime=0
      @l= {}
  end
  def set(norow,nocol)
      @lastrow=norow
      @lastcol=nocol
  end
  def list(period,txt,config)     @l[[@lastrow,@lastcol]] = EList.new(@app,period,txt,config)  end
  def bd(period,txt,cmd)     @l[[@lastrow,@lastcol]] = ERtdb.new(@app,period,txt,cmd)  end
  def nb(period,txt,cmd)     @l[[@lastrow,@lastcol]] = ENb.new(@app,period,txt,cmd)  end
  def fsize(period,txt,cmd)   @l[[@lastrow,@lastcol]] = EFSize.new(@app,period,txt,cmd) end 
  def plot(period,txt,config)   @l[[@lastrow,@lastcol]] = EPlot.new(@app,period,txt,config) end 
  def list(period,txt,config)     @l[[@lastrow,@lastcol]] = EList.new(@app,period,txt,config)  end
  def gauge(period,txt,config)    @l[[@lastrow,@lastcol]] = EGauge.new(@app,period,txt,config)  end
  def widget(period,txt,config)   @l[[@lastrow,@lastcol]] = EWidget.new(@app,period,txt,config) end 
  def realize()
      @app.clear_append_to($stack) {
        @app.prefixe
        @app.table(0,0) do
            (1..20).each {|r| @app.row { (1..10).each {|c| 
                k=[r,c]
                @l[k].realize() if @l[k]
            } } }
        end
        @app.postfixe
      }
      @l.values.each {|e| e.update }
  end
  def update(force=false)
       @l.each do |name,e| 
          begin
            e.update  if force || e.to_be_updated() 
          rescue Exception => e
            @l.delete(name)
            @app.error(e)
          end
      end 
  end
end


##################### Superclass des widgets

class W
  def initialize(app,p=nil,t=nil,c=nil)
      @app,@p,@t,@c=app,p,t,c
      @ltime=0
  end
  def to_be_updated
    now=Time.now.to_f
    if (@ltime+@p)< now
        @ltime=now
        true
    else
        false
    end
  end
  def update()
  end
end

###########################################################################################
#     Class Widgets
###########################################################################################

# EWidget: affiche le widget specifié par proc, sur les 3 colonnes
class EWidget < W
    def initialize(app,period,text,config)
        super(app,period,text)
        @config=config
    end
    def realize()
        @w=nil
        @app.cell_hspan(3,@app.box {
            @w=@config[:presentation].call(@app,self)
        })
    end
    def update()
        @config[:generation].call(@w)
    end
end

# ERtdb : affichae d'une valeur de variable, en text
class ERtdb < W
    def realize()
        @app.cell_right(@app.label(@t))
        @app.cell(@app.label(" : "))
        @app.cell_left(@w=@app.label("?"))
        @var=$rtdb.get_variable(@c.to_sym)
    end
    def update()
        @w.text= @var.read.to_s
    end
end


# Enb: Execute une commande et compte le nombre de lignes du resultat
class ENb < W
    def realize()
        @app.cell_right(@app.label(@t))
        @app.cell(@app.label(" : "))
        @app.cell_left(@w=@app.label("?"))
    end
    def update()
        @w.text=`#{(@c)}`.split(/\r?\n/).size.to_s
    end
end

# EZize: scan une liste de nom de fichier et renvoie la tailles cumullés des fichiers
class EFSize < W
    def realize()
        @value=0
        @app.cell_right(@app.label(@t))
        @app.cell(@app.label(" : "))
        @app.cell_left(@w=@app.label("?"))
    end
    def update()
        size=0
        Dir.glob(@c).each {|fn| size+=File.size(fn) if File.file?(fn) }
        delta=size-@value
        @value=size
        sdelta= if delta<1000 then delta.to_s elsif
          delta < 1000_000 then "#{delta/1000} KB" elsif
          delta < 1000_000_000 then "#{delta/1000_000} MB" else
            "#{delta/1000_000_000} GB" 
        end
        @w.text=sdelta
    end
end

# EText: execute un bloc ruby
class EText < W
    def realize()
        @app.cell_right(@app.label(@t))
        @app.cell(@app.label(" : "))
        @app.cell_left(@w=@app.label("?"))
    end
    def update()
        @w.text=@c.call.to_s
    end
end

# EList : liste de valeur
class EList < W
    def initialize(app,period,text,config) 
        super(app,period,text)
        @config=config
        @hw={}
    end
    def realize()
        @app.cell_hspan(3,@app.box {
            @app.flow {
            @app.labeli(" ")
            @app.frame(@t) {
                @w=@app.table(0,0) {
                    @config.each {|name,h|
                    @app.row {
                        @app.cell_right(@app.label(h[:text]))
                        @app.cell_left(@hw[name]=@app.label("?"))
                        @app.next_row
                    }}
                }
            }
            @app.labeli(" ")
        } } )
    end
    def update()
        @config.keys.each {|name|
            v=$rtdb.read(name)
            @hw[name].text= (@config[name][:format] || "%s" ) % v
        }
    end
end


# EPlot : courbe(s) type sclloscope : une ou plusieurs mesures, scrolling horisontal
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


# EGauge : affichage d'une valeur numerique dans un instrument
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

