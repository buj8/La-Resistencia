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
							"Escogiendo equipos...",
							"Votando equipos",
							"Contando votos...",
							"En la misión...",
							"Resultados de la misión",
							"Fin de misión"
							];							

	int PICKING_TEAM <- 0;
	int VOTING_TEAM <- 1;
	int VOTING_COUNT <- 2;
	int IN_MISSION <- 3;
	int MISSION_RESULTS <- 4;
	int END_PHASE <- 5;
	
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
            5  :: [0, 2, 3, 2, 3, 3],
            6  :: [0, 2, 3, 4, 3, 4],
            7  :: [0, 2, 3, 3, 4, 4],
            8  :: [0, 3, 4, 4, 5, 5],
            9  :: [0, 3, 4, 4, 5, 5],
            10 :: [0, 3, 4, 4, 5, 5]
        ]);
   	list<int> players_per_mission;
   	
   	
   	
   	// VARIABLES ESTÉTICAS DEL JUEGO
   	
   	int size <- 10;
	font default_font <- font('Default', 15, #bold);
	rgb color_background <- rgb(38, 40, 52);
	rgb color_info <- rgb(96, 101, 130);
	rgb color_resistance <- rgb(152, 160, 206);
	rgb color_spies <- rgb(255, 140, 58);


	reflex reset_game when: current_mission = -1 {
		do pause;
		current_mission <- -2;
	}
	
}

