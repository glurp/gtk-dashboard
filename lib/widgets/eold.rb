###########################################################################################
#     eold.rb : old version of dashboard, widget do acquisition...
###########################################################################################


# ERtdb : show a rtdb variable, as text, in a centered label
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


# Enb: Execute a system command and count the lines output
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

# EZize: Scan a list of filname (gloging) and show the nomber of lines off all files selected
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

# EText: Show in a label the out of a ruby bloc
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


