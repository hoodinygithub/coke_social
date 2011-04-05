Array.class_eval do
  def sortable(name, *args)
    raise ArgumentError, "parameter hash expected (got #{args.inspect})" unless Array === args
    
    if args[0][1] && args[0][1] == :default
      count = self.count
      self.map do |u| 
        u.instance_variable_set("@default",count)
        count = (count-1)
      end
    end
    
    MachineSort.create(name, args) + self
  end
end