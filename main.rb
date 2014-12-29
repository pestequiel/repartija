require 'bundler'
Bundler.setup
require 'sinatra'


configure do
  enable :sessions
  set :session_secret, "My session secret"
  set :aportes, {}
  set :saldos, {}
  set :acreedores, {}
  set :deudores, {}
end

helpers do
    
  def title
    @title || "Repartija"
  end
  
  def set_aportes(uno, dos)
    settings.aportes[uno.to_sym] ||= dos
  end

  def hard_code_aportes()
    settings.aportes = { 
      "Bufarra" => 40, 
      "Martin" => 600,  
      "Joni" => 150,  
      "Pedro" => 0,  
      "Cachi" => 0, 
      "Gisela" => 200,
      "Eze" => 0  
    }
  end

  def preparar_listas(aportes)
    puts
    puts "Total: " 
    puts @total = aportes.values.reduce(:+)
    puts "Pago individual: " 
    puts @pago_individual = @total/aportes.length
    settings.saldos = aportes.inject({}){ |hash, (k, v)| hash.merge( k.to_sym => @pago_individual - v )  }
  end

  def separar_lista()
    settings.acreedores, settings.deudores = settings.saldos.partition { |_,e| e < 0 }
    settings.acreedores = settings.acreedores.to_h 
    settings.deudores = settings.deudores.to_h
    puts "acreedores: "
    puts settings.acreedores.to_s
    puts "deudores: "
    puts settings.deudores.to_s 
  end

  def calcular()
    settings.acreedores.each do |nombre_acr, monto_acr|
      @monto_acr_actual = monto_acr
      @acumulado = 0
      puts'-------------------------------------------------------------------------'
      puts "Para acreedor: " + nombre_acr.to_s + monto_acr.to_s
      settings.deudores.each  do |k, v| 
        #puts "monto acreedor: " + monto_acr.to_s
        #puts
        if(v > 0 && @monto_acr_actual < 0)
          puts "el deudor: " + k.to_s
          @acumulado += v
          @resta_pagar = @acumulado + monto_acr
          #puts "acumulado: " + @acumulado.to_s
          #puts "resta_pagar: " + @resta_pagar.to_s

          if( @resta_pagar > 0 && @resta_pagar < @pago_individual)
            puts "Paga: " + (@pago_individual - @resta_pagar).to_s
            settings.deudores[k] = @resta_pagar
            settings.acreedores[nombre_acr] += @pago_individual - @resta_pagar
            @monto_acr_actual = settings.acreedores[nombre_acr]
          elsif (v < @pago_individual)
            puts "ppaga: " + v.to_s
            settings.deudores[k] = 0
            settings.acreedores[nombre_acr] += v
            @monto_acr_actual = settings.acreedores[nombre_acr]

          elsif (@resta_pagar <= 0)
            puts "paga: " + @pago_individual.to_s
            settings.deudores[k] = 0
            settings.acreedores[nombre_acr] += @pago_individual
            @monto_acr_actual = settings.acreedores[nombre_acr]

          end
        end
        #puts settings.acreedores.to_s
        #puts settings.deudores.to_s
      end 
    end
    puts'-------------------------------------------------------------------------' 
  end
end

get '/' do
  erb :form
end

post '/' do
  @title = "Resultado"
  @nombre = params[:nombre].chomp
  #set_aportes(@nombre, params[:cantidad].to_i)
  hard_code_aportes()

#  if session[@nombre.to_sym].nil?
#    session[@nombre.to_sym] = params[:cantidad].to_i
#    puts session
#  end

  @finished = params[:finished]
  if @finished 
    preparar_listas(settings.aportes)
    separar_lista()
    calcular()
    @saldos = settings.saldos
    erb :result
  else
    erb :form
  end
end
