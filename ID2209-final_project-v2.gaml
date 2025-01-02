model project

global{
	int N <- 50;
		
	int number_of_party_enthusiasts <- 10;
	int number_of_introverts <- 10;
	int number_of_music_lovers <- 10;
	int number_of_competitive_debater <- 10;
	int number_of_observers <- 10;
		
	init{
		create Bar;
		create Concert;
		create Library;

		create PartyEnthusiast number: number_of_party_enthusiasts;
		create Introvert number: number_of_introverts;
		create MusicLover number: number_of_music_lovers;
		create CompetitiveDebater number: number_of_competitive_debater;
		create Observer number: number_of_observers;

	}
}

species Guest skills:[moving,fipa]{
	float happiness <- rnd(0.0, 1.0);
	 
	float mental_strength <- rnd(0.0, 1.0);
	float nastiness <- rnd(0.0, 1.0);
	float boredom <- rnd(0.01, 0.2);
	float sociability <- rnd(0.0, 1.0); 
	float openness_to_experience <- rnd(0.0, 1.0); 
	
	float park_boredom_rate;
	float bar_boredom_rate;
	float concert_boredom_rate;
	
	float park_preference_weight;
	float bar_preference_weight;
	float concert_preference_weight;
	
	float current_place_boredom <- 0.0;
	
	bool is_at_bar <- false;
	bool is_at_concert <- false;
	bool is_at_park <- false;
	
	Place target;
	
	rgb color;
	


	action init_place {	   
		float max_pref <- max(park_preference_weight, concert_preference_weight, bar_preference_weight);
		if (park_preference_weight = max_pref) {
			target <- one_of(Library);
			write name + " is heading to park " + target;
		} else if (concert_preference_weight = max_pref) {
			target <- one_of(Concert);
			write name + " is heading to concert " + target;
		} else if (bar_preference_weight = max_pref) {
			target <- one_of(Bar);
			write name + " is heading to bar " + target;
		}	
	}
	
	action change_place {
			write name + " is changing place...";
		    float total_weight <- 0.0;
		    
		    if (!is_at_park) { total_weight <- total_weight + park_preference_weight; }
		    if (!is_at_bar) { total_weight <- total_weight + bar_preference_weight; }
		    if (!is_at_concert) { total_weight <- total_weight + concert_preference_weight; }
		    
		    float normalized_park_weight <- (!is_at_park) ? (park_preference_weight / total_weight) : 0.0;
		    float normalized_bar_weight <- (!is_at_bar) ? (bar_preference_weight / total_weight) : 0.0;
		    float normalized_concert_weight <- (!is_at_concert) ? (concert_preference_weight / total_weight) : 0.0;
		
		    // Generate a random value between 0 and 1
		    float random_value <- rnd(0.0, 1.0);
		
		    // Decide the next place based on the weights
		    if (random_value < normalized_park_weight) {
		        // Park
		        target <- one_of(Library);
		        write name + " is heading to park " + target;
		    } else if (random_value < normalized_park_weight + normalized_bar_weight) {
		        // Bar
		        target <- one_of(Bar);
		        write name + " is heading to bar " + target;
		    } else {
		        // Concert
		        target <- one_of(Concert);
		        write name + " is heading to concert " + target;
		    }
		    
		   	is_at_bar <- false;
			is_at_concert <- false;
			is_at_park <- false;
	}
	
	reflex update_current_place {
		
		if (target != nil and location distance_to(target.location) < 2) {
			if target is Bar {
				is_at_bar <- true;
			}
			if target is Concert {
				is_at_concert <- true;
			}
			if target is Library {
				is_at_park <- true;
			}
		}
		
		if (target = nil or (target != nil and location distance_to(target.location) > 3)) {
			is_at_bar <- false;
			is_at_concert <- false;
			is_at_park <- false;
		}

	}
	
	reflex default when: target = nil {
		do wander;
	}
	
	reflex move_to_target when: target != nil {
        do goto target: target.location speed: rnd(0.5, 1.0);
    }
	
	reflex report_presence when: target != nil and location distance_to(target.location) < 10 {
		list<PartyEnthusiast> nearby_party_enthusiasts <- PartyEnthusiast at_distance 2;
		list<Introvert> nearby_introverts <- Introvert at_distance 2;
		list<MusicLover> nearby_music_lovers <- MusicLover at_distance 2;
		list<CompetitiveDebater> nearby_competitive_debaters <- CompetitiveDebater at_distance 2;
		list<Observer> nearby_observers <- Observer at_distance 2;
		
		if (length(nearby_party_enthusiasts) > 0 and sociability > 0.5) { 
            // Adjust based on sociability
			do start_conversation with: (to: nearby_party_enthusiasts, protocol: 'fipa-request', performative: 'inform', contents: ["presence", self]);
		}
		if (length(nearby_introverts) > 0 and sociability > 0.2) { 
            // Adjust based on sociability
			do start_conversation with: (to: nearby_introverts, protocol: 'fipa-request', performative: 'inform', contents: ["presence", self]);
		}
		if (length(nearby_music_lovers) > 0 and sociability > 0.4) { 
            // Adjust based on sociability
			do start_conversation with: (to: nearby_music_lovers, protocol: 'fipa-request', performative: 'inform', contents: ["presence", self]);
		}
		if (length(nearby_competitive_debaters) > 0 and openness_to_experience > 0.5) { 
            // Adjust based on openness to experience
			do start_conversation with: (to: nearby_competitive_debaters, protocol: 'fipa-request', performative: 'inform', contents: ["presence", self]);
		}
		if (length(nearby_observers) > 0 and sociability > 0.3) { 
            // Adjust based on sociability
			do start_conversation with: (to: nearby_observers, protocol: 'fipa-request', performative: 'inform', contents: ["presence", self]);
		}
		
	}
	
	reflex increase_boredom when: target != nil and location distance_to(target.location) < 2 {
        if (target is Library) {
            current_place_boredom <- current_place_boredom + 0.1 * park_boredom_rate;
        } else if (target is Bar) {
            current_place_boredom <- current_place_boredom + 0.1 * bar_boredom_rate;
        } else if (target is Concert) {
        	current_place_boredom <- current_place_boredom + 0.1 * concert_boredom_rate;	
        }
        
        if (current_place_boredom >= 1) {
        	do change_place;
        }
    }
	
}

