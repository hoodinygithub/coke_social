namespace :coke do
  namespace :invalid_tags do
    desc "Unlink all invalid tags (that aren't on valid tags)"
    task :unlink_invalid => :environment do
      #@TODO: Remove links from invalid relationships between tags and playlists
      sites = Site.all(:conditions => "code in ('cokebr', 'cokemx', 'cokear', 'cokelatam')")    
      valid_tag_ids = sites.map(&:tag_ids)
      playlist_ids  = sites.map(&:playlist_ids)
      puts "Valid tag ids:"      
      puts valid_tag_ids.flatten.uniq.inspect
      puts "---"
      puts "Playlist ids:"
      puts playlist_ids.flatten.uniq.inspect
    end
  
    desc "Remove invalid tags and links"
    task :remove_invalid => :environment do
      
    end
    
    desc "Insert tags for xmas promo"
    task :insert_xmas_promo => :environment do
      tags = {
        :cokear => ['Dedicar canciones', 'Navidad', 'Xmas', 'Armonía', 'Felicidad', 'Seres queridos',
                    'Música', 'Compartir', 'Dar y compartir', 'Felices fiestas',
                    'Año nuevo', 'Canciones en año nuevo', 'Festejar', 'Cena navideña', 'Amigos', 
                    'Familia', 'Feliz navidad', 'Para nochebuena', 'Ser feliz', 'Reyes magos',
                    'Papá Noel', 'Regalos', 'Hacer felices a los demás', 'Regalar canciones',
                    'Canciones navideñas', 'Villancicos', 'Estrellas navideñas', 'Artistas navideños',
                    'Cantantes navideños', 'Navideña', 'Época de navidad'],
        :cokemx => ['Dedicar canciones', 'Navidad', 'Xmas', 'Armonía', 'Felicidad', 'Felicidad en navidad',
                    'Seres queridos', 'Música', 'Compartir', 'Dar y compartir', 'Felices fiestas', 'Año nuevo',
                    'Canciones en año nuevo', 'Festejar', 'Festejar en navidad', 'Cenar en navidad', 'Cena navideña',
                    'Amigos', 'Familia', 'Feliz navidad', 'Para nochebuena', 'Ser feliz', 'Reyes magos', 'Santa claus',
                    'Niño jesus', 'Regalos', 'Hacer felices a los demás', 'Regalar canciones', 'Canciones navideñas',
                    'Villancicos', 'Estrellas navideñas', 'Artistas navideños', 'Regalar una canción', 
                    'Cantantes navideños', 'Para posadas', 'Nostálgica', 'Navideña', 'Época de navidad',
                    'Época de compartir', 'Compartir'],
        :cokelatam => ['Dedicar canciones', 'Navidad', 'Xmas', 'Armonía', 'Felicidad', 'Felicidad en navidad',
                    'Seres queridos', 'Música', 'Compartir', 'Dar y compartir', 'Felices fiestas', 'Año nuevo',
                    'Canciones en año nuevo', 'Festejar', 'Festejar en navidad', 'Cenar en navidad', 'Cena navideña',
                    'Amigos', 'Familia', 'Feliz navidad', 'Para nochebuena', 'Ser feliz', 'Reyes magos', 'Santa claus',
                    'Niño jesus', 'Regalos', 'Hacer felices a los demás', 'Regalar canciones', 'Canciones navideñas',
                    'Villancicos', 'Estrellas navideñas', 'Artistas navideños', 'Regalar una canción', 
                    'Cantantes navideños', 'Para posadas', 'Nostálgica', 'Navideña', 'Época de navidad',
                    'Época de compartir', 'Compartir']  
      }
      
      sites = Site.all(:conditions => "code in ('cokemx','cokear','cokelatam')")
      sites.each do |site|
        puts site.name
        puts "--------"
        puts (tags[site.code.to_sym]).inspect 
        (tags[site.code.to_sym]).uniq.each do |tag_name|
          ValidTag.create(:tag_name => tag_name, :site => site, :promo => 'xmas')
        end
        puts "--------\n\n"      
      end          
    end
    
    desc 'Remove valid tags for xmas promo'
    task :remove_xmas_promo => :environment do
      tags = ValidTag.find_by_promo('xmas')
      tags.destroy
    end
        
    desc "Insert the pre-defined valid tags received from Claro"
    task :insert_valid => :environment do 
      ValidTag.delete_all
      tags = {
        :all => ["Alegre", "Amor", "Feliz", "Cool", "Pop", "Relax", "Sexy", "Chillout", "Reggae", "Energía", "Energy", "Dance", "Hip-Hop", "House", "Indie", "Rock n' Roll", "Rap", "Romântico", "Divertido", "De karaoke", "Rocker", "Hippie", "Super", "Lounge", "Metal"],
        :cokemx => ["Para despertarse", "Para motivarse", "Inspirado", "Buena Onda", "A mil", "Optimista", "Para celebrar", "De Fiesta", "Antreras", "Vivir de noche", "De Buenas", "Poperas", "Bailar", "Alternativas", "Buena Vibra", "Retro", "Te la dedico", "Energía", "Tranquilas", "Para estudiar", "Memorias", "Cute", "Sorpresa", "Románticas", "Cursis", "Enamorado", "Cardio", "Verano", "Graduación", "Playeras", "Ligue", "De Bodas", "Serenatas", "Rockeronas", "De carretera", "Domingueras", "Electro", "Covers", "Fresas", "Bling Bling", "Mañaneras"],
        :cokebr => ["Acordando", "Agito", "Alternativa", "Alto Astral", "Ao vivo", "Apaixonado", "Arrumando pra sair", "Balada", "BFF", "Boas Ondas", "Boas Vibrações", "Bombando", "Com a galera", "Cover", "Das antigas", "De bem com a vida", "De boa", "De Festa", "Despreocupado", "Dia de Sol", "Diva", "Divertidas", "Eclético", "Eletrônica", "EMO", "Engraçado", "Excitante", "Favoritas", "Feriado", "Férias", "Fofa", "Inesquecível", "Irada", "Legais", "Luau", "Malhação", "Maneira", "Minha cara", "Momento especial", "Na estrada", "Otimista", "Pensativo", "Pra cima", "Pra Curtir", "Pra dançar", "Pra estudar", "Pra inspirar", "Pra namorar", "Pra trabalhar", "Refrescar as ideias", "Sábado à noite", "Soltar a voz", "Sonhador", "Sossego", "Trilha Sonora", "Verão", "Viajando", "Viver Positivamente", "Zen"],
        :cokear => ["Para despertarse", "Para motivarse", "Inspirado", "Buena Onda", "A mil", "Optimista", "Para celebrar", "Afectuoso", "Meloso", "Despierto / Mañaneras", "Para mimarse", "Entusiasmado", "Pilas!", "Soñadores", "Aspirante ", "Para motivarse", "Cautivado", "Bacán", "Contento", "Despierto", "Piola", "Mañaneras", "Emocionado", "Emotivas", "Encantador ", "De levante", "Esperanzado", "Para reconciliarse", "Exaltado", "De reviente", "A fondo", "A full", "Motivados", "A pleno", "Orgulloso", "De fondo", "Confidente", "Valiente", "Calma", "Para bajar un cambio", "Intimas"],
        :cokelatam => ["Para despertarse", "Para motivarse", "Inspirado", "Buena Onda", "A mil", "Optimista", "Para celebrar", "Que jevy", "Ta de to", "Full", "Duro", "Apero ", "Aperísimo", "Ke lo ke", "Dame lu", "Bonche", "Ta pila", "Encendido", "Dime montro", "Ke lo ke montro", "Tu ta en onda", "Monta", "Dime a ver", "K de new?", "Atrativo", "No le pare", "No coja trote", "Nítido", "Chiva", "Pura vida", "Demasiado", "Deacachimba", "Pijudo", "Está fiera", "Diaca", "Pretty", "Rumba", "Friend", "Qué sopa!", "Rola", "Dale play", "Simón", "Chivo", "Patín"]
      }
            
      if Site.find_by_code('cokebr').nil?
        Site.create({
          :name => "Coke BR", :default_locale => "coke-BR", :code => "cokebr", :login_type_id => 1
        })
      end
      if Site.find_by_code('cokear').nil?
        Site.create({
          :name => "Coke AR", :default_locale => "coke-AR", :code => "cokear", :login_type_id => 1
        })
      end
      if Site.find_by_code('cokemx').nil?
        Site.create({
          :name => "Coke MX", :default_locale => "coke-MX", :code => "cokemx", :login_type_id => 1
        })
      end
      if Site.find_by_code('cokelatam').nil?
        Site.create({
          :name => "Coke LATAM", :default_locale => "coke-ES", :code => "cokelatam", :login_type_id => 1
        })
      end    
    
      sites = Site.all(:conditions => "code in ('cokebr', 'cokemx', 'cokear', 'cokelatam')")
      sites.each do |site|
        puts site.name
        puts "--------"
        puts (tags[:all] + tags[site.code.to_sym]).inspect 
        (tags[:all] + tags[site.code.to_sym]).uniq.each do |tag_name|
          ValidTag.create(:tag_name => tag_name, :site => site)
        end
        puts "--------\n\n"      
      end
    end
  end
end