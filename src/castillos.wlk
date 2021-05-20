class Castillo{
	
	var property estabilidad = 100
	var pais
	var tamanioMuralla
	var property derrota = false
	var property bufones=[]
	var property coleccionGuardias = [new Guardia(capacidad = 1, lugar = "muralla"), new Guardia(capacidad = 1, lugar = "muralla"), new Guardia(capacidad = 1, lugar = "calles"), new Guardia(capacidad = 1, lugar = "calles"),
									  new Guardia(capacidad = 2, lugar = "calles"), new Guardia(capacidad = 2, lugar = "cuartel"), new Guardia(capacidad = 2, lugar = "cuartel"), 
									  new Guardia(capacidad = 3, lugar = "muralla"), new Guardia(capacidad = 3, lugar = "cuartel")]  
	var property coleccionBurocratas = []
	
	const esclavos = [new Esclavo(), new Esclavo(),	new Esclavo()]
	
	const muralla = new Wall()
	const cuartel = new Barracks()
	const calles = new Streets()
	const masterHerrero = new Herrero()
	
	method seFormaBurocracia(){
		return coleccionBurocratas.addAll(diferenciarBurocratas.coleccionBuro().filter{burocrata => burocrata.pais() == pais})
	}
	
	method reclutarSoldados(){
		cuartel.terminarEntrenamiento(self)
	}
	
	method puebloFeliz(){
		if (estabilidad > 80) {calles.alentarALosGuardias(self)}
	}
	
	method contratarHerrero(){
		if(masterHerrero.necesitado()) {masterHerrero.contratar()}
	}
	
	method prepararDefensas(){
		if (coleccionBurocratas.count{burocrata => burocrata.panico()} > 0) {
		} else {
		estabilidad += 7 * coleccionBurocratas.size()
		estabilidad += coleccionGuardias.sum({guard => guard.capacidad()})
		estabilidad = estabilidad.min(100)
		muralla.defensa(esclavos.sum{esclavo => esclavo.repararMuralla()})
		if (masterHerrero.contratado()) {masterHerrero.ayudarEnDefensas(self)}
		}
	}
	
	method recibeAtaque(){
		var danio
		danio = 70 - tamanioMuralla - muralla.defensa() - cuartel.defensa() - calles.defensa() - coleccionGuardias.sum({guard => guard.capacidad()})
		estabilidad -= danio
		estabilidad = estabilidad.max(0)
		bufones.forEach({buf=>buf.aburre()})
		coleccionGuardias.forEach{guard => guard.agotarse(danio)}
		
		coleccionBurocratas.filter({burocrata => burocrata.esJoven()})
						   .forEach({burocrata => burocrata.asustarse()})
		
		if (danio > 15) {muralla.pierdeResistencia()}
		if (estabilidad < 50) {masterHerrero.necesitarServicio()}
		if (estabilidad < 1)  {derrota = true}
		if (esclavos.size() > 0){                       
			esclavos.remove(esclavos.last())
		}
	}
	
	method secuestrarEsclavo(){
		esclavos.add(new Esclavo())
	}
	
	method fiesta(){
		bufones.forEach{buf=>buf.fiestasbu()}
		estabilidad += 3 * coleccionBurocratas.size() + bufones.sum({buf=>buf.diversion()})
		estabilidad = estabilidad.min(100)
		coleccionGuardias.forEach({guardia => guardia.relajarse()})
		coleccionBurocratas.forEach({burocrata => burocrata.relajarse()})
	}
	
	method consultaEstabilidad(){
		return pais + " " + estabilidad
	}
	
	method consultaAgotamiento(){	//para testeos
		return coleccionGuardias.map{guardia => guardia.agotamiento()}
	}
	
	method consultaCapacidad(){	//para testeos
		return coleccionGuardias.map{guardia => guardia.capacidad()}
	}
	method agregarbufon(){
		bufones.add(new Bufon(diversion = 2))
	}
	
	method agregarbufoncreado(consola){
		bufones.add(consola)
	}	
	method cantidadEsclavos(){
		return esclavos.size()
	}
}

class Bufon{
var property diversion
	method fiestasbu(){
		diversion += 2
	}
	method aburre(){
		diversion=0
		return diversion
	}
}
class Esclavo{                  
	method repararMuralla(){
		return 1
	}
}

const castilloFrances = new Castillo(pais = "Francia" , tamanioMuralla = 15)
const castilloIngles = new Castillo(pais = "Inglaterra" , tamanioMuralla = 20)
const castilloAleman = new Castillo(pais = "Alemania" , tamanioMuralla = 12)

class Rey{
	
