actions :create, :delete
default_action :create

# sensu_spec "check_proc_http" do
#   description "Checks availability of httpd process"
#   command "check_proc.sh -p httpd"
# end
#
# sensu_spec "check_disk_space" do
#   description "Ensure disk space available"
#   command "check_disk -A"
#   interval 60
#   handlers [ "badgers" ]
#   ...
# end


attribute :name, :kind_of => String, :name_attribute => true
attribute :description, :kind_of => String
attribute :command, :kind_of => String, :required => true
attribute :interval, :kind_of => Integer, :default => 60
attribute :handlers, :kind_of => [Array, NilClass], :default => ["default"]
