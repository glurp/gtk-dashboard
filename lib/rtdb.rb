

class RTDB
    def initialize(dico)
        build(dico)
        @for_start=[]
        @period=Hash.new {|h,k| h[k]=[0,[]]}
        @executor_order=[]
    end
    def self.newversion(oldrtdb,dico,aprod)
      nbd=RTDB.new(dico)
      oldrtdb.stop
      nbd.init_from(oldrtdb)
      nbd.create_producer(aprod)
      nbd.start
      nbd
    end

    def build(dico)
        @dico={}
        dico.each {|n,c| @dico[n]=Var.new(n,c)}
    end    
    def init_from(oldbdttr)
        oldbdttr.each_var {|n,v| var=@dico[n]; var.set_value(v.read) if var}
    end
    def each_var
        @dico.each {|n,v| yield(n,v) rescue puts("ERROR on reinit #{v} : #{$!}") }
    end
    def set_value(name,value)
        @dico[name].set_value(value) rescue puts("ERROR set_value(#{name},#{value}) : #{$!} // #{stack}") 
    end
    def get_variable(name) @dico[name] end
    def read(name) @dico[name].read() end
    def observ(observer,name) 
        @dico[name].observ(observer) 
    end

    ############################ Producer manager
    def create_producer(aprod)
        aprod.each do |dico|
            clazz=dico[:type]
            dico.delete(:type)
            clazz.new(self,dico)
        end
    end
    def register(producer,period)
        @period[period.to_f].last << producer
        @executor_order=@period.keys.sort
    end

    def register_for_start(prod)
        @for_start << prod
    end
    def start()
        @for_start.each {|prod|  ; prod.start rescue puts("ERROR :start() of produceur {[prod.inspect} : #{$!}") }
    end
    def stop()
        @for_start.each {|prod| prod.stop rescue "" }
    end
    def excutor(now)
        @executor_order.each do |p| 
            top=@period[p]
            if (top.first + p) < now
                top.last.each {|prod| prod.execute() rescue puts("ERROR: execut() on #{prod.inspect} \n #{$!}") }
                top[0]=now
            end
        end
    end
end

class Var
    def initialize(name,config)
        @name=name
        @value= config[:value] || 0
        @observer={}
    end
    def observ(observer) 
        if @observer.respond_to?(:event) 
            @observer[observer] = true 
        else
            puts("ERROR observer not respond to #event method : #{observer.inspect}") 
        end
    end
    def set_value(v)
        if v.kind_of?(String) && !@value.kind_of?(String)
          v=@value.kind_of?(Float) ? v.to_f : v.to_i
        end
        if @value.class != v.class
            puts("ERROR: #{@name}.set_value(#{v}) : type incompatible : #{@value.class} /=> #{@v.class} // #{stack}") 
        else
            @value=v 
            @observer.each {|o| 
                o.event(@name,@value) rescue puts("ERROR Event(#{@name} / #{@value})  => #{o.inspect} : #{$!}")
            } 
        end
    end
    def read()           @value  end
    def read_as_int()    @value.to_i end
    def read_as_string() @value.to_s end
    def read_as_float()  @value.to_f end
end
