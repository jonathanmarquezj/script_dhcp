#! /usr/bin/env bash

function comprobar_mac {
	#MIRAR SI UNA VARIABLE ES UNA MAC
	#METODO DE EJECUCION
	#mac=$(comprobar_mac "texto del read" $mac)

	local mac=$2
        #MIRAMOS SI EL NUMERO ES ENTERO
        while [[ `echo $mac | grep -oE "\b[0-9a-zA-Z]{1,2}:[0-9a-zA-Z]{1,2}:[0-9a-zA-Z]{1,2}:[0-9a-zA-Z]{1,2}:[0-9a-zA-Z]{1,2}:[0-9a-zA-Z]{1,2}\b"` == "" ]]
        do
                read -p "$1" mac
        done
        echo "$mac"


}

function comprobar_variable_numerica {
	#MIRA SI UNA VALIABLE ES NUMERICA
	#METODO DE EJECUCION
	#numero=$(comprobar_variable_numerica "texto del read" $num)

	local num=$2
	#MIRAMOS SI EL NUMERO ES ENTERO
        while [[ `echo $num | egrep "^[0-9]+$"` == "" ]]
        do
                read -p "$1" num
        done
        echo "$num"

}

function comprobar_ip {
	#COMPRUEBA SI EL CONTENIDO ES UNA IP
	#METODO DE EJECUCION
	#contenedor=$(comprobar_ip "texto del read" "$ip")
	local ip=$2
	while [[ `echo $ip | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"` == "" ]]
	do
		read -p "$1" ip
	done
	echo "$ip"
}

function comprobar_interfaz {
	#BUSCA EN LAS INTERFACES QUE TENEMOS A VER SI ESTA LA QUE PUSO EL USUARIO
	#METODO DE EMPLEO
	#comprobar_interfaz 'eth0'

	#GUARDAMOS LAS INTERFACES EN LA VARIABLE QUITANDOLE LOS ESPACIOS INICIO Y FINAL
	interfaces=$(ip a | grep [0-9]': ' | cut -d ':' -f 2 | grep -Eo '\S*')

	if [[ ! $interfaces =~ $1 ]]
	then
		echo -e "\x1b[1;31m ERROR:\x1b[0m Esa interfaz no existe."
		read -p "Pulsa intro para ir al menu."
		./$(basename $0) && exit
	fi
}

function comprobar_campos_vacios {
        #METODOS DE EJECUCION
        #comprobar_campos_vacios "$valor1" "$valor2"  ...
        total_campos_pasados=$#
        total_campos_llenos=0

        for i in $*; do
                ((total_campos_llenos++))
        done

        if [[ $total_campos_llenos -ne $total_campos_pasados ]]
        then
		echo -e "\x1b[1;31m ERROR: No complementaste todos los campos. \x1b[0m"
		read -p "Pulse un boton para salir."
		#CON ESTO LO QUE HACEMOS ENTRAR EN EL SCRIPT Y SALIR DEL ANTERIOR, DE TAL MANERA QUE NO SE APILA
		./$(basename $0) && exit
        fi
}

function ip_reservada {
	#MUESTRA UNA TABLA CON LAS DIRECCIONES IP RESERVADAS

	#BUSCAMOS SI ESTAN EL COMENTARIO
	if [[ `cat /etc/dhcp/dhcpd.conf | grep -n "#IP RESERVADAS"` != "" ]]
	then
		#MIRAMOS EL INICIO Y EL FINAL DE LOS COMENTARIOS PARA DISMINUIR EL RANGO
		inicio_ip_reservadas=$(cat /etc/dhcp/dhcpd.conf | grep -n "#IP RESERVADAS" | cut -d ':' -f 1)
		fin_ip_reservadas=$(cat /etc/dhcp/dhcpd.conf | grep -n "#FIN IP RESERVADAS" | cut -d ':' -f 1)"p"

		echo "--------------- IP RESERVADAS --------------"
		#GUARDAMOS EL CONTENIDO DENTRO DE UNA VARIABLE
		contenedor=$(sed -n "$inicio_ip_reservadas,$fin_ip_reservadas" /etc/dhcp/dhcpd.conf)

		#CONTADORES PARA COGER EL SIGUIENTE CARACTER EN EL FOR
		contN=0
		contM=0
		contI=0

		#CONTENEDORES PARA GUARDAR EL CONTENIDO
		nombre=""
		mac=""

		for i in $contenedor
		do
			#PARA COGER EL NOMBRE
		        if [[ $contN -eq 1 ]]
		        then
		                nombre=$i
		                contN=0
		        fi

		        if [[ $i == "host" ]]
		        then
		                contN=1
		        fi

			#PARA COGER LA MAC
		        if [[ $contM -eq 1 ]]
		        then
		                mac=$i
		                contM=0
		        fi
		        if [[ $i == "ethernet" ]]
		        then
		                contM=1
		        fi

			#PARA COGER LA IP Y MOSTRAR EL RESULTADO
		        if [[ $contI -eq 1 ]]
		        then
				#BORRAMOS EL ULTIMO CARACTER, YA QUE ES ; EN MAC Y EN IP
		                echo $nombre" --> "$(echo $mac | sed 's/.$//g')" --> "$(echo $i | sed 's/.$//g')
		                contI=0
		        fi

		        if [[ $i == "fixed-address" ]]
		        then
		                contI=1
		        fi
		done

		echo "--------------------------------------------"
	fi
}









