actions :create, :delete
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :description, :kind_of => String
attribute :command, :kind_of => String
attribute :interval, :kind_of => Integer
attribute :handlers, :kind_of => [Array, NilClass]
attribute :subscribers, :kind_of => [Array, NilClass]
attribute :variables, :kind_of => Hash, :default => nil
