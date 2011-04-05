= Machine Sort

Copyright: Big Bad Machine Inc
Author: Scott Shervington
Homepage: http://www.bigbadmachine.com/projects/machine_sort

== Usage

Controller
  add sortable([name], [sortable_field_name, db_attribute_or_method], ...)
  example:
    @recent_playlists = current_site.playlists.all(:limit => 50, :order => 'total_plays desc').sortable(
          :mixes,
          [:popularity, :total_plays],
          [:rating, :rating_cache],
          [:most_recent, :updated_at],
          [:alpha, :name]
    )

  notes:
    1. (:order => 'total_plays desc') should match the first sortable field in the list.
    2. If the sortable_field_name is the same as the db_attribute then you only need to pass it once
        @recent_playlists = current_site.playlists.all(:limit => 50, :order => 'total_plays desc').sortable(
              :mixes,
              [:popularity, :total_plays],
              :updated_at,
              [:rating, :rating_cache],
              :name
        )

View
  Dropdown w/ Sort options
    call sortable_options_tag(array_of_items, options_hash) to build the sort dropdown
    example:
      <%= sortable_options_tag @recent_playlists, :name => "mixes", :class => "ord_mixes", :i18n_base => "coke_messenger.order_filter" %>
      
      will return:
          <form action="#" class="ord_mixes" id="sortable_options_form_mixes">
            <select class="">
              <option value='popularity'>Order by Popularity</option>
              <option value='rating'>Order by Rating</option>
              <option value='most_recent'>Order by Most Recent</option>
              <option value='alpha'>Order Alphabetically</option>
            </select>
          </form>>
        </form>
    notes: 
      1. sortable_options_tag accepts the following options:
        :name => name of list to sort (must match name given to list or both need to be nil)
        :class or :form_class => class to be appended to Form tag
        :select_class => class to be appended to Select tag
        :i18n => Set this to true if you want to Internationalize the sortable_field_name, ie. t('popularity)
        :i18n_base => Set this if you want to use i18n and need a base name, ie t('coke_messenger.order_filter.popularity')
  
  Sortable List
    call sortable_list(array_of_items, options_hash) do |item| { # rhtml to fill each <li> }
    example:
      <% sortable_list(@recent_playlists, {:name => "mixes", :class => "ult_mixes", :li_class => "estirar"}) do |playlist, index| %>
        <%= avatar_for(playlist, :small, :class => 'avatar', :disable_default_css => true) %>
        <div class="datos">
          <h3><%= playlist.name %></h3>
          <p>Por: <%= link_to playlist.owner.name,djs_details_path(playlist.owner.id), :title => playlist.owner.name, :class=>"link_gris" %></p> 
        </div>
        <%= link_to "Copiar",  copy_mix_layer_path(playlist.id), :title => t('actions.copy') , :rel=> "layer" %>
        <%= link_to_function t('coke_messenger.play'), "Base.Station.request('/playlists/#{playlist.id}.xml', 'xml', Base.Station.stationCollection);Base.Player.random(false)", :class => 'btn_play' %>
      <% end %>
      
      will return:
        <ul class="sortable_options_ul ult_mixes" id="sortable_options_ul_mixes" sortable_fields="popularity,rating,most_recent,alpha">
          <li class="estirar" alpha="test4" most_recent="2011-03-28 19:29:53 UTC" popularity="2" rating="0.0">
            <img alt="5099921685958_800x800_300dpi" class="avatar small" disable_default_css="true" src="http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/89547/image/thumbnail/5099921685958_800x800_300dpi.jpg" />
            <div class="datos">
              <h3>test4</h3>
              <p>Por: <a href="/messenger_player/dj_mix_details/1687662" class="link_gris" title="testmonkey">testmonkey</a></p> 
            </div>
            <a href="/messenger_player/copy_mix_layer/578848" rel="layer" title="Copy">Copiar</a>
            <a class="btn_play" href="#" onclick="Base.Station.request('/playlists/578848.xml', 'xml', Base.Station.stationCollection);Base.Player.random(false); return false;">Play</a>
          </li>
          <li alpha="test3" class="estirar" most_recent="2011-03-23 20:41:21 UTC" popularity="0" rating="0.0">
            ....
          </li>
        </ul>
    
    notes:
      1. sortable_list accepts the following options:
        :name => name of list to sort (must match name given to list or both need to be nil)
        :class or :ul_class => class to be appended to UL tag
        :li_class => class to be appended to LI tag
      2. If you need to number the LIs, then add <span class="ord">1</span> around the indexes.

  
  