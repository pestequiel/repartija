def main 
	Preparar_listas()
	Separar_lista()

	$acreedores.each do |a|
		$acumulado = 0
		puts "Para acreedor: " + a.to_s
		$deudores.map! { |d|
			if(d > 0)
				puts "el deudor: " + ( $deudores.index( d ) + 1 ).to_s
				$acumulado += d
				$resto = $acumulado + a
				if( $resto > 0 && $resto < $pago_individual)
					puts "Paga: " + ($pago_individual - $resto).to_s
					d = $resto
				elsif ( $resto > $pago_individual)
					puts "otro" + $pago_individual.to_s
					d = $pago_individual
				else
					puts "paga: " + $pago_individual.to_s
					d = 0
				end
			end
		}
		#$deudores.delete_if { |e| e < 0}
		puts $deudores.to_s
	end 
end

def Preparar_listas()
	$aportes = [73,27,0,0,0,0,0,0,0,0]
	puts $aportes.to_s
	puts "Total: " 
	puts $total = $aportes.reduce(:+)
	puts "Pago individual: " 
	puts $pago_individual = $total/$aportes.count
	$saldos = $aportes.map {|e| $pago_individual - e }
end

def Separar_lista()
	$acreedores, $deudores = $saldos.partition { |e| e < 0 }
	puts "acreedores: "
	puts $acreedores.to_s
	puts "deudores: "
	puts $deudores.to_s	
end

main()