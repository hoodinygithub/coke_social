module MachineSort
  class << self
    def create(name, *args)
      [name] + args
    end
  end
end