species Board {
	
	// Métodos del agente Tablero
	
	action start_game {
		// Empezamos en una fase ficticia 0
		current_mission <- 0;
		
		// Empezamos en el final de la fase ficticia
		current_phase <- END_PHASE;
		
		// Inicializamos la votación
		votes_favor <- 0;
		votes_against <- 0;
		
		missions_succeeded <- 0;
		missions_failed <- 0;
		mission_total <- 0;
		mission_good <- 0;
		mission_bad <- 0;
		
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
	
	action start_round {
		total_votes <- 0;
		votes_favor <- 0;
		votes_against <- 0;
		
		rejected_teams <- 0;
	
		current_phase <- 0;
		current_mission <- current_mission + 1;
		
		mission_total <- 0;
		mission_good <- 0;
		mission_bad <- 0;
		
		
		players_per_mission <- missions_map[n_players];
	}
	
	action reset_stats {
		votes_favor <- 0;
		votes_against <- 0;
		missions_succeeded <- 0;
		missions_failed <- 0;
		mission_total <- 0;
		mission_good <- 0;
		mission_bad <- 0;
		loop i over: spies {
			i.is_spy <- false;
		}
		spies <- n_spies among players;
		loop i over: spies {
			i.is_spy <- true;
		}
	}	
	
	action pick_next_leader {
		players[leader_index].is_leader <- false;
		leader_index <- (leader_index + 1) mod n_players;
		players[leader_index].is_leader <- true;
		write("[BOARD] NEW LEADER: " + players[leader_index].name) color: #white;
	}
	
	action propose_team {
		ask players[leader_index] {
			// Pedimos al líder que proponga un equipo
		}

		/* IMPLEMENTACIÓN PROVISIONAL
		 * 
		 * Se elige un equipo de forma aleatoria.
		 */
		 loop p over: proposed_team {
		 	p.proposed_for_team <- false;
		 }
		 write("[BOARD] Proposed team:") color: #white;
		 proposed_team <- players_per_mission[current_mission] among players;
		 loop p over: proposed_team {
		 	write("\t" + p.name) color: p.is_spy ? #gamaorange : #royalblue;
		 	p.proposed_for_team <- true;
		 }
		 
		 
		 
	}
	
	action collect_votes {
		total_votes <- 0;
		votes_favor <- 0;
		votes_against <- 0;
	
		ask target: players {
			// Pedir a los jugadores que voten
		}
		
		/* IMPLEMENTACIÓN PROVISIONAL
		 * 
		 * Al no haber jugadores implementados que decidan se 
		 * calcularán los votos de forma aleatoria.
		 */
		 
		 votes_favor <- rnd(n_players);
		 votes_against <- n_players - votes_favor;
		 total_votes <- 0;

	}
	
	action perform_mission {
		mission_good <- 0;
		mission_bad <- 0;
		mission_total <- 0;
		
		ask target: proposed_team {
			// Pedir al equipo que ejecute la misión
		}
		
		/* IMPLEMENTACIÓN PROVISIONAL
		 * 
		 * Igual que en el collect_votes, se obtienen los valores
		 * de forma aleatoria.
		 */
		 
		 mission_total <- players_per_mission[current_mission]; 
		 mission_good <- rnd(mission_total);
		 mission_bad <- mission_total - mission_good;
	}
	
	action evaluate_mission {
		if (mission_bad > 0) {
			missions_failed <- missions_failed + 1;
		} else {
			missions_succeeded <- missions_succeeded + 1;
		}
	}
	

	action end_game {
		current_mission <- 0;
		current_phase <- END_PHASE;
	}
	
	
	init {	
		do start_game;
	}
	

	// REFLEJOS
	
	reflex start_new_round when: current_phase = END_PHASE {
	    do start_round;
	    write("[BOARD] Starting round " + current_mission) color: #white;
	}
	
	reflex team_proposal  when: current_phase = PICKING_TEAM {
		do propose_team;
		current_phase <- VOTING_TEAM;
	}
	
	reflex team_voting when: current_phase = VOTING_TEAM {
		write("[BOARD] Voting team") color: #white;
		do collect_votes;
		current_phase <- VOTING_COUNT;
	}
	
	reflex voting_result when: current_phase = VOTING_COUNT
	 	{
			if votes_against <= votes_favor {
				write("[BOARD] Team rejected") color: #white;
				do pick_next_leader;
				current_phase <- PICKING_TEAM;
				rejected_teams <- rejected_teams + 1;
			}
			else {
				write("[BOARD] Team accepted") color: #white;
				current_phase <- IN_MISSION;
			}
		}
	
	reflex execute_mission when: current_phase = IN_MISSION {
		write("[BOARD] Executing mission") color: #white;
		do perform_mission;
		current_phase <- MISSION_RESULTS;
	}
	
	reflex show_mission_result when: current_phase = MISSION_RESULTS {
		do evaluate_mission;
		if mission_bad > 0 {
			write("[BOARD] Mission failed") color: #white;
		}
		current_phase <- END_PHASE;
	}
	
	reflex resistance_wins when: missions_succeeded >= 3 {
		write("[BOARD] RESISTANCE WINS!") color: #white;
		do end_game;
	}
	
	reflex spies_win when: missions_failed >= 3 or rejected_teams >= 5 {
		write("[BOARD] SPIES WIN!") color: #white;
		do reset_stats;
		do end_game;
	}
	
	reflex new_game when: current_mission = -2{
		do start_game;
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
			graphics RoundInfo visible: current_mission != 0 and current_mission != 6 {
				string stage_info <- phases[current_phase];
				draw string("[ MISIÓN " + current_mission + " ]") at: {size/5, 2+(size/4)} font:default_font color:#white;
				draw string(stage_info) at: {size/5, 6+(size/5)} font:default_font color:#white; 
				draw string("Jugadores necesarios: " + players_per_mission[current_mission]) at: {size/5, 10+(size/5)} font:default_font color:#white; 
				draw string("Equipos rechazados: " + rejected_teams + "/5") at: {size/5, 14+(size/5)} font:default_font color:#white;
				draw string("Misiones completadas: " + missions_succeeded) at: {size/5, 18+(size/5)} font:default_font color:#white;
				draw string("Misiones fallidas: " + missions_failed) at: {size/5, 22+(size/5)} font:default_font color:#white;
			}
			
			// En caso de que sea la fase de votación tendremos un círculo con el estado de los votos
			graphics VotingCircle visible: current_phase >= VOTING_TEAM or current_phase <= VOTING_COUNT {
				draw geometry:circle(120/size) color: color_info at: {size*10/2, size*10/2};
				draw string("Votos a favor:   " + votes_favor) at: {size*17/4, size*19/4} font:default_font color:#white;
				draw string("Votos en contra: " + votes_against) at: {size*17/4, size*21/4} font:default_font color:#orange;
			}
			
			// En caso de que sea la fase de misión tendremos un círculo con los éxitos y sabotajes
			graphics MissionsCircle visible: current_phase >= IN_MISSION and current_mission != 0 {
				draw geometry:circle(120/size) color: color_info at: {size*10/2, size*10/2};
				draw string("Éxitos		: " + mission_good) at: {size*17/4, size*19/4} font:default_font color:#white;
				draw string("Sabotajes	: " + mission_bad) at: {size*17/4, size*21/4} font:default_font color:#orange;
			}	
			
			// En caso de que sea la fase de misión tendremos un círculo con los éxitos y sabotajes
			graphics EndgameCircle visible: current_mission = 6 {
				draw geometry:circle(120/size) color: color_info at: {size*10/2, size*10/2};
				string win_text <- (missions_succeeded > missions_failed) ? "VICTORIA RESISTENCIA" : "VICTORIA ESPÍA";
				draw win_text at: {size*4.27, size*10/2} font:default_font color:#orange;
			}	
		}
	}
}

	