species PartyEnthusiast parent: Guest {
    init {
        sociability <- rnd(0.7, 1.0);
        openness_to_experience <- rnd(0.7, 1.0);
        
        park_boredom_rate <- rnd(0.3, 0.5);  
        bar_boredom_rate <- rnd(0.05, 0.10);  
        concert_boredom_rate <- rnd(0.05, 0.15);  
        
        park_preference_weight <- 0.1;
        bar_preference_weight <- 0.6;
        concert_preference_weight <- 0.3;
        
        color <- #blue;
        
        // Use our new personality-based location choice
        do personality_based_location_choice;
    }
    
    action personality_based_location_choice {
        // Party Enthusiasts thrive in social settings, so they have high thresholds
        // but also high rewards for meeting those thresholds
        if (sociability > 0.6 and openness_to_experience > 0.6) {
            // When feeling social, strongly prefer bars and concerts
            float venue_choice <- rnd(0.0, 1.0);
            if (venue_choice < 0.8) { // 80% chance to go to preferred venues
                target <- one_of(Bar + Concert);
            } else {
                do init_place;
            }
        } else {
            // Even when less social, they avoid parks
            target <- one_of(Bar + Concert);
            location <- target.location;
            current_place_boredom <- 0.0;
            is_at_bar <- (target is Bar);
            is_at_concert <- (target is Concert);
            is_at_park <- false;
        }
    }
    
    float generosity <- rnd(0.0, 0.8);
    
    reflex read_message when: !(empty(informs)) {
        loop msg over: informs {
            if msg.contents[0] = "presence" {
                if (is_at_bar and (msg.contents[1] is MusicLover or msg.contents[1] is PartyEnthusiast)) {
                    happiness <- happiness + 0.2 * (1 - nastiness); // Gains happiness from shared enthusiasm
                    write "Party Enthusiast: Shared enthusiasm with " + msg.contents[1];
                }
            }
        }
    }

    reflex read_accepted_drink_offers when: !empty(proposes) and is_at_bar {
        loop accepted_drink_offer over: proposes {
            happiness <- happiness + 0.3 * (1 - nastiness); // Positive response to generosity
            write "Party Enthusiast: Accepted drink offer.";
        }
    }

    reflex read_rejected_drink_offers when: !empty(accept_proposals) and is_at_bar {
        loop refused_drink_offer over: accept_proposals {
            happiness <- happiness - 0.2 * (1 - mental_strength); // Rejection lowers happiness
            write "Party Enthusiast: Rejected drink offer.";
        }
    }

    reflex propose_drinks when: is_at_bar {
        list<Guest> nearby_guests <- Guest at_distance 10;
        if(length(nearby_guests) > 0){
            loop nearby_guest over: nearby_guests {
                if (nearby_guest is Introvert or nearby_guest is Observer) {
                    float offer_rnd <- rnd(0.0, 1.0);
                    if (offer_rnd < generosity) {
                        // TODO : send one only conversation to all concerned guests
                        do start_conversation with: (to: [nearby_guest], protocol: 'fipa-contract-net', performative: 'cfp', contents: ["propose_drink"]);
                        write "Party Enthusiast: Proposed drink to " + nearby_guest.name;
                    }
                }
            }
        }
    }
}


