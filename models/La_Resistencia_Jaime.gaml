/**
* Name: LaResistencia
* Based on the internal empty template. 
* Author: Jaime
* Tags: 
*/


model LaResistencia

global {
    int jugadores <- 10;  // Total de jugadores
    list<people> TodosJugadores <- [];
    int votos_a_favor <- 0;
    int votos_en_contra <- 0;
    int turno <- 0;  // Turno actual
    int contjugador <- 0;
    
    int misiones <- 5;
	int misionesnovotadas <- 0;
	int misionesvotadas <- 0;

    init {
        create people number: jugadores with:[Nombre::"Jugador " + (contjugador + 1)];
        create lider;
    }
    
    reflex avanzar_turno{
    	turno <- turno + 1;
    }
    
    reflex misiones{
		if (votos_en_contra >= votos_a_favor){
			misionesnovotadas <- misionesnovotadas + 1;
		} else {
			misionesvotadas <- misionesvotadas + 1;
		}
	}
}

species people {
	string Nombre;
    bool es_resistencia <- true;  // Probabilidad de ser de la resistencia
    bool ha_votado <- false;
    int yPos <- (index - 1) * 25 + 30;
    
    init{
    	add item:self to: TodosJugadores;
    }

    reflex votar when: !(ha_votado){
        if (es_resistencia) {
            votos_a_favor <- votos_a_favor + 1;
            ha_votado <- true;
        } else {
            votos_en_contra <- votos_en_contra + 1;
            ha_votado <- true;
        }
    }
    
    aspect base {
        draw ("" + Nombre + " - " + (es_resistencia ? "R" : "E")) at: {20, yPos} color: #white size: 14;
    }
}

species lider {
    init {
    	if (jugadores=5) or (jugadores=6){
    		list<people> spies <- shuffle(TodosJugadores) as list<people>;
	        spies[0].es_resistencia <- false;
	        spies[1].es_resistencia <- false;
    	}
    	if (jugadores=7) or (jugadores=8) or (jugadores=9){
    		list<people> spies <- shuffle(TodosJugadores) as list<people>;
	        spies[0].es_resistencia <- false;
	        spies[1].es_resistencia <- false;
	        spies[2].es_resistencia <- false;
    	}
    	if (jugadores=10){
    		list<people> spies <- shuffle(TodosJugadores) as list<people>;
	        spies[0].es_resistencia <- false;
	        spies[1].es_resistencia <- false;
	        spies[2].es_resistencia <- false;
	        spies[3].es_resistencia <- false;
    	}
    }
}

species tablero{
	reflex{
		if (votos_en_contra >= votos_a_favor){
			misionesnovotadas <- misionesnovotadas + 1;
		} else {
			misionesvotadas <- misionesvotadas + 1;
		}
	}
	
}


experiment my_experiment type: gui {
    output {
    	display "Documentacion" background:#black{
    		graphics "Jugadores" position:{0,0} size:{0.2,0.8} {
            	draw shape color:#darkorange;
            	int cont <- 0;
            	loop i over: TodosJugadores{
            		draw (""+i+TodosJugadores[cont].Nombre + " - " + (TodosJugadores[cont].es_resistencia ? "R" : "E")) color: #white at: {3, 30+(cont*5)} font: font('Default', 15, #bold);
            		cont <- cont + 1;
            	}
            }
            graphics "VotosAFavor" {
                draw circle(8) at: {30,50} color: #green; //at{x,y}
                draw ("Votos a favor") color: #white at: {26, 60};
                draw (""+votos_a_favor) color: #white at: {29, 51} font: font('Default', 30, #plain);
            }
            graphics "VotosEnContra" {
                draw circle(8) at: {70,50} color: #red;
                draw ("Votos en contra") color: #white at: {66, 60};
                draw (""+votos_en_contra) color: #white at: {69, 51} font: font('Default', 30, #plain);
            }
            graphics "Ronda" {
            	draw circle(7) at: {50,30} color: #blue;
            	draw ("TURNO") color: #white at: {47.5, 40};
            	draw (""+turno) color: #white at: {48.5, 31} font: font('Default', 30, #plain);
            }
            graphics "Misiones"{
            	tablero t;
            	draw ("Misiones votadas: " + misionesvotadas) color: #white at: {22, 78} font: font('Default', 15, #plain);
            	draw ("Misiones no votadas: " + misionesnovotadas) color: #white at: {22, 80} font: font('Default', 15, #plain);
            }
    	}
    	
    	//display "Jugadores"{
    	//	graphics "nombres"{
    	//		loop i over: TodosJugadores {
		//			write i;
		//		}		
    	//	}    		
    	//}
    }
}