###########################################################################################
#     EList : list de valeur, in text, one colonne : "name : formatted-value"
###########################################################################################
# 

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

