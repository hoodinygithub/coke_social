require 'machine_sort/machine_sort'
require 'machine_sort/array_ext'
require 'machine_sort/helpers/sortable_helper'

ActionView::Base.send(:include, MachineSort::SortableHelper)

PLUGIN_ROOT = File.join(RAILS_ROOT, 'vendor', 'plugins', 'machine_sort')

if Object.const_defined?(:Rails) && File.directory?(Rails.root.to_s + "/public")  
  # install files
  unless File.exists?(RAILS_ROOT + '/public/javascripts/machine_sort/machine_sort.js')
    source = File.join(PLUGIN_ROOT, 'public', 'javascripts', 'machine_sort')
    dest = File.join(RAILS_ROOT, 'public', 'javascripts', 'machine_sort')
    FileUtils.mkdir_p(dest)
    FileUtils.cp(Dir.glob(source+'/*.*'), dest)
  end
end