	var property reino
	var property esposa
	
	method atacarA(castillo){
		if (castillo.cantidadEsclavos() > 0){
			reino.secuestrarEsclavo()
		}	
		castillo.recibeAtaque()	
	}
	
	method consultar(){
		return todocastillos.consultar()
	}
	
	method hacerFiesta(){
		if (reino.estabilidad() > 25) {reino.fiesta()}
		if (reino.estabilidad() > 50) {esposa.aumentaPopularidad()}
	}
}

const carlomagno = new Rey(reino = castilloFrances, esposa = juanaDeArco)
const enrique = new Rey(reino = castilloIngles, esposa = isabel)
const barbaroja = new Rey(reino = castilloAleman, esposa = hannah)

object todocastillos{
	
	var property castillos = [castilloAleman , castilloIngles , castilloFrances]
	
	method consultar(){
		return castillos.map{castillo => castillo.consultaEstabilidad()}
	}
}

class Guardia{
	
	var property capacidad
	var property lugar
	var property agotamiento = 0
	
	method agotarse(x){
		agotamiento += (x*13/10)
		agotamiento = agotamiento.min(100)
		agotamiento = agotamiento.truncate(0)
	}
	
	method relajarse(){
		agotamiento = agotamiento - 15 * capacidad
		agotamiento = agotamiento.max(0)
	}
	
	method mejoraDeArmas(){
		capacidad = 6
	}
}

class Burocrata{
	
	var property nombre
	var property fechaDeNacimiento
	var property aniosDeExp
	var property pais
	var property panico = false
	
	method esJoven(){
		return (fechaDeNacimiento > 1290)
	}
	
	method asustarse(){
		panico = true
	}
	
	method relajarse(){
		panico = false
	}
}

object diferenciarBurocratas{
	
	var property coleccionBuro = [new Burocrata(nombre = "Erick", fechaDeNacimiento = 1270, aniosDeExp = 30, pais = "Alemania"), new Burocrata(nombre = "Kernel", fechaDeNacimiento = 1295, aniosDeExp = 5, pais = "Alemania"), new Burocrata(nombre = "Barter", fechaDeNacimiento = 1245, aniosDeExp = 35, pais = "Alemania"),
								  new Burocrata(nombre = "Isek", fechaDeNacimiento = 1260, aniosDeExp = 40, pais = "Alemania"), new Burocrata(nombre = "Edward", fechaDeNacimiento = 1260, aniosDeExp = 40, pais = "Inglaterra"), new Burocrata(nombre = "Fastolf", fechaDeNacimiento = 1298, aniosDeExp = 2, pais = "Inglaterra"),
								  new Burocrata(nombre = "Joan", fechaDeNacimiento = 1300, aniosDeExp = 0, pais = "Francia"), new Burocrata(nombre = "Philip", fechaDeNacimiento = 1270, aniosDeExp = 30, pais = "Francia"), new Burocrata(nombre = "Luis", fechaDeNacimiento = 1290, aniosDeExp = 10, pais = "Francia")]
}

class Reina{
	
	var property reino
	var property popularidad = 10
	
	method aumentaPopularidad(){
		popularidad += 20
		popularidad = popularidad.min(100)
	}
	
	method reclutarConCarisma(){
		if (popularidad >= 60) {reino.coleccionGuardias().add(new Guardia(capacidad = 1, lugar = "muralla"))}
		popularidad -= 15
	}
}

const juanaDeArco = new Reina(reino = castilloFrances)
const isabel = new Reina(reino = castilloIngles)
const hannah = new Reina(reino = castilloAleman)

class Herrero{
	
	var property contratado = false
	var property necesitado = false
	
	method necesitarServicio(){
		necesitado = true
	}
	
	method contratar(){
		contratado = true
	}
	
	method ayudarEnDefensas(castillo){
		castillo.coleccionGuardias().filter({guard => guard.capacidad() == 3})
									.forEach({guard => guard.mejoraDeArmas()})
	}
}

class Barracks{
	var property defensa = 7
	
	method terminarEntrenamiento(castillo){
		castillo.coleccionGuardias().add(new Guardia(capacidad = 2, lugar = "cuartel"))
	}
}

class Streets{
	var property defensa = 1
	
	method alentarALosGuardias(castillo){
		castillo.coleccionGuardias().forEach({guardia => guardia.relajarse()})
	}
}

class Wall{
	var property defensa = 13
	
	method defensa(sumar){
		defensa += sumar
		defensa = defensa.min(13)
	}
	method pierdeResistencia(){
		defensa -= 2
		defensa = defensa.max(5)
	}
}