species Introvert parent: Guest {
    init {
        sociability <- rnd(0.0, 0.3);
        openness_to_experience <- rnd(0.2, 0.6);
        
        park_boredom_rate <- 0.1;
        bar_boredom_rate <- 0.4;
        concert_boredom_rate <- 0.4;
        
        park_preference_weight <- 0.7;
        bar_preference_weight <- 0.1;
        concert_preference_weight <- 0.2;
        
        color <- #grey;
        
        // Use our new personality-based location choice
        do personality_based_location_choice;
    }
    
    action personality_based_location_choice {
        // Introverts have very high thresholds for social venues
        // This represents their strong preference for quieter spaces
        if (sociability > 0.7 and openness_to_experience > 0.8) {
            // Even when meeting high thresholds, still prefer parks
            float venue_choice <- rnd(0.0, 1.0);
            if (venue_choice < 0.7) { // 70% chance to go to park
                target <- one_of(init_place);
            } else {
                // Only 30% chance to try other venues when feeling very social
                do init_place;
            }
        } else {
            // When not meeting high thresholds, always go to park
            target <- one_of(init_place);
            location <- target.location;
            current_place_boredom <- 0.0;
            is_at_park <- true;
            is_at_bar <- false;
            is_at_concert <- false;
        }
    }


    float introvert_rate <- rnd(0.0, 0.4);
    int max_surrounding_guests <- 25;

    reflex read_message when: !(empty(informs)) {
        loop msg over: informs {
            if msg.contents[0] = "presence" {
                if (is_at_park and (msg.contents[1] is Introvert or msg.contents[1] is Observer)) {
                    happiness <- happiness + 0.2 * (1 - nastiness); // Gains happiness from being with pairs
                    write "Introvert: Gains happiness from presence of " + msg.contents[1];
                }

                if (msg.contents[1] is CompetitiveDebater) {
                    happiness <- happiness - 0.2 * (1 - mental_strength); // Loses happiness during debates
                    write "Introvert: Loses happiness due to debate with " + msg.contents[1];
                }
            }
        }
    }

    reflex read_drink_offers when: !(empty(cfps)) and is_at_bar {
        loop drink_offer over: cfps {
            float offer_rnd <- rnd(0.0, 1.0);
            if (offer_rnd < introvert_rate) {
                do propose message: drink_offer contents: ["Let's take a drink!"];
                write "Introvert: Accepted drink offer.";
            } else {
                do refuse message: drink_offer contents: ["Sorry, I don't want any drink..."];
                write "Introvert: Rejected drink offer.";
            }
        }
    }

    reflex surrounded_by_too_many when: target != nil and length(Guest at_distance 3) >= 25 {
        happiness <- happiness - 0.2 * (1 - mental_strength);
        write "Introvert: Too many people nearby, loses happiness.";
    }
}


