require 'Ruiby'
require_relative "rtdb.rb"
Dir.glob("producer/*.rb").each {|fn| p fn ;  require_relative fn }
require_relative "widgets/engine.rb"
Dir.glob("widgets/*.rb").each {|fn| p fn ; require_relative fn }

$lfile= "lshow.rb"
$rtdb=RTDB.new({})

Thread.abort_on_exception=true

def reload()
  $dtime=File.mtime($lfile).to_i
  puts "eval #{$lfile} ..."
  h=eval(File.read($lfile))
  puts "eval #{$lfile} done."
  h
rescue Exception => e
  error(e)
  nil
end
def stack
    "\n  #{caller[2..-1].join("\n  ")}"
end

module Ruiby_dsl 
    def prefixe() label("Hello",font: "Arial bold 10") ; separator  end
    def postfixe() separator ; button("Refresh") { @e.update(true) } end
end

$BG="#333"

Ruiby.app width: 10, height:10, title: "Show" do
    def reinit(d)
        puts "\n\n\n\n"
        e=E.new(self)
        $rtdb=RTDB.newversion($rtdb,d[:rtdb],d[:production])        
        @e=e
        d[:window][:page1].each {|row,hrow| hrow.each {|(col,bloc)|
             e.set(row,col)
             cmd= bloc.call(e)             
        } }
        e.realize
        def_style(d[:css]) if d[:css]
    end
    
    $stack=stack do
    end

    reinit(reload())

    anim(100) {
      @e.update if @e             
      $rtdb.excutor(Time.now.to_f)
    }

    anim(1000) {
      if File.mtime($lfile).to_i != $dtime
          d=reload()
          reinit(d) if d
      end
    }

end

