class EstilistasController < ApplicationController

	def mainest
		if autorizado("Estilista")
		end
		id_estilista = session[:persona_id]

		persona = Person.find_by(id: id_estilista)

		@nombre = persona.nombre

		id_estilista = Stylist.find_by(person_id: session[:persona_id]).id

		@citassol = Appointment.where(stylist_id: id_estilista , estado: 0)
	end

	def agendaest
		if autorizado("Estilista")
		end
	end

	def agendaestnew
		if autorizado("Estilista")
		end
		datos = params.permit(:fecha,:horain,:horafin,:lapso)

		inicial= datos[:horain].to_time.hour* 60 + datos[:horain].to_time.min
		final= datos[:horafin].to_time.hour* 60 + datos[:horafin].to_time.min
		lapso= datos[:lapso].to_time.hour* 60 + datos[:lapso].to_time.min

		var = (final - inicial) / lapso

		horainicio = inicial
		id_est = session[:persona_id]

		estilista = Stylist.find_by(person_id: id_est)

		for i in 0..var-1
			horario = Schedule.new

			horario.fecha = datos[:fecha]
			horario.hora_inicio = ((inicial/60).to_s + ":" + (inicial%60).to_s ).to_time
			inicial+= lapso
			horario.hora_fin = ((inicial/60).to_s + ":" + (inicial%60).to_s ).to_time
			horario.stylist_id = estilista.id

			if horario.save
                        	flash[:notice] = "Horario agregado exitosamente"
                        	#redirect_to agendaest_path
                        end
		end
	end

	def citaspest
		if autorizado("Estilista")
		end 

		id_estilista = Stylist.find_by(person_id: session[:persona_id]).id 
		@citasp = Appointment.where(stylist_id: id_estilista , estado: 0)
	end

	def confirmarcita
		if autorizado("Estilista")
		end


		cita = Appointment.find_by(id: confirmarcita_params[:id])

		puts cita.hora_inicio

		if confirmarcita_params[:confirmar]== "1"
			cita.estado=1

		end

		if confirmarcita_params[:cancelar]== "2"
			cita.estado=2
		end

		if cita.save
			redirect_to citaspest_path
		end
	end

	def cortesest
		if autorizado("Estilista")
		end
		@haircut = Haircut.new
		@cortes = Haircut.all.order("created_at ASC")	
		@cut = Haircut.all.order("created_at ASC")	
	end

	def agregarcorte
		if autorizado("Estilista")
		end
		corte = Haircut.new agregarcorte_params

		if corte.save
			id_estilista = session[:persona_id]
			estilista = Stylist.find_by(person_id: id_estilista)
			corte = Haircut.find_by(id: corte.id)
			cortest = HaircutStylist.new
			cortest.stylist_id = estilista.id
			cortest.haircut_id = corte.id
			cortest.save
			redirect_to cortesest_path
		end
	end

	def perfilest
		if autorizado("Estilista")
		end

		id_estilista = session[:persona_id]

		@persona = Person.find_by(id: id_estilista)
		@estilista = Stylist.find_by(person_id: id_estilista)
		@ubicacion = Ubication.find_by(id: @persona.ubication_id)
	end

	def editarestilista
		if autorizado("Estilista")
		end


		datos = updateestilista_params


		id_estilista = session[:persona_id]

		ubicacion = Ubication.new
		ubicacion.direccion = updateestilistau_params[:direccion]
		ubicacion.barrio = updateestilistau_params[:barrio]

		if ubicacion.save
			persona = Person.find_by(id: id_estilista) 
			persona.nombre = datos[:nombre]
			persona.apellido = datos[:apellido]
			persona.fecha_nacimiento = datos[:fecha_nacimiento]
			persona.telefono_movil = datos[:telefono_movil]
			persona.telefono_fijo = datos[:telefono_fijo]
			persona.foto_perfil = datos[:foto_perfil]
			persona.ubication_id = ubicacion.id

			estilista = Stylist.find_by(person_id: id_estilista)
			estilista.correo_electronico = updateestilistad_params[:correo_electronico]

			if estilista.save and persona.save
				flash[:notice] = "Se actualizaron los datos con éxito"
				redirect_to perfilest_path
			end
		end

	end 

	def verexpest
		if autorizado("Estilista")
		end

		@experience = Experience.new
		@experiencias = Experience.all.order("created_at ASC")
		@experienciasm = Experience.all.order("created_at ASC")
	end

	def nuevaverexpest
		if autorizado("Estilista")
		end

		experiencia = Experience.new nuevaexperiencia_params
		experiencia.person_id = session[:persona_id]

		if experiencia.save
			redirect_to verexpest_path
		end

	end

	def horarios
		if autorizado("Estilista")
		end
		@schedules = Schedule.all.order("created_at ASC")
	end

	private

	def updateestilista_params
		params.require(:person).permit(:nombre, :apellido, :fecha_nacimiento, :telefono_movil, :telefono_fijo, :foto_perfil)
	end

	def updateestilistad_params
		params.require(:stylist).permit(:correo_electronico)
	end

	def updateestilistau_params
		params.require(:ubication).permit(:barrio, :direccion)
	end

	def nuevaexperiencia_params
		params.require(:experience).permit(:comentario,:foto_exp)
	end

	def agregarcorte_params
		params.require(:haircut).permit(:nombre_corte,:descripcion,:foto)
	end

	def confirmarcita_params
		params.permit(:confirmar,:cancelar,:id)
	end	

	def corte_params
		params.permit(:id)
	end
end
