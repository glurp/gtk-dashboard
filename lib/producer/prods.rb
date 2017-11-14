###########################################################################
#   Producer: parent of all producer
###########################################################################
class Producer
    def write(name,value) @rtdb.set_value(name,value) end

    def initialize(rtdb,config)
        @rtdb=rtdb
        config.each {|name,value| instance_variable_set("@"+name.to_s,value) }         
        if config[:period]
            rtdb.register(self,@period)
        else
            rtdb.register_for_start(self)
        end
    end
    def start() end
    def stop() end
    def execute() end
    def traitment(varray)
       if defined?(@index)
           @index.zip(@to) { |i,name| write(name,varray[i]) }
       else
           write(@to,varray.first)
       end
    end
end

#
# Execute une commande systeme, periodiquement (schedule by rtdb)
#
class ProdSystem < Producer
    def execute()
        `#{@cmd}`.each_line {|line|
           traitment(line.strip.split(/(\s+)|[,:;]/))
        }
    end
end

#
# Run a pipe and read his output. no sceduling
#
class ProdPipeNum < Producer
    def start
        @th=Thread.new {
            IO.popen(@cmd,"r") {|sout| 
                sout.gets
                while !sout.eof
                   str=sout.gets
                   a=str.strip.split(/(\s+)|[,:;]/).map {|v| v=~ /\./ ? v.to_f : v.to_i}
                   traitment(a)
                end
            }
        }
    end
    def stop
        @th.kill
        @th.join
    end
end

class ProdRuby < Producer
    def execute()
        begin
            value=@cmd.call()
            traitment(value.kind_of?(Array) ? value : [value])
        rescue Exception => e
            puts "ERROR: RubyProducer to #{@to} : #{e}"
        end
    end
end

