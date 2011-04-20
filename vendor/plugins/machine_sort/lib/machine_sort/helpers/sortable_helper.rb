module MachineSort::SortableHelper
  
  # ######################################
  # Creates dropdown for Sortable List
  # <form class="ord_mixes" action="#" >
  #   <select id="sortable_options_select_#{name.to_s.underscore.parameterize("_")}">
  #   </select>
  # </form>
  def sortable_options_tag( list_items, options={} )
    html = ""
    name = list_items[0]
    ordered_fields = list_items[1]
    return unless ordered_fields.kind_of?(Array)

    form_options = {}
    form_options[:action] = "#"
    form_options[:id] = options.has_key?(:name) ? "sortable_options_form_#{options[:name].to_s.underscore.parameterize("_")}" : "sortable_options_form"
    form_options[:class] = options[:form_class] || options[:class] || ""
    
    select_options = {}
    select_options[:onchange] = "$.sortable.sort(this.value, '#{name}')"
    select_options[:class] = options[:select_class] || ""
    
    use_i18n = (options.has_key?(:i18n_base) || (options.has_key?(:i18n) && options[:i18n]))
    
    ordered_fields.each do |field|
      field_name = (field.kind_of?(Array) ? field[0] : field).to_s
      field_text = use_i18n ? (options.has_key?(:i18n_base) ? t(options[:i18n_base] + "." + field_name) : t(field_name)) : field_name.titleize
      html += "<option value='#{field_name}'>#{field_text}</option>"
    end

    select = content_tag :select, html, select_options
    
    result = content_tag :form, select, form_options
    result += javascript_include_tag 'machine_sort/machine_sort'
  end
  
  # ######################################
  # Creates UL w/ LI's for each item you need sorted
  # <ul class="ult_mixes">
  #   <% @recent_playlists.each do |playlist| %>
  #     <li class="estirar">
  #       <%= avatar_for(playlist, :small, :class => 'avatar', :disable_default_css => true) %>
  #       <div class="datos">
  #         <h3><%= playlist.name %></h3>
  #         <p>Por: <%= link_to playlist.owner.name,djs_details_path(playlist.owner.id), :title => playlist.owner.name, :class=>"link_gris" %></p> 
  #       </div>
  #       <%= link_to "Copiar",  copy_mix_layer_path(playlist.id), :title => t('actions.copy') , :rel=> "layer" %>
  #       <%= link_to_function t('coke_messenger.play'), "Base.Station.request('/playlists/#{playlist.id}.xml', 'xml', Base.Station.stationCollection);Base.Player.random(false)", :class => 'btn_play' %>
  #     </li>
  #   <% end %>
  # </ul>
  def sortable_list( list_items, options={}, &block )
    html = ""
    name = list_items[0]
    ordered_fields = list_items[1]
    return unless ordered_fields.kind_of?(Array)
    
    if list_items.size > 2
      ul_options = {}
      ul_options[:id] = options.has_key?(:name) ? "sortable_options_ul_#{options[:name].to_s.underscore.parameterize("_")}" : "sortable_options_ul"
      ul_options[:class] = "sortable_options_ul "
      ul_options[:class] += options[:ul_class] || options[:class] || ""
      ul_options[:sortable_fields] = ordered_fields.map{|field| field.kind_of?(Array) ? field[0] : field}.join(",")
      
      li_options = {}
      li_options[:class] = options[:li_class] || ""
    
      list_items[2..-1].each_with_index do |item,index|
        new_block = Proc.new do
          block.call(item,index)
        end
        html += content_tag :li, capture(&new_block), li_options.merge(sortable_options(item, ordered_fields))
      end
      ul = content_tag(:ul, html, ul_options)
      concat(ul)
    else
      ul_options = {}
      ul_options[:class] = options[:ul_class] || options[:class] || ""
      
      li_options = {}
      li_options[:class] = options[:no_results_class] || "no_results"
      
      if options.has_key?(:no_results_partial)
        li = content_tag(:li, (render :partial => options[:no_results_partial]), li_options)
      else
        li = content_tag(:li, (options.has_key?(:no_results_text) ? options[:no_results_text] : "No Results Found"), li_options)
      end
      
      ul = content_tag(:ul, li, ul_options)
      concat(ul)
    end
  end
  
  def sortable_options(object, ordered_fields)
    options = {}
    ordered_fields.each do |field|
      if field.kind_of?(Array)
        options[field[0]] = field[1]==:default ? object.instance_variable_get("@default") : object.send(field[1])
      else
        options[field] = field==:default ? object.instance_variable_get("@default") : object.send(field)
      end
    end
    options
  end

end