species MusicLover parent: Guest {
    init {
        // Initialize personality traits - Music Lovers tend to be more social and open
        sociability <- rnd(0.5, 0.8);
        openness_to_experience <- rnd(0.6, 1.0);
        
        // Initialize location preferences and boredom rates
        park_boredom_rate <- 0.4;
        bar_boredom_rate <- 0.2;
        concert_boredom_rate <- 0.1;
        
        park_preference_weight <- 0.1;
        bar_preference_weight <- 0.3;
        concert_preference_weight <- 0.6;
        
        color <- #yellow;
        
        // Check personality thresholds and choose initial place
        do personality_based_location_choice;
    }
    
    action personality_based_location_choice {
        // Music Lovers need lower thresholds for bars/concerts since they naturally enjoy these venues
        if (sociability > 0.3 and openness_to_experience > 0.4) {
            // If meeting minimum social requirements, prefer concert or bar
            float venue_choice <- rnd(0.0, 1.0);
            if (venue_choice < 0.7) { // 70% chance to go to preferred venues
                target <- one_of(Concert + Bar);
            } else {
                do init_place;
            }
        } else {
            // If not meeting thresholds, go to park as it's quieter
            target <- one_of(init_place);
            location <- target.location;
            current_place_boredom <- 0.0;
            is_at_park <- true;
            is_at_bar <- false;
            is_at_concert <- false;
        }
    }
    aspect default {
        draw sphere(2) at: location color: color;
    }

    init {
        park_boredom_rate <- 0.4;
        bar_boredom_rate <- 0.2;
        concert_boredom_rate <- 0.1;

        park_preference_weight <- 0.1;
        bar_preference_weight <- 0.3;
        concert_preference_weight <- 0.6;

        color <- #yellow;

        do init_place;
    }

    reflex read_message when: !(empty(informs)) {
        loop msg over: informs {
            if msg.contents[0] = "presence" {
                if (is_at_concert and (msg.contents[1] is MusicLover)) {
                    happiness <- happiness + 0.4 * (1 - nastiness); // Gains happiness with another Music Lover
                    write "Music Lover: Gains happiness with another Music Lover.";
                }
                if ((is_at_bar or is_at_concert) and (msg.contents[1] is PartyEnthusiast)) {
                    happiness <- happiness + 0.2 * (1 - nastiness); // Gains happiness with Party Enthusiast
                    write "Music Lover: Gains happiness with Party Enthusiast.";
                }
            }
        }
    }

    reflex alone_at_concert when: is_at_concert {
        list<Guest> nearby_guests <- Guest at_distance 2;
        int pairs_count <- 0;
        loop guest over: nearby_guests {
            if (guest is MusicLover or guest is PartyEnthusiast) {
                pairs_count <- pairs_count + 1;
            }
        }
        if (pairs_count = 0) {
            happiness <- happiness - 0.3 * (1 - mental_strength); // Loses happiness if no compatible guests nearby
            write "Music Lover: Loses happiness due to being alone at concert.";
        }
    }
}



species CompetitiveDebater parent: Guest {
    init {
        // Initialize personality traits - Debaters tend to be very social but may vary in openness
        sociability <- rnd(0.6, 0.9);
        openness_to_experience <- rnd(0.4, 0.8);
        
        // Initialize location preferences and boredom rates
        park_boredom_rate <- 0.2;
        bar_boredom_rate <- 0.2;
        concert_boredom_rate <- 0.4;
        
        park_preference_weight <- 0.3;
        bar_preference_weight <- 0.5;
        concert_preference_weight <- 0.2;
        
        color <- #purple;
        
        // Check personality thresholds and choose initial place
        do personality_based_location_choice;
    }
    
    action personality_based_location_choice {
        // Debaters need higher sociability but lower openness threshold since they prefer structured social settings
        if (sociability > 0.5 and openness_to_experience > 0.3) {
            // If meeting social requirements, strongly prefer bar
            float venue_choice <- rnd(0.0, 1.0);
            if (venue_choice < 0.6) { // 60% chance to go to bar
                target <- one_of(Bar);
            } else {
                do init_place;
            }
        } else {
            // If not meeting thresholds, go to park where they can find one-on-one conversations
            target <- one_of(init_place);
            location <- target.location;
            current_place_boredom <- 0.0;
            is_at_park <- true;
            is_at_bar <- false;
            is_at_concert <- false;
        }
    }
    
    aspect default {
        draw sphere(2) at: location color: color;
    }

    init {
        park_boredom_rate <- 0.2;
        bar_boredom_rate <- 0.2;
        concert_boredom_rate <- 0.4;

        park_preference_weight <- 0.3;
        bar_preference_weight <- 0.5;
        concert_preference_weight <- 0.2;

        color <- #purple;

        do init_place;
    }

    reflex read_message when: !(empty(informs)) {
        loop msg over: informs {
            if msg.contents[0] = "presence" {
                if (msg.contents[1] is CompetitiveDebater or msg.contents[1] is MusicLover) {
                    happiness <- happiness + 0.3 * (1 - nastiness); // Gains happiness debating Competitive Debater or Music Lover
                    write "Competitive Debater: Gains happiness debating with " + msg.contents[1];
                } else if (msg.contents[1] is PartyEnthusiast or msg.contents[1] is Introvert or msg.contents[1] is Observer) {
                    happiness <- happiness - 0.2 * (1 - mental_strength); // Loses happiness with uninterested guests
                    write "Competitive Debater: Loses happiness with uninterested guest " + msg.contents[1];
                }
            }
        }
    }
}



