Array.class_eval do
  def sortable(name, *args)
    raise ArgumentError, "parameter hash expected (got #{args.inspect})" unless Array === args
    MachineSort.create(name, args) + self
  end
end