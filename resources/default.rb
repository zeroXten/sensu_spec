actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :specs, :kind_of => Array
attribute :description, :kind_of => String
#attribute :tags, :kind_of => Array, :default => []

#attribute :command, :kind_of => String
#attribute :interval, :kind_of => Integer
#attribute :handlers, :kind_of => [Array, NilClass]
#attribute :subscribers, :kind_of => [Array, NilClass]
#attribute :variables, :kind_of => Hash, :default => nil
