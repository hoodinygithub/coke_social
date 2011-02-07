require 'erb'
namespace :band_index do
  desc "Create artist index"
  task :create => :environment do

	  "A".upto("Z") do | var |
			create_html(var)
		end
		0.upto(9) do | var |
			create_html(var)
		end
      create_html('#')
	end
	
		def create_html(param)
			var = param
			#var = "B"
			#Dir.mkdir("#{RAILS_ROOT}/public/artists")
			f = File.new("#{RAILS_ROOT}/public/artists/#{var}.html",  "w+")

			f.write('<html xmlns="http://www.w3.org/1999/xhtml" xmlns:og=\'http://opengraphprotocol.org/schema/\' xmlns=\'http://www.w3.org/1999/xhtml\' xmlns:fb=\'http://www.facebook.com/2008/fbml\' xml:lang=\'en-US\' lang=\'en-US\'>
		<head>
    <meta content=\'text/html;charset=utf-8\' http-equiv=\'Content-Type\' />
    <meta content=\'text/javascript\' http-equiv=\'Content-Script-Type\' />
     <title>Coca-Cola.fm |  Destapa tus emociones</title>
		<meta content=\'Descubrir música, descubrir música nueva, descubrir videos, escuchar música, escuchar música gratis, música gratis, videos gratis, artistas musicales, descubrir artistas, descubrir artistas musicales, descubrir músicos, descubrir bandas, escuchar bandas, biblioteca de música online, biblioteca de música en la red, la biblioteca de música online más grande, música online gratis, música gratis en la red, biblioteca de música gratis online, biblioteca de música gratis en la red, la biblioteca de música gratutita en línea más grande, seguir amigos, siguiendo amigos, seguidor de amigos, crear mixes de música, compartir mixes de música, estaciones de radio personalizadas, artistas favoritos, compartir música, compartir música gratis.\' name=\'keywords\' />
		<meta content=\'Descubre música nueva y videos gratis de la biblioteca más grande y completa de música y videos en Internet. Sigue a tus amigos y lo que están escuchando. Crea y comparte mixes y estaciones de radio personalizadas de tus artistas favoritos.\' name=\'description\' />
		<meta content=\'ALL\' name=\'robots\' />
		<meta content=\'21\' name=\'site\' />
		<meta content=\'Sun Feb 06 08:22:41 +0530 2011\' name=\'created\' />
		<link href=\'http://localhost:3000/favicon.ico\' rel=\'shortcut icon\' />
		<meta content=\'GU/Zid0XOsI15JUJGWPvq7c1Uqt8pYKhCXHhTPUDZmE=\' name=\'authenticity_token\' />
				')

			f.write('	  <script type="text/javascript" charset="utf-8">
  var current_url_site = "http://localhost:3000";
</script>
<script src="/javascripts/jquery-1.4.1.min.js" type="text/javascript"></script>
<script src="/javascripts/jquery.cycle.all.min.js" type="text/javascript"></script>
<script src="/javascripts/supersleight.plugin.js" type="text/javascript"></script>
<script src="/javascripts/jquery.metadata.js" type="text/javascript"></script>
<script src="/javascripts/jquery.autocomplete.js" type="text/javascript"></script>
<script src="/javascripts/jquery.validate.min.js" type="text/javascript"></script>
<script src="/javascripts/jquery.hotkeys.min.js" type="text/javascript"></script>
<script src="/javascripts/jquery.facebox.js" type="text/javascript"></script>
<script src="/javascripts/base.js" type="text/javascript"></script>
<script src="/utils/locale.js" type="text/javascript"></script>
<script src="/javascripts/jquery.rating.js" type="text/javascript"></script>
<script src="/javascripts/growinput.js" type="text/javascript"></script>
<script src="/javascripts/jquery.textboxlist.js" type="text/javascript"></script>
<script type="text/javascript">
//<![CDATA[
var AUTH_TOKEN = "OfTLU+sW5GtolZQHGzRjey7uEGOtbR5ZDGSNoIOPZQI=";
//]]>
</script>
<script>
</script>
<link href="/stylesheets/application.css" media="screen" rel="stylesheet" type="text/css" />
<link href="/stylesheets/facebox.css" media="screen" rel="stylesheet" type="text/css" />
<link href="/stylesheets/registration.css" media="screen" rel="stylesheet" type="text/css" />
<!--[if lte IE 7]>
<link href="/stylesheets/ie.css" media="screen" rel="stylesheet" type="text/css" />
<![endif]-->
<link href="/stylesheets/coke.css" media="screen" rel="stylesheet" type="text/css" />
<link href="/stylesheets/styles_radio.css" media="screen" rel="stylesheet" type="text/css" />
<link href="/stylesheets/jquery.rating.css" media="screen" rel="stylesheet" type="text/css" />
<link href="/stylesheets/jquery.textboxlist.css" media="screen" rel="stylesheet" type="text/css" />


  </head> 			')

			f.write('
			 <body locale="coke_ES" market="cokelatam" current_site_url="http://localhost:3000">
    <div id="container">
      <div id="header" class="artists">
          <a href="/home"><img alt="Coca-Cola" class="png_fix" id="logo" src="/images/logo_cokelatam.png" title="Coca-Cola" /></a>
          <ul id="header_nav">
            <li><a href="/home" class="false">Inicio</a></li>
            <li><a href="/playlists" class="">Mixes</a></li>
            <li><a href="/search" class="">Buscar</a></li>
          </ul>

<script>
 var msg="Busca tus mixes y amigos favoritos";
</script>
<div id="search_form">
  <form action="/search" class="line" id="header_search_form" method="get" onsubmit="return Base.header_search.buildSearchUrl();">
    <div>
      <input autocomplete="off" class="search_input" id="search_query" name="q" onblur="restoreInput(msg, this); setTimeout(function() {$(\'.search_results_box\').hide();}, 300);" onfocus=" clearInput(msg, this);" type="text" value="Busca tus mixes y amigos favoritos" />
      <img alt="Search_icon" class="search_button" src="/images/search_icon.gif" />
      <div class="clearer"></div>
    </div>
  </form>
  <div class="search_results_ajax"><img alt="Ajax_activity_indicators_download_animated_icon_animated_busy" src="/images/ajax_activity_indicators_download_animated_icon_animated_busy.gif" /></div>
</div><!--/end search_form -->
<div class="search_results_box"></div>



  <div id="login_register_links">

      <a href="http://localhost:3000/login?return_to=%2Fartists%2Flist">Log in</a>
      |
      <a href="/users/new?return_to=%2Fmy%2Fdashboard">Regístrate</a>

</div>


          <div class="clearer"></div>
          <div id="flash_messages">

          </div>
          <div class="clearer"></div>
      </div><!--/end header -->


      <div id="main_content" class="artists ">

		<div class="support_pages">



	<h1><span class="translation_missing">coke_ES, band_index, title</span></h1>

	<p class="preamble">
		<span class="translation_missing">coke_ES, band_index, description</span>
	</p>

				');


			f.write('
	 <table class="coke">
		<thead>
			<tr>

				<td><span class="translation_missing">coke_ES, band_index, table_header</span></td>
			</tr>
		</thead>
		<tbody> ');
     if var == '#' then
        @accounts = Artist.all(:select=>"id, name",
          :conditions=>"LCASE(name) REGEXP '^[^[:alnum:]].*'",
          #:limit=>2,
          :order=>:name)
      else
        @accounts = Artist.all(:select=>"id, name",
          :conditions=>"LCASE(name) LIKE '#{var}%'",
          #:limit=>2,
          :order=>:name)
      end
			@accounts.each { |a|
				account = Account.find(a.id)
				puts "Account name :"+ account.name
				f.write('
						<tr>
							<td>
								<h2>
									<a href="/search/playlists/'+CGI::escape(account.name)+'">'+account.name+
						'</a>
								</h2>
							</td>
						</tr>

					');
			}

			f.write('
		</tbody>
	</table>
  <br/><br/>

				');

			f.write('
	<div class="alplabetic_filter_list">');
			"A".upto("Z") do | alplabet |
				if alplabet == var then
					f.write('<span id="current_alphabet"><a href="/index-bands/'+alplabet+'">'+alplabet+'</a>&nbsp;</span>');
				else
					f.write('<a href="/index-bands/'+alplabet+'">'+alplabet+'</a>&nbsp;');
				end
			end
			f.write('</div>
	<div class="numeric_filter_list">');

			0.upto(9) do | numeric |
				if numeric == var then
					f.write('<span id="current_numeric"><a href="/index-bands/'+numeric.to_s()+'">'+numeric.to_s()+'</a>&nbsp;</span>');
				else
					f.write('<a href="/index-bands/'+numeric.to_s()+'">'+numeric.to_s()+'</a>&nbsp;');
				end
			end
			f.write('<a href="/index-bands/special">#</a>&nbsp;');
			f.write('

	</div>
</div>
</div>



				');

			f.write('
				</div>
			</div>
		</body>
	</html>
				')

			#	f.write(ERB.new(File.read("#{RAILS_ROOT}/app/views/artists/list.html.erb")).result())
		
		end

 
end