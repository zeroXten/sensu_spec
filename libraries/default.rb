
class Chef
  class Recipe

    def clean(name)
      name.gsub(/[^\w ]/,'').gsub(/[^\w]+/,'_')
    end

    def describe(name, &block)
      Chef::Log.debug "describe called for #{name}"
      node.run_state['sensu_spec_tree'] ||= []
      node.run_state['sensu_spec_tree'] << name
      Chef::Log.debug "Current tree #{node.run_state['sensu_spec_tree']}, evaluating block"

      index = node.run_state['sensu_spec_tree'].size - 1
      Chef::Log.debug "Current index: #{index}"

      self.instance_eval &block

      if node.run_state['sensu_spec_tree'].last.kind_of? Hash
        Chef::Log.debug "Hash found, processing content"
        names = []
        specs = []
        node.run_state['sensu_spec_tree'].each do |e|
          if e.kind_of? String
            names << e
          elsif e.kind_of? Hash
            specs << e
          end
        end
        spec_name = names.map { |e| clean(e) }.join('.')
        desc = names.join(' ')
        Chef::Log.debug "Defining sensu_spec for #{spec_name} with description #{desc}"
        sensu_spec spec_name do
          specs specs
          description desc
        end
      end
      Chef::Log.debug "End of describe, resetting tree"
      node.run_state['sensu_spec_tree'] = index == 0 ? [] : node.run_state['sensu_spec_tree'][0..index-1]
      Chef::Log.debug "Current tree #{node.run_state['sensu_spec_tree']}"
    end

    def it(name)
      Chef::Log.debug "it called for #{name}"
      raise 'Not defines found' unless node.run_state.has_key?('sensu_spec_tree')
      node.run_state['sensu_spec_tree'] << {:it => name}
    end

    def define(name, &block)
      sensu_spec_definition(name, &block)
    end

    def with(data)
      Chef::Log.debug "with called with data #{data}"
      raise 'Not defines found' unless node.run_state.has_key?('sensu_spec_tree')
      node.run_state['sensu_spec_tree'] << {:with => data}
    end

  end
end
