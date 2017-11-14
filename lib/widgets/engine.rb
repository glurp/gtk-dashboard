###########################################################################################
#     Class E :  widgets engine 
###########################################################################################
class E
  def list(period,txt,config)     @l[[@lastrow,@lastcol]] = EList.new(@app,period,txt,config)  end
  def bd(period,txt,cmd)     @l[[@lastrow,@lastcol]] = ERtdb.new(@app,period,txt,cmd)  end
  def nb(period,txt,cmd)     @l[[@lastrow,@lastcol]] = ENb.new(@app,period,txt,cmd)  end
  def fsize(period,txt,cmd)   @l[[@lastrow,@lastcol]] = EFSize.new(@app,period,txt,cmd) end 
  def plot(period,txt,config)   @l[[@lastrow,@lastcol]] = EPlot.new(@app,period,txt,config) end 
  def list(period,txt,config)     @l[[@lastrow,@lastcol]] = EList.new(@app,period,txt,config)  end
  def gauge(period,txt,config)    @l[[@lastrow,@lastcol]] = EGauge.new(@app,period,txt,config)  end
  def widget(period,txt,config)   @l[[@lastrow,@lastcol]] = EWidget.new(@app,period,txt,config) end 

  def initialize(app)
      @app=app
      @ltime=0
      @l= {}
  end
  def set(norow,nocol)
      @lastrow=norow
      @lastcol=nocol
  end
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