species Observer parent: Guest {
    init {
        // Initialize personality traits
        sociability <- rnd(0.1, 0.4);
        openness_to_experience <- rnd(0.3, 0.7);
        
        // Initialize boredom rates for different locations
        park_boredom_rate <- 0.3;
        bar_boredom_rate <- 0.4;
        concert_boredom_rate <- 0.3;
        
        // Initialize location preferences
        park_preference_weight <- 0.5;
        bar_preference_weight <- 0.2;
        concert_preference_weight <- 0.3;
        
        color <- #black;
        
        // Check personality thresholds and choose initial place
        do personality_based_location_choice;
    }
    
    // New action to handle location choice based on personality
    action personality_based_location_choice {
        if (sociability > 0.35 and openness_to_experience > 0.35) {
            // If guest is social and open, proceed with normal location selection
            do init_place;
        } else {
            // If guest is less social or less open, go to library
            target <- one_of(Library);
            location <- target.location;
            current_place_boredom <- 0.0;
            is_at_park <- false;
            is_at_bar <- false;
            is_at_concert <- false;
        }
    }
    
    float introvert_rate <- rnd(0.0, 0.3);
    
    aspect default {
        draw sphere(2) at: location color: color;
    }
    
    // Handle messages about presence of others
    reflex read_message when: !(empty(informs)) {
        loop msg over: informs {
            if msg.contents[0] = "presence" {
                if (is_at_park and (msg.contents[1] is Observer or msg.contents[1] is Introvert)) {
                    happiness <- happiness + 0.3 * (1 - nastiness); // Gains happiness from peaceful company
                    write "Observer: Gains happiness from peaceful company with " + msg.contents[1];
                }
                if (msg.contents[1] is CompetitiveDebater) {
                    happiness <- happiness - 0.3 * (1 - mental_strength); // Loses happiness with Competitive Debater
                    write "Observer: Loses happiness with Competitive Debater.";
                }
            }
        }
    }
    
    // Handle drink offers at bar
    reflex accept_or_decline_drinks when: !(empty(cfps)) and is_at_bar {
        loop drink_offer over: cfps {
            float accept_rnd <- rnd(0.0, 1.0);
            if (accept_rnd < introvert_rate) {
                do propose message: drink_offer contents: ["Thanks for the drink!"];
                happiness <- happiness + 0.3 * (1 - nastiness); // Gains happiness from accepting drink
                write "Observer: Accepted drink offer.";
            } else {
                do refuse message: drink_offer contents: ["No, thank you."];
                happiness <- happiness - 0.2 * (1 - mental_strength); // Loses happiness from refusing drink
                write "Observer: Rejected drink offer.";
            }
        }
    }


    reflex majority_check when: is_at_bar or is_at_park {
        list<Guest> nearby_guests <- Guest at_distance 3;
        int num_observers <- 0;
        int num_introverts <- 0;

        loop guest over: nearby_guests {
            if (guest is Observer) {
                num_observers <- num_observers + 1;
            }
            if (guest is Introvert) {
                num_introverts <- num_introverts + 1;
            }
        }

        if (num_observers > num_introverts) {
            happiness <- happiness - 0.2 * (1 - mental_strength); // Loses happiness in Observer-heavy area
            write "Observer: Too many Observers nearby, loses happiness.";
        } else if (num_introverts > num_observers) {
            happiness <- happiness - 0.2 * (1 - mental_strength); // Loses happiness in Introvert-heavy area
            write "Observer: Too many Introverts nearby, loses happiness.";
        }
    }
}




species Place {
	
}

species Bar parent: Place {
	aspect default {
        draw box({10, 5, 5}) at: location color: #brown;
    }
}
species Library parent: Place {
	aspect default {
        draw box({10, 10, 1}) at: location color: #green;
    }
}
species Concert parent: Place {
 	aspect default {
        draw box({10, 5, 10}) at: location color: #yellow;
    }
}

experiment final_project type: gui
{
    output{
        display myDisplay type: opengl{
            species Bar;
            species Concert;
            species Library;
            species PartyEnthusiast;
            species Introvert;
            species MusicLover;
            species CompetitiveDebater;
            species Observer;
        }

    display Charts {
      chart "Happiness level histogram" type: series {
        list<Guest> all_guests <- list(PartyEnthusiast) + list(Introvert) + list(MusicLover) + list(CompetitiveDebater) + list(Observer);
        datalist all_guests collect (each.name) value: all_guests collect (each.happiness) color: all_guests collect (each.color); 
      }


    }
  }
}