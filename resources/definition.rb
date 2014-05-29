#actions :create, :delete
actions :create
default_action :create

attribute :name, :kind_of => Regexp, :name_attribute => true

#attribute :description, :kind_of => String

attribute :command, :kind_of => String, :required => true
#attribute :unique_on, :kind_of => String
attribute :code, :kind_of => String

#attribute :subscribers, :kind_of => Array
#attribute :interval, :kind_of => Integer
#attribute :handlers, :kind_of => Array
#attribute :handle, :kind_of => [TrueClass, FalseClass]
#attribute :subdue, :kind_of => Hash
#attribute :dependencies, :kind_of => Array
#attribute :type, :kind_of => String
#attribute :standalone, :kind_of => [TrueClass, FalseClass]
#attribute :publish, :kind_of => [TrueClass, FalseClass]
#attribute :occurrences, :kind_of => Integer
#attribute :refresh, :kind_of => Integer
#attribute :low_flap_threshold, :kind_of => [String, Integer]
#attribute :high_flap_threshold, :kind_of => [String, Integer]
#attribute :aggregate, :kind_of => [TrueClass, FalseClass]
#attribute :handler, :kind_of => [TrueClass, FalseClass]
