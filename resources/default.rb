actions :create, :delete
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :description, :kind_of => String
attribute :command, :kind_of => String, :required => true
attribute :interval, :kind_of => Integer, :default => 60
attribute :handlers, :kind_of => [Array, NilClass], :default => ['default']
attribute :subscribers, :kind_of => [Array, NilClass], :default => ['default']
