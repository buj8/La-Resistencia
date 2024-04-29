/**
* Name: La Resistencia
* Tags: 
*/


model LaResistencia

global {
	
	// VARIABLES LÓGICAS DEL JUEGO
	
	int current_mission;
	int current_phase;
	/*  Para la entrega parcial al no tener iniciativa los agentes "jugador"
	 *  restringiremos las partes de la misión a formación de equipos
	 *  y ejecución de la misión. Lo dejamos en este formato para implementar
	 *  el uso de cartas de los jugadores para la siguiente entrega.
	 */
	list<string> phases <-	[
							"Formando equipos...",
							"En la misión..."
							];
	int rejected_teams;
	Board board;
	int n_players;
	int n_spies;
	int leader_index;

	list<Player> players;
	list<Player> spies;
	
	list<Player> proposed_team;
	
	int votes_favor;
	int votes_against;
	int total_votes;
	
	int mission_good;
	int mission_bad;
	int mission_total;
	
	int missions_failed;
	int missions_succeeded;
	
	list<string> names <-   [
						    "Ana",
						    "Bruno",
						    "Carla",
						    "David",
						    "Esther",
						    "Fran",
						    "Gabriela",
						    "Héctor",
						    "Irene",
						    "Jose"
							];
	map<int, list<int>> missions_map <- map([
            5  :: [2, 3, 2, 3, 3],
            6  :: [2, 3, 4, 3, 4],
            7  :: [2, 3, 3, 4, 4],
            8  :: [3, 4, 4, 5, 5],
            9  :: [3, 4, 4, 5, 5],
            10 :: [3, 4, 4, 5, 5]
        ]);
   	list<int> players_per_mission;
   	
   	
   	
   	// VARIABLES ESTÉTICAS DEL JUEGO
   	
   	int size <- 10;
	font default_font <- font('Default', 15, #bold);
	rgb color_background <- rgb(38, 40, 52);
	rgb color_info <- rgb(96, 101, 130);
	rgb color_resistance <- rgb(152, 160, 206);
	rgb color_spies <- rgb(255, 140, 58);
	
	
}

species Board {
	init {	
		// Empezamos en la fase 1
		current_mission <- 1;
		
		// Empezamos en la parte de selección de equipos
		current_phase <- 0;
		
		// Inicializamos la votación
		votes_favor <- 0;
		votes_against <- 0;
		
		// Elegimos un líder al azar
		leader_index <- rnd(n_players - 1);
		players[leader_index].is_leader <- true;
		
		
		// Calculamos el número de espías
		switch n_players {
			match 5 	{ n_spies <- 2;}
			match 6 	{ n_spies <- 2;}
			match 7 	{ n_spies <- 3;}
			match 8 	{ n_spies <- 3;}
			match 9 	{ n_spies <- 3;}
			match 10 	{ n_spies <- 4;}	
		}
			
		// Añadimos los espías
		spies <- n_spies among players;
		loop i over: spies {
			i.is_spy <- true;
		}
		
		// Seleccionamos la distribución de jugadores
		players_per_mission <- missions_map[n_players];
	}
	
	
	
}

grid BoardGrid height:size width: size {
	rgb color <- color_background;
}

species Player {
	string name;
	bool is_spy <- false;
	bool is_leader <- false;
	bool proposed_for_team <- false;
	
	/* El aspecto de los jugadores en el tablero será en forma de círculos de colores
	 * - Si es el líder actual tendrá borde DORADO, si no será NEGRO
	 * - Si está en la resistencia el círculo será AZUL, si no será NARANJA
	 * - Si está propuesto para el equipo se añadirá un borde ROJO extra
	 * */
	aspect player_aspect {
		if proposed_for_team {
			draw geometry:circle(54/size) color: #red;
		}
		draw geometry:circle(48/size) color: (is_leader ? #yellow : #black);
		draw geometry:circle(45/size) color: (is_spy ? color_spies : color_resistance);
		draw string(name) color: #black anchor: #center  font: default_font;
		
	}
}

experiment Game type: gui {
	parameter "Number of players" var:n_players <- 5 min:5 max:10;
	
	init {
		// Creamos los jugadores 
		create Player number: n_players;
		players <- list(Player);
				
		// Creamos nuestro tablero
		create Board;

		// Obtenemos las posiciones de cada jugador en el tablero en un corro
		float centerX <- size*10/2;
		float centerY <- size*10/2; 
		int radius <-  size*3;
		
		loop i from: 0 to: n_players - 1 {
			players[i].name <- names[i];
			float angle <- 360 * (i / n_players) - 90;
			players[i].location <- {centerX + radius * cos(angle), centerY + radius * sin(angle)};
		}

		
	}
	
	output {
		display Game type:java2D {
			// Representamos los jugadores en un corro
			grid BoardGrid;
			species Player aspect: player_aspect;
			
			// Ponemos la info de la ronda en el centro
			graphics RoundInfo {
				draw string("[ MISIÓN " + current_mission + " ]") at: {size/5, 2+(size/4)} font:default_font color:#white;
				string stage_info <- phases[current_phase];
				draw string(stage_info) at: {size/5, 6+(size/5)} font:default_font color:#white; 
				draw string("Jugadores necesarios: " + players_per_mission[current_phase]) at: {size/5, 10+(size/5)} font:default_font color:#white; 
				draw string("Equipos rechazados: " + rejected_teams + "/5") at: {size/5, 14+(size/5)} font:default_font color:#white;
				draw string("Misiones completadas: " + missions_succeeded) at: {size/5, 18+(size/5)} font:default_font color:#white;
				draw string("Misiones fallidas: " + missions_failed) at: {size/5, 22+(size/5)} font:default_font color:#white;
			}
			
			// En caso de que sea la fase de votación tendremos un círculo con el estado de los votos
			graphics VotingCircle visible: current_phase = 0 {
				draw geometry:circle(120/size) color: color_info at: {size*10/2, size*10/2};
				draw string("Votos a favor:   " + votes_favor) at: {size*17/4, size*19/4} font:default_font color:#white;
				draw string("Votos en contra: " + votes_against) at: {size*17/4, size*21/4} font:default_font color:#orange;
			}
			
			// En caso de que sea la fase de misión tendremos un círculo con los éxitos y sabotajes
			graphics MissionsCircle visible: current_phase = 1 {
				draw geometry:circle(120/size) color: color_info at: {size*10/2, size*10/2};
				draw string("Éxitos		: " + mission_good) at: {size*17/4, size*19/4} font:default_font color:#white;
				draw string("Sabotajes	: " + mission_bad) at: {size*17/4, size*21/4} font:default_font color:#orange;
			}
		}
	}
}

	